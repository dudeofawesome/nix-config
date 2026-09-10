# kings-canyon

Louis' home server

## Hardware

- Motherboard: ASRock Rack ROMED8-2T
- CPU: AMD EPYC 7443 (Milan / EPYC 7003)
- GPU: EVGA FTW3 ULTRA GAMING Nvidia RTX 3080 10GB
- [Full parts list](https://pcpartpicker.com/user/dudeofawesome/saved/cF6wkL)

## Initial installation

Kings-canyon will use native encrypted bcachefs, Secure Boot through Lanzaboote,
and Clevis TPM2 unlock in the systemd initrd, following
[olympus](../olympus/README.md). Keep a strong recovery passphrase for boots when
the TPM policy cannot be satisfied.

Do not use this repository's `nixos-anywhere.sh` wrapper: it expects a LUKS
password secret. Format and mount bcachefs before running `nixos-install`.

## Prepare firmware and installer

Enter UEFI Setup with **F2** during POST. Record the BIOS version on the Main
screen. Refer to the
[ROMED8-2T manual](https://download.asrock.com/Manual/ROMED8-2TBCM.pdf)
(printed pages 50, 62, 71–72, and 77); the Secure Boot submenu path below
was confirmed on this machine.

| UEFI setting                                                           | Installation value                                                                |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| **Boot** → CSM Parameters → CSM                                        | `Disabled`                                                                        |
| **Security** → Secure Boot                                             |                                                                                   |
| ├ Secure Boot                                                          | `Disabled` until signed boot files are installed; then `Enabled`                  |
| ├ Secure Boot Mode                                                     | `Custom`                                                                          |
| ├ Key Management → Factory Key Provision                               | `Disabled`                                                                        |
| ├ Key Management → Platform Key(PK)                                    | `[Delete]`                                                                        |
| **Advanced**                                                           |                                                                                   |
| ├ Chipset Configuration → SPI/LPC TPM Switch                           | Match the installed TPM: `LPC` for TPM1 (17-pin), `SPI` for TPM_BIOS_PH1 (13-pin) |
| ├ AMD CBS → UMC Common Options → DDR4 Common Options → Security → TSME | `Enabled`                                                                         |
