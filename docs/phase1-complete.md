# Phase 1 Complete

## What Was Built

- GitHub repo created with full directory structure
- Documentation standards established
- Hyper-V enabled and configured as lab hypervisor
- Three virtual switches created and documented
- Storage paths configured and documented
- Hardware and network design documented honestly

## Decisions Made

**Proxmox → Hyper-V**
Primary machine is a daily driver. Bare metal Proxmox would require rebooting
out of Windows to use the lab. Hyper-V runs natively alongside Windows.
Proxmox is the right answer on a dedicated host — documented as future state.

**VLAN ID disabled**
ISP router has no managed VLAN support. Tags would go nowhere. Physical
isolation for the security lab is enforced by Hyper-V Private switch type.
Revisit when a managed switch is added.

**GPU passthrough deferred**
Not available under Hyper-V on a daily driver. Ollama runs CPU-only until
a dedicated lab host exists.

## What Phase 1 Produces

A foundation everything else stands on. The repo exists, the philosophy is
documented, the hypervisor is running, and every decision made here is
written down with the reasoning behind it.

## Up Next

Phase 2 — Ansible. Nothing gets built manually twice.