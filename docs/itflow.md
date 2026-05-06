# ITFlow

## What It Is

ITFlow is a free, open-source MSP platform that consolidates IT documentation,
ticketing, invoicing, and client management into one self-hosted web application.
It is the open-source alternative to ITGlue and Hudu.

Upstream: [itflow-org/itflow](https://github.com/itflow-org/itflow)
Fork (reference): [DanteRedrum/itflow](https://github.com/DanteRedrum/itflow)

---

## Why It's Here

The fork was originally kept as a reference. ITFlow fits naturally into the
Nerdfolio stack as a self-hosted service for organizing client/lab documentation,
tracking assets, and managing any IT work — replacing scattered notes and folders
with a structured system.

---

## Architecture

| Component     | Details                                      |
|---------------|----------------------------------------------|
| Runtime       | Docker Compose                               |
| App image     | `itflow/itflow:latest`                       |
| Database      | MariaDB 10.11 (dedicated, internal network)  |
| Reverse proxy | Nginx (shared `proxy` network)               |
| VM            | Dedicated Ubuntu/Debian VM (not shared)      |

### Network Design

- `itflow_internal` — isolated bridge between ITFlow app and its MariaDB.
  The database is never exposed to the proxy or host network.
- `proxy` — external Docker network shared with Nginx.
  Only the ITFlow app container is attached here.

---

## Deployment

### Prerequisites

- VM provisioned and added to the `[itflow]` inventory group
- `.env` file created from `docker/itflow/.env.example`

### Deploy

```bash
ansible-playbook ansible/playbooks/deploy-itflow.yml -i ansible/inventory/hosts.yml
```

### First Run

On first boot, ITFlow runs a web-based setup wizard at the configured URL.
Complete the wizard to initialize the database and create the admin account.

---

## Files

| Path                                | Purpose                        |
|-------------------------------------|--------------------------------|
| `docker/itflow/docker-compose.yml`  | Service definition             |
| `docker/itflow/.env.example`        | Environment variable template  |
| `ansible/playbooks/deploy-itflow.yml` | VM provisioning + deployment |
| `docs/itflow.md`                    | This file                      |

---

## Maintenance

- **Updates:** Pull latest image and restart — `docker compose pull && docker compose up -d`
- **Backups:** MariaDB volume `itflow_db_data` and `itflow_uploads` should be included in backup rotation
- **Upstream tracking:** The fork is a reference snapshot. For production use, pull updates from `itflow-org/itflow` and review changelog before upgrading
