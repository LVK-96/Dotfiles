#!/usr/bin/env python3
"""Small CLI for inspecting RTL waveform dumps via VCD parsing.

VCD is parsed natively. FST/FSDB/VPD are converted to VCD using command-line
converters when present on PATH.
"""

from __future__ import annotations

import argparse
import fnmatch
import gzip
import io
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import BinaryIO, Iterable, Iterator, TextIO


@dataclass
class Signal:
    path: str
    code: str
    width: int
    kind: str


@dataclass
class Header:
    timescale: str | None
    signals: list[Signal]


CONVERTERS = {
    ".fst": [["fst2vcd"]],
    ".fsdb": [["fsdb2vcd"], ["verdi", "-ssf"]],
    ".vpd": [["vpd2vcd"]],
}


def open_wave(path: Path) -> tuple[TextIO, subprocess.Popen[bytes] | None]:
    suffixes = path.suffixes
    if suffixes[-2:] == [".vcd", ".gz"]:
        return io.TextIOWrapper(gzip.open(path, "rb"), encoding="utf-8", errors="replace"), None
    if path.suffix == ".vcd":
        return path.open("r", encoding="utf-8", errors="replace"), None

    for converter in CONVERTERS.get(path.suffix.lower(), []):
        exe = shutil.which(converter[0])
        if not exe:
            continue
        cmd = [exe, *converter[1:], str(path)]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        assert proc.stdout is not None
        return io.TextIOWrapper(proc.stdout, encoding="utf-8", errors="replace"), proc

    raise SystemExit(
        f"No native parser/converter for {path.suffix or 'this file'} found. "
        "Export to VCD or install a converter such as fst2vcd, fsdb2vcd, or vpd2vcd."
    )


def parse_header(lines: Iterator[str]) -> tuple[Header, Iterator[str]]:
    scopes: list[str] = []
    signals: list[Signal] = []
    timescale: str | None = None

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("$timescale"):
            parts = stripped.split()
            if "$end" in parts:
                timescale = " ".join(parts[1 : parts.index("$end")])
            else:
                # Multi-line timescale.
                value_parts = []
                for next_line in lines:
                    if "$end" in next_line:
                        break
                    value_parts.append(next_line.strip())
                timescale = " ".join(value_parts).strip() or None
        elif stripped.startswith("$scope"):
            parts = stripped.split()
            if len(parts) >= 3:
                scopes.append(parts[2])
        elif stripped.startswith("$upscope"):
            if scopes:
                scopes.pop()
        elif stripped.startswith("$var"):
            parts = stripped.split()
            if len(parts) >= 5:
                kind = parts[1]
                try:
                    width = int(parts[2])
                except ValueError:
                    width = 1
                code = parts[3]
                name = parts[4]
                full = ".".join([*scopes, name]) if scopes else name
                signals.append(Signal(full, code, width, kind))
        elif stripped.startswith("$enddefinitions"):
            return Header(timescale, signals), lines

    raise SystemExit("VCD ended before $enddefinitions")


def iter_value_changes(lines: Iterable[str]) -> Iterator[tuple[int, str, str]]:
    time = 0
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("$"):
            continue
        if line.startswith("#"):
            try:
                time = int(line[1:])
            except ValueError:
                pass
            continue
        first = line[0]
        if first in "01xXzZ":
            yield time, line[1:], first
        elif first in "bBrR":
            parts = line.split(None, 1)
            if len(parts) == 2:
                yield time, parts[1], parts[0][1:]


def parse_time(value: str | None) -> int | None:
    if value is None:
        return None
    return int(value.replace("_", ""))


def print_summary(header: Header, body: Iterable[str]) -> None:
    max_time = 0
    changes = 0
    for t, _, _ in iter_value_changes(body):
        max_time = max(max_time, t)
        changes += 1
    scopes = sorted({s.path.rsplit(".", 1)[0] for s in header.signals if "." in s.path})
    print(f"timescale: {header.timescale or 'unknown'}")
    print(f"signals: {len(header.signals)}")
    print(f"scopes: {len(scopes)}")
    print(f"time_range: 0..{max_time}")
    print(f"value_changes: {changes}")
    if scopes:
        print("sample_scopes:")
        for scope in scopes[:20]:
            print(f"  {scope}")


def print_signals(header: Header, pattern: str | None) -> None:
    matches = header.signals
    if pattern:
        matches = [s for s in matches if fnmatch.fnmatchcase(s.path, pattern)]
    for sig in matches:
        width = f"[{sig.width}]" if sig.width != 1 else ""
        print(f"{sig.path}{width}  code={sig.code} type={sig.kind}")
    print(f"matched: {len(matches)}", file=sys.stderr)


def print_traces(
    header: Header,
    body: Iterable[str],
    traces: list[str],
    start: int | None,
    end: int | None,
    limit: int,
) -> None:
    by_path = {s.path: s for s in header.signals}
    wanted = []
    missing = []
    for trace in traces:
        if trace in by_path:
            wanted.append(by_path[trace])
            continue
        globbed = [s for s in header.signals if fnmatch.fnmatchcase(s.path, trace)]
        if globbed:
            wanted.extend(globbed)
        else:
            missing.append(trace)

    if missing:
        print("missing signals: " + ", ".join(missing), file=sys.stderr)
    code_to_paths: dict[str, list[str]] = {}
    for sig in wanted:
        code_to_paths.setdefault(sig.code, []).append(sig.path)

    printed = 0
    for time, code, value in iter_value_changes(body):
        if start is not None and time < start:
            continue
        if end is not None and time > end:
            break
        paths = code_to_paths.get(code)
        if not paths:
            continue
        for path in paths:
            print(f"{time}\t{path}\t{value}")
            printed += 1
            if printed >= limit:
                print(f"limit reached: {limit}", file=sys.stderr)
                return


def main() -> int:
    parser = argparse.ArgumentParser(description="Inspect VCD/FST/FSDB/VPD waveform files")
    parser.add_argument("wave", type=Path)
    parser.add_argument("--summary", action="store_true", help="print waveform summary")
    parser.add_argument("--signals", nargs="?", const="*", help="list signals, optionally matching a glob")
    parser.add_argument("--trace", action="append", default=[], help="print transitions for a signal path or glob")
    parser.add_argument("--from", dest="start", help="start time tick")
    parser.add_argument("--to", dest="end", help="end time tick")
    parser.add_argument("--limit", type=int, default=200, help="maximum trace lines")
    args = parser.parse_args()

    if not args.wave.exists():
        raise SystemExit(f"No such file: {args.wave}")

    stream, proc = open_wave(args.wave)
    try:
        header, body = parse_header(iter(stream))
        if args.summary or (args.signals is None and not args.trace):
            print_summary(header, body)
        elif args.signals is not None:
            print_signals(header, args.signals)
        elif args.trace:
            print_traces(header, body, args.trace, parse_time(args.start), parse_time(args.end), args.limit)
    finally:
        stream.close()
        if proc:
            _, stderr = proc.communicate(timeout=2)
            if proc.returncode not in (0, None):
                sys.stderr.write(stderr.decode("utf-8", errors="replace"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
