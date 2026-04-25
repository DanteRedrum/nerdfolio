# Network Design

## Physical Network

ISP-provided router — no managed VLAN support. Physical network segmentation
is not available at this stage. Segmentation is implemented in software via
Proxmox Linux bridges.

## Proxmox Bridge Topology

| Bridge | Uplink | Purpose |
|---|---|---|
| `vmbr0` | Physical NIC | Internet-facing VMs — general lab, Docker host |
| `vmbr1` | None | Internal only — services, inter-VM communication |
| `vmbr2` | None | Security lab — completely isolated, no uplink ever |

## Security Lab Isolation

`vmbr2` has no physical uplink by design. VMs attached to this bridge
cannot reach the physical network or the internet. Isolation is enforced
at the hypervisor level, not by policy.

Vulnerable VMs are provisioned and torn down via Ansible playbook.
They are never persistent. See `security-lab/` for methodology.

## Future State

When a managed switch is added, physical VLANs will replace or supplement
the bridge topology. This doc will be updated at that time.