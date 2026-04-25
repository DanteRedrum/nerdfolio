# Hyper-V

Hyper-V is the hypervisor for the Nerdfolio lab. It runs natively on Windows 11
on the primary lab host, allowing the lab to coexist with daily driver use
without requiring a reboot to switch contexts.

## Virtual Switches

| vSwitch | Type | Purpose |
|---|---|---|
| `vSwitch-External` | External | Internet-facing VMs, bridges to physical NIC |
| `vSwitch-Internal` | Internal | Lab inter-VM communication, host can reach VMs |
| `vSwitch-Isolated` | Private | Security lab — no host access, no external access |

VLAN ID is intentionally disabled. The physical network is an ISP-provided
router with no managed VLAN support. Tags would go nowhere. Revisit when
a managed switch is added.

## Storage

| Drive | Path | Role |
|---|---|---|
| 1TB SSD (D:) | `D:\Hyper-V\Virtual Hard Disks` | VM disks |
| 1TB SSD (D:) | `D:\Hyper-V\Virtual Machines` | VM config files |
| 2TB HDD (E:) | `E:\Hyper-V\ISOs` | OS images and templates |
| 2TB HDD (E:) | `E:\Hyper-V\Backups` | VM backups |

## Notes

GPU passthrough is not available under Hyper-V on a daily driver machine.
Ollama runs CPU-only until a dedicated lab host is added. See
`docs/hardware.md` for future state.

## VM Naming Convention

All VMs follow the pattern `nf-[role]-[os]` for consistency across
Ansible inventory and documentation.

Examples:
- `nf-docker-ubuntu`
- `nf-kali-lab`
- `nf-ansible-ubuntu`