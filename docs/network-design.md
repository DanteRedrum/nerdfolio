# Network Design

## Physical Network

ISP-provided router — no managed VLAN support. Physical network segmentation
is not available at this stage. Segmentation is implemented in software via
Hyper-V virtual switches.

## Hyper-V Virtual Switch Topology

| vSwitch | Type | Purpose |
|---|---|---|
| `vSwitch-External` | External | Internet-facing VMs, bridges to physical NIC |
| `vSwitch-Internal` | Internal | Lab inter-VM communication, host can reach VMs |
| `vSwitch-Isolated` | Private | Security lab — no host access, no external access |

## Security Lab Isolation

`vSwitch-Isolated` is a Hyper-V Private switch. VMs on this switch cannot
reach the host, the physical network, or the internet. Hyper-V enforces
this at the hypervisor level — not by policy, by design.

Vulnerable VMs are provisioned and torn down via Ansible playbook.
They are never persistent. See `security-lab/` for methodology.

## Future State

When a managed switch is added, physical VLANs become available.
When a dedicated Proxmox host is added, the bridge topology from the
original design gets implemented there. This doc will be updated at
that time.
