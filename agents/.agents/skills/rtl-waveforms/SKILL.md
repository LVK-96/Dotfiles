---
name: rtl-waveforms
description: Inspect RTL simulation waveform dumps, summarize signals, and extract transitions from VCD/FST/FSDB-style files. Use when the user mentions waveforms, RTL simulation debug, VCD, FST, FSDB, SHM, VPD, GTKWave, Verdi, Questa, Vivado xsim, or asks to inspect signal activity.
---

# RTL Waveforms

## Goal

Help the agent read simulation waveform files without opening a GUI. Prefer deterministic command-line inspection, produce concise summaries, and only ask the user to export/convert when the local machine lacks proprietary readers.

## Quick start

Use the bundled helper first:

```bash
python3 /home/leo/.agents/skills/rtl-waveforms/scripts/wavepeek.py path/to/dump.vcd --summary
python3 /home/leo/.agents/skills/rtl-waveforms/scripts/wavepeek.py path/to/dump.vcd --signals 'top.cpu.*'
python3 /home/leo/.agents/skills/rtl-waveforms/scripts/wavepeek.py path/to/dump.vcd --trace 'top.reset' --trace 'top.state'
```

For non-VCD formats, the helper tries available converters (`fst2vcd`, `fsdb2vcd`, `vpd2vcd`) and then parses the VCD stream.

## Workflow

1. Identify file type:
   - `.vcd`: parse directly.
   - `.fst`: try `fst2vcd` from GTKWave.
   - `.fsdb`: try `fsdb2vcd`/Verdi tools if installed; otherwise ask for VCD/FST export.
   - `.vpd`: try `vpd2vcd`.
   - `.shm`, `.wlf`, simulator databases: ask which simulator generated it and whether CLI export tools are available.
2. Run `wavepeek.py --summary` to get timescale, time range, scopes, and top-level signal count.
3. Run `wavepeek.py --signals '<glob>'` to find candidate nets. Use hierarchical names such as `tb.dut.clk`.
4. Run `wavepeek.py --trace '<signal>'` for selected signals. Add `--limit N` to cap transitions.
5. For debug questions, correlate transitions with the user’s expected behavior and cite exact times.

## Helper options

```bash
wavepeek.py WAVE --summary
wavepeek.py WAVE --signals '[glob]'
wavepeek.py WAVE --trace SIGNAL [--trace SIGNAL ...] [--from TIME] [--to TIME] [--limit N]
```

Times are raw VCD time ticks. Convert using the reported `$timescale`.

## Notes and limitations

- VCD parsing is native and works without extra tools.
- FST/FSDB/VPD require converter binaries on `PATH`; FSDB is proprietary, so a Verdi/Novas installation is usually required.
- Very large dumps should be queried with narrow `--signals` and `--trace` selections rather than fully printed.
- Do not invent waveform values. If a signal is absent or optimized away, say so and suggest rerunning with dumping enabled for that hierarchy.
