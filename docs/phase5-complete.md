# Phase 5 Complete

## What Was Built

An isolated, disposable security lab. Air-gapped from the home network
at the hypervisor level. Everything runs on vSwitch-Isolated — a Hyper-V
Private switch with no uplink, enforced by the hypervisor not by policy.

## Infrastructure

| VM | IP | Role | Switch |
|---|---|---|---|
| nf-kali | 10.10.10.10 | Attack machine | vSwitch-Isolated |
| kioptrix-1 | TBD | Vulnerable target | vSwitch-Isolated |
| mr-robot | TBD | Vulnerable target | vSwitch-Isolated |
| dc-1 | TBD | Vulnerable target | vSwitch-Isolated |
| basic-pentesting-1 | TBD | Vulnerable target | vSwitch-Isolated |

## Ansible Playbooks

| Playbook | Purpose |
|---|---|
| `provision-kali.yml` | Provision Kali attack VM |
| `provision-vulnvm.yml` | Provision vulnerable VM from VHDX |
| `destroy-vulnvm.yml` | Destroy VM and remove VHD |
| `set-vm-switch.yml` | Move VM NIC between switches |

## Kali Setup

- Kali 2026.1 installed on vSwitch-Isolated
- Static IP 10.10.10.10
- dnsmasq running as DHCP server for 10.10.10.100-200
- Secure Boot disabled — Kali bootloader not Microsoft signed
- Tools: default Kali toolset plus feroxbuster, seclists

## Vulnerable VMs

Downloaded from VulnHub, converted from VMDK to VHDX via
StarWind V2V Converter, provisioned via Ansible.

All VMs on vSwitch-Isolated — no internet access, no home
network access, no host access.

## Documentation Structure

security-lab/
	notes/
	  methodology/    Attack methodology reference
	  boxes/          Write-up per completed box (TEMPLATE.md provided)
	vulnerable-vms/   Conversion and import notes
	kali/             Kali setup and tooling notes
	playbooks/        Lab lifecycle automation

## Known Issues

### Kioptrix DHCP
Kioptrix Level 1 not obtaining DHCP lease from dnsmasq.
Likely legacy network adapter incompatibility with Hyper-V Gen 1.
Workarounds documented in vulnerable-vms/README.md.
To be resolved when attacking this box.

## Workflow

### Start a lab session
```bash
# Start Kali
ansible-playbook -i inventory/hosts.ini playbooks/vm-start.yml \
  -e "vm_name=nf-kali"

# Start target
ansible-playbook -i inventory/hosts.ini playbooks/vm-start.yml \
  -e "vm_name=kioptrix-1"
```

### End a lab session
```bash
# Stop target
ansible-playbook -i inventory/hosts.ini playbooks/vm-stop.yml \
  -e "vm_name=kioptrix-1"

# Stop Kali
ansible-playbook -i inventory/hosts.ini playbooks/vm-stop.yml \
  -e "vm_name=nf-kali"
```

### Destroy a VM after completion
```bash
ansible-playbook -i inventory/hosts.ini \
  ../security-lab/playbooks/destroy-vulnvm.yml \
  -e "vm_name=kioptrix-1"
```

### Move Kali to internet for updates
```bash
ansible-playbook -i inventory/hosts.ini playbooks/set-vm-switch.yml \
  -e "vm_name=nf-kali" -e "switch_name=vSwitch-External"
# update, then move back
ansible-playbook -i inventory/hosts.ini playbooks/set-vm-switch.yml \
  -e "vm_name=nf-kali" -e "switch_name=vSwitch-Isolated"
```

## Up Next

Phase 6 — FiveM Server. Infrastructure as code applied to a game server.
