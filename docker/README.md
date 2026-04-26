# Docker

The living layer of Nerdfolio. Services are organized by function across
dedicated VMs. On-demand VMs are started and stopped via Ansible.

## VM Assignment

| VM | Stack | Always On |
|---|---|---|
| `nf-docker-ubuntu` | Core, Utilities | Yes |
| `nf-ai-ubuntu` | Ollama, Open WebUI | On demand |
| `nf-kasm-ubuntu` | Kasm remote desktop | On demand |
| `nf-security-ubuntu` | Wazuh, Greenbone, CyberChef | On demand |

## Stacks

| Stack | Services |
|---|---|
| Core | Portainer, Pi-hole, Nginx Proxy Manager, Uptime Kuma |
| AI | Ollama, Open WebUI |
| Security | Wazuh, CyberChef, Greenbone/OpenVAS |
| Utilities | Vaultwarden, Gitea, Code Server, Dashy, Stirling PDF |

## Secrets

`.env` files are gitignored. `.env.example` files show structure without
values. After cloning, copy the example files and fill in real values:

    cp docker/env/core.env.example docker/env/core.env

## On-Demand VM Workflow

    # Start a VM
    ansible-playbook ansible/playbooks/vm-start.yml -e "vm_name=nf-ai-ubuntu"

    # Stop a VM
    ansible-playbook ansible/playbooks/vm-stop.yml -e "vm_name=nf-ai-ubuntu"

## FiveM / RedM

Game server containers are Phase 6. Placeholder only — these require
database backends and persistent file access that make containers
inappropriate for anything beyond throwaway dev. Full treatment in Phase 6.
