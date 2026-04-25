# Hardware

## Primary Lab Host

| Component | Detail |
|---|---|
| CPU | Intel i7-13700K |
| GPU | NVIDIA RTX 4090 |
| RAM | 64GB |
| OS/Primary Drive | 2TB NVMe — Windows 11, daily driver |
| Lab Storage | 1TB SSD — VM disks, lab storage |
| Bulk Storage | 2TB HDD — ISOs, templates, backups |

## Supporting Hardware

| Device | Planned Role |
|---|---|
| Raspberry Pi (x2) | TBD — candidates: DNS/DHCP node, Ansible control node, monitoring |

## Hypervisor

Hyper-V on Windows 11. This machine is a daily driver — Proxmox bare metal
was considered and ruled out. Hyper-V runs natively on Windows without
requiring a reboot to switch contexts. The lab lives alongside normal use.

GPU passthrough for Ollama is deferred. Ollama will run CPU-only initially.
When a dedicated lab host is added in the future, the Ansible playbooks migrate
and Proxmox goes there. The automation story doesn't change.

## Future State

Dedicated lab host — Proxmox bare metal, GPU passthrough, full separation
from the daily driver. Nerdfolio playbooks are written to be portable.
