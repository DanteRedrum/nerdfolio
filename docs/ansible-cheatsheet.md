# Ansible Cheat Sheet

All commands run from `~/nerdfolio/ansible/`

---

## VM Lifecycle

### Provision a new VM
```bash
ansible-playbook -i inventory/hosts.ini playbooks/hyperv-provision-vm.yml \
  -e "vm_name=nf-ROLE-ubuntu" \
  -e "vm_ram=BYTES" \
  -e "vm_disk_size=BYTES" \
  -e "vm_cpu=COUNT"
```

**Common RAM values:**
| GB | Bytes |
|---|---|
| 2GB | 2147483648 |
| 4GB | 4294967296 |
| 8GB | 8589934592 |
| 12GB | 12884901888 |
| 16GB | 17179869184 |

**Common disk values:**
| Size | Bytes |
|---|---|
| 40GB | 42949672960 |
| 60GB | 64424509440 |
| 100GB | 107374182400 |

### Attach ISO to VM
```bash
ansible-playbook -i inventory/hosts.ini playbooks/hyperv-attach-iso.yml \
  -e "vm_name=nf-ROLE-ubuntu"
```

### Start a VM
```bash
ansible-playbook -i inventory/hosts.ini playbooks/vm-start.yml \
  -e "vm_name=nf-ROLE-ubuntu"
```

### Stop a VM
```bash
ansible-playbook -i inventory/hosts.ini playbooks/vm-stop.yml \
  -e "vm_name=nf-ROLE-ubuntu"
```

### Remove a VM
```bash
ansible-playbook -i inventory/hosts.ini playbooks/hyperv-remove-vm.yml \
  -e "vm_name=nf-ROLE-ubuntu"
```

---

## Configuration

### Run base hardening on a VM
```bash
ansible-playbook -i inventory/hosts.ini playbooks/base-hardening.yml \
  --limit nf-ROLE-ubuntu
```

### Run base hardening on all lab VMs
```bash
ansible-playbook -i inventory/hosts.ini playbooks/base-hardening.yml \
  --limit lab
```

---

## Inventory

### List all hosts
```bash
ansible all -i inventory/hosts.ini --list-hosts
```

### Ping all lab VMs
```bash
ansible lab -i inventory/hosts.ini -m ping
```

### Ping Windows host
```bash
ansible windows -i inventory/hosts.ini -m ansible.windows.win_ping
```

### Ping all hosts
```bash
ansible all -i inventory/hosts.ini -m ping
```

---

## Vault

### Edit vault file
```bash
ansible-vault edit inventory/group_vars/windows/vault.yml
```

### View vault file
```bash
ansible-vault view inventory/group_vars/windows/vault.yml
```

### Encrypt a file
```bash
ansible-vault encrypt path/to/file.yml
```

---

## New VM Checklist

After provisioning and installing Ubuntu:

1. Switch NIC to vSwitch-Internal in Hyper-V Manager
2. Fix netplan — assign static IP in 192.168.100.0/24 range:
```bash
   sudo nano /etc/netplan/00-installer-config.yaml
```
   Set contents to:
```yaml
   network:
     version: 2
     ethernets:
       eth0:
         dhcp4: false
         dhcp6: false
         addresses:
           - 192.168.100.XX/24
         routes:
           - to: default
             via: 192.168.100.1
         nameservers:
           addresses: [8.8.8.8, 8.8.4.4]
```
   Then apply:
```bash
   sudo netplan apply
```
3. Set up passwordless sudo:
```bash
   echo "daniel ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/daniel
```
4. Copy SSH key from Ansible VM:
```bash
   ssh-copy-id daniel@192.168.100.XX
```
5. Add to inventory/hosts.ini under [lab]
6. Run hardening playbook:
```bash
   ansible-playbook -i inventory/hosts.ini playbooks/base-hardening.yml --limit nf-ROLE-ubuntu
```

---

## IP Address Assignments

| VM | IP |
|---|---|
| Windows Host | 192.168.100.1 |
| nf-ansible-ubuntu | 192.168.100.10 |
| nf-docker-ubuntu | 192.168.100.20 |
| nf-ai-ubuntu | 192.168.100.30 |
| nf-kasm-ubuntu | 192.168.100.40 |
| nf-security-ubuntu | 192.168.100.50 |
