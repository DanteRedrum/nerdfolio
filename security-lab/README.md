# Security Lab

Isolated, disposable, intentional.

## Architecture

All lab traffic is air-gapped via Hyper-V Private switch `vSwitch-Isolated`.
VMs on this switch cannot reach the host, the physical network, or the internet.
Isolation is enforced at the hypervisor level — not by policy.

## Network

| Switch | Type | Purpose |
|---|---|---|
| `vSwitch-Isolated` | Private | Security lab only — no external access |

| VM | IP | Role |
|---|---|---|
| `nf-kali` | 10.10.10.10 | Attack machine |
| Vulnerable VMs | 10.10.10.x | Targets — provisioned and destroyed per session |

## Structure
security-lab/
    kali/           Kali VM setup and tooling notes
    vulnerable-vms/ VulnHub VM conversion and import notes
    notes/
        methodology/  Attack methodology reference
        boxes/        Write-ups per vulnerable VM
    playbooks/      Ansible playbooks for lab lifecycle

## Rules

1. Kali VM stays on `vSwitch-Isolated` during attacks
2. Vulnerable VMs are never persistent — destroy after each session
3. Every completed box gets a write-up in `notes/boxes/`
4. Nothing from the lab touches the home network

## Vulnerable VMs

Downloaded from VulnHub — https://www.vulnhub.com
Converted from OVA/VMDK to VHDX for Hyper-V.
See `vulnerable-vms/` for conversion process.

## Kasm Phishing Sandbox

Kali workspace running in Kasm on `nf-kasm-ubuntu`.
Used for opening suspicious links and attachments in a
disposable container. Session destroyed after each use.