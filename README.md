# Pedalboard

Firmware for a wireless three-pedal keyboard, built with
[RMK](https://rmk.rs), a feature-rich keyboard firmware written in Rust.

See the Seeed Studio [XIAO nRF52840 pinout sheet](https://files.seeedstudio.com/wiki/XIAO-BLE/XIAO-nRF52840-pinout_sheet.xlsx)
for the controller's pin assignments.

## uf2 support

If you’re using the Adafruit_nRF52_Bootloader (pre-installed on the nice!nano), you’re in luck! This bootloader supports the .uf2 firmware format, which eliminates the need for a debugging probe to flash your firmware. RMK uses the `cargo-make` tool to generate .uf2 firmware, with the generation process defined in the `Makefile.toml`.

Follow these steps to generate and flash the .uf2 firmware with RMK:

1. Get `cargo-make` tool:
   ```shell
   cargo install --force cargo-make
   ```
2. Compile RMK and generates .uf2 firmware:
   ```shell
   cargo make uf2 --release
   ```
3. Flash

   - Put your board into bootloader mode. A USB drive will appear on your computer.
   - Drag and drop the generated .uf2 firmware file onto the USB drive. The RMK firmware will be automatically flashed onto your microcontroller.

   For additional details on entering bootloader mode and flashing firmware, refer to the [nice!nano documentation](https://nicekeyboards.com/docs/nice-nano/getting-started#flashing-firmware-and-bootloaders)

### Tips for nRF52840

Most nice!nano compatible boards have bootloader with SoftDevice pre-flashed. Since v0.7.x, RMK will remove old SoftDevice Bluetooth stack and replace it with its own. So if you want to rollback to v0.6.x, or switch to firmwares that use SoftDevice stack(for example, zmk), you will need to [re-flash the bootloader](https://nicekeyboards.com/docs/nice-nano/troubleshooting#my-nicenano-seems-to-be-acting-up-and-i-want-to-re-flash-the-bootloader).

### Additional notes

RMK defaults to USB-priority mode if a USB cable is connected. After flashing, remember to disconnect the USB cable, or [switch to BLE-priority mode](https://rmk.rs/docs/features/wireless.html#multiple-profile-support) by pressing User11(Switch Output) key.

## Future option: BLE-only with Feather nRF52832

RMK 0.9 supports the Adafruit Feather nRF52832 through its `nrf52832_ble`
feature. The current direct-pin GPIOs are also exposed on the Feather:

- `P0_02`: A0
- `P0_03`: A1
- `P0_28`: A4

This is not a drop-in firmware target. The nRF52832 has 512 KiB flash, 64 KiB
RAM, and no native USB peripheral, so keyboard output is BLE-only. The build
would need to use `nrf52832` features in RMK, `nrf-sdc`, `nrf-mpsl`, and
`embassy-nrf`, plus an nRF52832 memory map. The current USB mass-storage UF2
workflow does not work on this board; use the Feather's serial DFU bootloader or
an SWD probe instead.

## License

Except for third-party components, this project is licensed under the
[PolyForm Noncommercial License 1.0.0](LICENSE). RMK is available under the
MIT License or Apache License 2.0; see [the third-party notices](THIRD_PARTY_NOTICES.md).
