# Phase 3 Complete

## What Was Built

- Docker installed on all lab VMs via Ansible
- Portainer — container management UI
- Pi-hole — internal DNS for 192.168.100.0/24
- Nginx Proxy Manager — hostname routing for all services
- Uptime Kuma — service monitoring
- Vaultwarden — password manager for lab credentials
- Gitea — self-hosted git
- Code Server — browser-based VS Code
- Dashy — lab dashboard
- Stirling PDF — PDF utilities
- Ollama — local LLM inference
- Open WebUI — Ollama frontend
- Wazuh — SIEM, learning tool
- CyberChef — data analysis utility
- Kasm Workspaces — remote desktop environment

## VM Assignment

| VM | Role | Always On |
|---|---|---|
| nf-docker-ubuntu | Core and utilities | Yes |
| nf-ai-ubuntu | Ollama, Open WebUI | On demand |
| nf-kasm-ubuntu | Kasm | On demand |
| nf-security-ubuntu | Wazuh, CyberChef | On demand |

## Networking

- Pi-hole handles DNS for all internal VMs
- All services accessible via .nerdfolio hostnames
- NPM routes by hostname to correct container/VM
- Wildcard self-signed cert applied to all proxy hosts
- Pi-hole local DNS records for all .nerdfolio hostnames
- Windows hosts file maps .nerdfolio to 192.168.100.20

## Decisions Made

**SQLite for utilities stack**
Gitea and Vaultwarden use SQLite. Light use, no shared DB needed.
MariaDB reserved for FiveM/RedM in Phase 6.

**Wazuh official docker deployment**
Custom compose failed — Wazuh requires specific network aliases and
initialization containers. Official single-node deployment used instead.

**Kasm manual install**
Kasm installer generates random credentials printed to stdout.
Ansible non-interactive flag works but credentials must be captured
manually. Install script at /tmp/kasm_release/install.sh.

**Self-signed wildcard cert**
Generated via openssl, imported into NPM as custom certificate.
Applied to all proxy hosts. Browsers warn once then work normally.

**systemd-resolved disabled on all VMs**
Ubuntu 26.04 binds port 53 by default. Disabled to allow Pi-hole
to bind port 53 for DNS. Added to base hardening playbook.

## Up Next

Phase 4 — PowerShell Module. Existing scripts get a real home.
