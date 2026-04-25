# greetd + Sway + gtkgreet

This setup replaces Ly with greetd and uses a minimal Sway greeter session to run gtkgreet.

The greeter flow is:

1. greetd starts on tty2
2. greetd starts Sway with `/etc/greetd/sway-config`
3. the greeter Sway session runs `gtkgreet -l`
4. after login, gtkgreet starts `dbus-run-session sway --unsupported-gpu`
5. the greeter Sway session exits with `swaymsg exit`

## Requirements

Install the packages for:

- `greetd`
- `greetd-gtkgreet`
- `sway`
- `dbus`

## Install

First disable the old Ly services once:

```bash
sudo systemctl disable --now ly@tty2.service
sudo systemctl disable --now ly-console-selector.service
```

Then run the installer from the repository root:

```bash
./greetd/install-greetd-cage-gtkgreet.sh
```

That copies:

- `greetd/.config/greetd/config.toml` to `/etc/greetd/config.toml`
- `greetd/.config/greetd/sway-config` to `/etc/greetd/sway-config`

Then it runs:

```bash
sudo systemctl enable --now greetd.service
```

## Roll back

If you want to go back to Ly:

```bash
sudo systemctl disable --now greetd.service
sudo systemctl enable --now ly@tty2.service
```

If you want the earlier Ly console selector too:

```bash
sudo systemctl enable --now ly-console-selector.service
```
