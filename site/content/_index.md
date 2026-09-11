+++
title = "Home"
template = "index.html"
+++

# shortcuts underfoot

Pedalboard turns three momentary foot switches into a wireless keyboard. It is built around a Seeed Studio XIAO nRF52840 and runs [RMK](https://rmk.rs), a keyboard firmware written in Rust.

Use it over Bluetooth or USB for push-to-talk, muting, automation, or any action that is useful while both hands are busy.

## Controls

The default layout emits uncommon macOS shortcuts for automation tools to pick up. “Meh” means Control + Option + Shift.

| Pedal | Tap | Hold for one second |
| --- | --- | --- |
| Left | Meh + F16 | — |
| Middle | Meh + F17 | Mute audio output |
| Right | Meh + M | Meh + Backspace |

Hold the left pedal while resetting or powering on the controller to enter the UF2 bootloader.

## Hardware

Each normally-open switch connects one GPIO directly to ground; RMK supplies the pull-up resistor.

| Pedal | XIAO nRF52840 GPIO |
| --- | --- |
| Left | P0.02 |
| Middle | P0.03 |
| Right | P0.28 |

There are no diodes or key matrix: three switches, three signal wires, and ground are enough.

## Build and flash

Install Rust and [`cargo-make`](https://github.com/sagiegurari/cargo-make), then build the UF2 image:

```console
cargo install --force cargo-make
just build
```

Hold the left pedal while resetting the XIAO. When the `XIAO-SENSE` drive appears, flash the firmware with:

```console
just flash
```

The key bindings, pins, Bluetooth settings, and hold timing live in [`keyboard.toml`](https://git.neonforest.org/ra/pedalboard/src/branch/main/keyboard.toml).
