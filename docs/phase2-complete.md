# Phase 2 Complete

## What Was Built

- Ansible installed and configured on nf-ansible-ubuntu
- Ansible Vault configured — credentials never touch GitHub
- group_vars structure established for per-group variable management
- WinRM configured on Windows host — Ansible manages Hyper-V directly
- Base hardening playbook — idempotent, runs against any Linux VM
- VM provisioning playbook — creates Hyper-V VMs from Ansible
- VM removal playbook — tears down VMs and cleans up VHDs
- nf-docker-ubuntu provisioned and hardened
- IP forwarding enabled on Windows host — Internal VMs have internet access

## Decisions Made

**group_vars over hosts.ini for connection vars**
INI format inventory doesn't support Jinja2 templating at connection time.
Connection variables live in group_vars, vault credentials loaded automatically.

**ansible_password directly in vault**
Referencing vault variables via Jinja2 in ansible_password doesn't resolve
at connection time. Password goes directly into vault.yml as ansible_password.

**Swap on Docker VM**
Ubuntu Server installs no swap by default. apt operations under memory
pressure caused kernel panics. 4GB swapfile added, persisted via fstab.

**16GB RAM for nf-docker-ubuntu**
Docker workload plus apt operations require headroom. OOM kills resolved
by combination of increased RAM and swap.

**IP forwarding over NAT**
New-NetNat tested but not required. IP forwarding on the Windows host
interfaces is sufficient and persists across reboots.

## Up Next

Phase 3 — Docker and Services. The living layer.
