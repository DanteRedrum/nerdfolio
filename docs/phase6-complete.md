# Phase 6 Complete

## What Was Built

A Qbox FiveM server provisioned via Ansible. Infrastructure as code
applied to a game server. MariaDB runs in Docker, FiveM runs as a
systemd service, everything is reproducible from the playbooks.

## Stack

| Component | Detail |
|---|---|
| VM | nf-fivem-ubuntu — 192.168.100.60 |
| OS | Ubuntu 26.04 LTS |
| FiveM | Artifact 25770 — txAdmin v8.0.1 |
| Framework | Qbox Project |
| Database | MariaDB 10.11 via Docker |
| Server Name | Sunset Paradise |

## Why Qbox over QBCore

Qbox is a modern fork of QBCore with better performance, proper
oxmysql integration, and stricter coding standards. Compatible with
QBCore resources with minor edits. Better foundation for future
script development.

## Ansible Playbooks

| Playbook | Purpose |
|---|---|
| `deploy-fivem.yml` | Install FiveM artifact and configure systemd service |
| `deploy-mariadb.yml` | Deploy MariaDB via Docker Compose |

## Architecture

- FiveM runs as systemd service — starts on boot, restarts on failure
- MariaDB runs as Docker container — persistent volume for data
- txAdmin manages server config, restarts, and resource management
- server-data directory gitignored — contains sensitive config and framework code
- server.cfg.example committed — shows structure without sensitive values

## Key Decisions

**Qbox over QBCore** — Modern architecture, better performance,
same DNA as QBCore so existing knowledge transfers.

**MariaDB in Docker** — Keeps database portable and consistent.
Independent lifecycle from the FiveM process.

**systemd service** — Auto-restart on failure, starts on boot,
logs via journalctl.

**server-data gitignored** — Contains license keys, database
passwords, and generated framework files. Ansible recreates
the environment, not the files themselves.

**TXHOST env vars** — Updated from deprecated ConVars to proper
environment variable configuration per txAdmin v8 requirements.

## Known Issues

**GTA V Enhanced incompatible** — FiveM requires GTA V Legacy.
Enhanced support is on the FiveM roadmap but not available yet.

**Public server list unreachable** — Home router has no port
forwarding configured. Server is local-only. Expected behavior
for a dev server.

## Connecting

FiveM client → Direct Connect → 192.168.100.60:30120

## Management

```bash
# View logs
sudo journalctl -u fivem -f

# Restart server
sudo systemctl restart fivem

# Stop server
sudo systemctl stop fivem

# txAdmin panel
http://192.168.100.60:40120
```

## Up Next

Phase 7 — FreeCAD and the physical layer.
