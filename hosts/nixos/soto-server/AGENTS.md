# soto-server

Josh Gibbs's home server. NixOS on a Dell PowerEdge T430.

## Hardware

| Part          | Model                                           |
| ------------- | ----------------------------------------------- |
| Chassis       | PowerEdge T430 (5U)                             |
| Motherboard   | Dell 0975F3                                     |
| CPU           | Intel Xeon E5-2630 v3                           |
| RAM           | 2× Hynix 16GB 2Rx4 PC4-2133P (HMA42GR7MFR4N-TF) |
| PSU           | 2× 750W (0V1YJ6A00)                             |
| SAS backplane | unknown                                         |

## Talking to it (out-of-band)

Managed through the iDRAC 8, not the host OS. The graphical Virtual Console can't be driven programmatically — use these instead:

- **Power, sensors, serial console** — [../../../scripts/ipmi.sh](../../../scripts/ipmi.sh):
  `./scripts/ipmi.sh soto-server chassis power status` · `… power cycle` · `… sol activate`
- **Power, boot override, virtual media** — [../../../scripts/redfish.sh](../../../scripts/redfish.sh):
  `./scripts/redfish.sh soto-server /redfish/v1/Managers/iDRAC.Embedded.1/VirtualMedia/CD`

The OS boot/login is on serial (`console=ttyS1`), reachable with `ipmi.sh soto-server sol activate`. Run either script with no args for full usage.
