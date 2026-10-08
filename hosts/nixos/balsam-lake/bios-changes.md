# HP t540 — BIOS changes from reset defaults

**System:** HP t540  
**Starting state:** BIOS reset to defaults immediately before configuration

Only settings observed changing from their post-reset values are recorded below. Settings viewed but not changed are omitted.

| BIOS setting           | After BIOS reset | Selected value         |
| ---------------------- | ---------------- | ---------------------- |
| Secure Boot            | Enabled          | Disabled, then Enabled |
| Clear Secure Boot Keys | Don't Clear      | Clear                  |
| Key Ownership          | HP keys          | Custom keys            |
| Fast Boot              | Enabled          | Disabled               |
| After Power Loss       | Off              | Previous State         |

## Secure Boot setup note

The **Secure Boot**, **Clear Secure Boot Keys**, and **Key Ownership** selections are for the **initial NixOS/Lanzaboote Secure Boot setup**, including preparation for owner-managed keys. **Secure Boot = Disabled is temporary**, not the intended final configuration. After the appropriate keys are enrolled and the signed boot chain is ready, re-enable Secure Boot and verify booting.
