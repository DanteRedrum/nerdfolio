# Nerdfolio

Nerdfolio is a culmination of things I do for the love of it.

It's not a portfolio in the traditional sense. It's documentation of how I think
and how I build. The goal is simple: someone should be able to clone this repo
and rebuild my entire environment from scratch — Proxmox, networking, Docker
services, security lab, all of it — provisioned via Ansible.

If you're reading this, you're seeing how I actually work.

---

## Structure

| Directory | Purpose |
|---|---|
| `docs/` | Architecture decisions, hardware, network design |
| `hyperv/` | Proxmox configuration and notes |
| `ansible/` | Playbooks, roles, inventory — the connective tissue |
| `docker/` | Compose files for all running services |
| `powershell/` | 75+ scripts, organized and documented |
| `security-lab/` | HTB methodology, tooling, disposable VM playbooks |
| `fivem/` | QBCore server config and provisioning |
| `freecad/` | Homelab physical designs and print settings |
| `llm/` | Local LLM integration, RAG, environment-aware assistant |

## Phases

The project builds in phases. Each phase is functional on its own and feeds
the next. Ansible is the through line — it touches almost every phase and
makes the final one possible.

- **Phase 1** — Foundation: repo, documentation standards, Proxmox base
- **Phase 2** — Automation Layer: Ansible, VM provisioning, hardening
- **Phase 3** — Docker & Services: containerized tools, Ollama, Open WebUI
- **Phase 4** — PowerShell Module: existing scripts get a real home
- **Phase 5** — Security Lab: isolated, disposable, intentional
- **Phase 6** — FiveM Server: infrastructure as code applied to a game server
- **Phase 7** — FreeCAD & Physical Layer: the stuff you can hold
- **Phase 8** — LLM Integration: local AI aware of the entire environment
- **Final Phase** — Culmination: full teardown and rebuild from the repo alone

## Status

🔧 Phase 1 in progress
