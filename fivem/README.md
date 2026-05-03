# FiveM Server

QBCore-based FiveM server provisioned via Ansible.
Infrastructure as code applied to a game server.

## Stack

| Component | Detail |
|---|---|
| VM | nf-fivem-ubuntu — 192.168.100.60 |
| FiveM | Latest artifact via txAdmin |
| Framework | QBCore |
| Database | MariaDB via Docker |
| Node.js | Required by txAdmin |

## Structure

    fivem/
	server-data/      Server config and resources — version controlled
	ansible/          Provisioning playbooks
	docker/           MariaDB compose file

## Ports

| Port | Purpose |
|---|---|
| 30120 | FiveM game port (TCP/UDP) |
| 40120 | txAdmin web panel |
| 3306 | MariaDB (internal only) |

## Quick Start

```bash
# Provision from scratch
ansible-playbook -i ansible/inventory/hosts.ini fivem/ansible/deploy-fivem.yml

# Start MariaDB
ansible-playbook -i ansible/inventory/hosts.ini fivem/ansible/start-db.yml
```
