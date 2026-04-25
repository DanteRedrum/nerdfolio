# Hardware

## Primary Lab Host

| Component | Detail |
|---|---|
| CPU | Intel i7-13700K |
| GPU | NVIDIA RTX 4090 |
| RAM | 64GB |
| OS Drive | 2TB NVMe — Windows (not managed by Proxmox) |
| Proxmox Drive | 1TB SSD — Proxmox OS and VM disks |
| Bulk Storage | 2TB HDD — ISOs, templates, backups |

## Supporting Hardware

| Device | Planned Role |
|---|---|
| Raspberry Pi (x2) | TBD — candidates: DNS/DHCP node, Ansible control node, monitoring |

## Notes

The 4090 is earmarked for Ollama via GPU passthrough in Phase 3/8.
IOMMU must be enabled at Proxmox install time — documented in
`proxmox/`.

The NVMe is intentionally outside Proxmox. Windows stays
untouched. The 1TB SSD is sufficient for the full project scope.