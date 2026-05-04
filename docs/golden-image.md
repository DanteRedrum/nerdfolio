# Golden Image — Full Rebuild Guide

Clone the repo and rebuild the entire Nerdfolio environment from scratch.
This document is the test of whether the project is complete.

---

## Prerequisites

Before starting ensure you have:
- Windows 11 machine with Hyper-V available
- At minimum 32GB RAM, 200GB free disk
- GTA V Legacy installed (for FiveM testing)
- FiveM client installed
- StarWind V2V Converter downloaded
- VulnHub VHDX files converted and ready
- CFX license key from keymaster.fivem.net
- Kali Linux ISO downloaded

---

## Overview

| Phase | Method | Time Estimate |
|---|---|---|
| 1. Windows prep | Manual | 15 min |
| 2. Hyper-V setup | Manual | 10 min |
| 3. Ansible VM | Manual + Ansible | 30 min |
| 4. Vault setup | Manual | 5 min |
| 5. Lab VMs | Ansible | 45 min |
| 6. Core services | Ansible | 30 min |
| 7. DNS + Proxy | Ansible | 5 min |
| 8. SSL cert | Manual | 10 min |
| 9. Security lab | Manual + Ansible | 45 min |
| 10. FiveM | Ansible + Manual | 30 min |
| 11. Ollama | Ansible | 20 min |
| 12. Verify | Manual | 15 min |

---

## Step 1 — Windows Preparation

**MANUAL**

Open PowerShell as Administrator:

```powershell
# Enable IP forwarding
Set-NetIPInterface -InterfaceAlias "vEthernet (vSwitch-Internal)" -Forwarding Enabled
Set-NetIPInterface -InterfaceAlias "Ethernet" -Forwarding Enabled

# Configure WinRM
winrm quickconfig
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Create Ansible service account
$password = ConvertTo-SecureString "YOUR_PASSWORD" -AsPlainText -Force
New-LocalUser -Name "ansible" -Password $password -FullName "Ansible Service Account"
Add-LocalGroupMember -Group "Administrators" -Member "ansible"

# Add firewall rule for WinRM
New-NetFirewallRule -DisplayName "WinRM HTTP Internal" -Direction Inbound `
  -Protocol TCP -LocalPort 5985 -Action Allow -Profile Private

# Add Windows hosts file entries
$hosts = @(
    "192.168.100.20`tportainer.nerdfolio",
    "192.168.100.20`tpihole.nerdfolio",
    "192.168.100.20`tnpm.nerdfolio",
    "192.168.100.20`tuptime.nerdfolio",
    "192.168.100.20`tvault.nerdfolio",
    "192.168.100.20`tgit.nerdfolio",
    "192.168.100.20`tcode.nerdfolio",
    "192.168.100.20`tdash.nerdfolio",
    "192.168.100.20`tpdf.nerdfolio",
    "192.168.100.20`tai.nerdfolio",
    "192.168.100.50`twazuh.nerdfolio"
)
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value ($hosts -join "`n")
```

✅ **Verify before continuing:**
- WinRM listener shows on port 5985: `winrm enumerate winrm/config/listener`
- ansible account exists: `Get-LocalUser -Name "ansible"`

---

## Step 2 — Hyper-V Virtual Switches

**MANUAL**

Open Hyper-V Manager → Virtual Switch Manager → Create three switches:

| Name | Type |
|---|---|
| `vSwitch-External` | External — bind to physical NIC |
| `vSwitch-Internal` | Internal |
| `vSwitch-Isolated` | Private |

Configure Hyper-V storage paths:
- Hyper-V Settings → Virtual Hard Disks: `D:\Hyper-V\Virtual Hard Disks`
- Hyper-V Settings → Virtual Machines: `D:\Hyper-V\Virtual Machines`

Create directories:
```powershell
New-Item -ItemType Directory -Path "D:\Hyper-V\Virtual Hard Disks" -Force
New-Item -ItemType Directory -Path "D:\Hyper-V\Virtual Machines" -Force
New-Item -ItemType Directory -Path "E:\Hyper-V\ISOs" -Force
New-Item -ItemType Directory -Path "E:\Hyper-V\Backups" -Force
```

✅ **Verify before continuing:**
- Three switches visible in Virtual Switch Manager
- Storage paths set correctly

---

## Step 3 — Clone Repository and Install Ansible VM

**MANUAL**

1. Clone the repo on Windows:
```powershell
cd C:\Users\YOUR_USER\Documents\GitHub
git clone git@github.com:DanteRedrum/nerdfolio.git
```

2. Provision the Ansible VM via PowerShell:
```powershell
New-VM -Name "nf-ansible-ubuntu" -Generation 2 `
  -MemoryStartupBytes 2147483648 `
  -NewVHDPath "D:\Hyper-V\Virtual Hard Disks\nf-ansible-ubuntu.vhdx" `
  -NewVHDSizeBytes 42949672960 `
  -SwitchName "vSwitch-External"
Set-VMMemory -VMName "nf-ansible-ubuntu" -DynamicMemoryEnabled $false
Set-VMProcessor -VMName "nf-ansible-ubuntu" -Count 2
Set-VMFirmware -VMName "nf-ansible-ubuntu" -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
```

3. Attach Ubuntu ISO:
```powershell
Add-VMDvdDrive -VMName "nf-ansible-ubuntu" `
  -Path "E:\Hyper-V\ISOs\ubuntu-26.04-live-server-amd64.iso"
$dvd = Get-VMDvdDrive -VMName "nf-ansible-ubuntu"
Set-VMFirmware -VMName "nf-ansible-ubuntu" -FirstBootDevice $dvd
```

4. Install Ubuntu with these settings:
   - Hostname: `nf-ansible-ubuntu`
   - Username: `daniel`
   - Install OpenSSH: yes
   - Skip network during install

5. After install — switch NIC to vSwitch-Internal, fix netplan:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      dhcp6: false
      addresses:
        - 192.168.100.10/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
    eth1:
      dhcp4: true
      dhcp6: false
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

6. Add second NIC on vSwitch-External for internet access during setup.

7. Install Ansible and Git:
```bash
sudo apt update
sudo apt install -y ansible git
```

8. Generate SSH key and add to GitHub:
```bash
ssh-keygen -t ed25519 -C "nf-ansible-ubuntu"
cat ~/.ssh/id_ed25519.pub
# Add to GitHub → Settings → SSH Keys
```

9. Clone repo on Ansible VM:
```bash
git clone git@github.com:DanteRedrum/nerdfolio.git ~/nerdfolio
```

10. Set passwordless sudo:
```bash
echo "daniel ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/daniel
```

✅ **Verify before continuing:**
- `ansible --version` returns version
- `git clone` succeeded
- `ping 192.168.100.1` succeeds

---

## Step 4 — Vault Setup

**MANUAL**

```bash
cd ~/nerdfolio/ansible

# Windows host vault
ansible-vault create inventory/group_vars/windows/vault.yml
```

Add:
```yaml
ansible_password: YOUR_ANSIBLE_ACCOUNT_PASSWORD
```

```bash
# Lab services vault
ansible-vault create inventory/group_vars/lab/vault.yml
```

Add:
```yaml
pihole_password: YOUR_PIHOLE_PASSWORD
npm_email: YOUR_NPM_EMAIL
npm_password: YOUR_NPM_PASSWORD
```

Set vault password file:
```bash
echo "YOUR_VAULT_PASSWORD" > ~/.vault_pass
chmod 600 ~/.vault_pass
```

Add to `ansible.cfg`:
```ini
vault_password_file = ~/.vault_pass
```

✅ **Verify before continuing:**
- `ansible windows -i inventory/hosts.ini -m ansible.windows.win_ping` returns pong

---

## Step 5 — Provision Lab VMs

**ANSIBLE**

```bash
cd ~/nerdfolio/ansible

# Provision all lab VMs
ansible-playbook -i inventory/hosts.ini playbooks/hyperv-provision-vm.yml \
  -e "vm_name=nf-docker-ubuntu" -e "vm_ram=17179869184" \
  -e "vm_disk_size=64424509440" -e "vm_cpu=4"

ansible-playbook -i inventory/hosts.ini playbooks/hyperv-provision-vm.yml \
  -e "vm_name=nf-ai-ubuntu" -e "vm_ram=8589934592" \
  -e "vm_disk_size=107374182400" -e "vm_cpu=4"

ansible-playbook -i inventory/hosts.ini playbooks/hyperv-provision-vm.yml \
  -e "vm_name=nf-kasm-ubuntu" -e "vm_ram=8589934592" \
  -e "vm_disk_size=107374182400" -e "vm_cpu=4"

ansible-playbook -i inventory/hosts.ini playbooks/hyperv-provision-vm.yml \
  -e "vm_name=nf-security-ubuntu" -e "vm_ram=17179869184" \
  -e "vm_disk_size=107374182400" -e "vm_cpu=4"

ansible-playbook -i inventory/hosts.ini playbooks/hyperv-provision-vm.yml \
  -e "vm_name=nf-fivem-ubuntu" -e "vm_ram=8589934592" \
  -e "vm_disk_size=107374182400" -e "vm_cpu=4"
```

**MANUAL** — For each VM:
1. Attach Ubuntu ISO: `ansible-playbook playbooks/hyperv-attach-iso.yml -e "vm_name=VM_NAME"`
2. Switch NIC to vSwitch-External during install
3. Install Ubuntu — hostname, username daniel, OpenSSH yes
4. Switch NIC back to vSwitch-Internal
5. Fix netplan with correct static IP (see IP table below)
6. Set passwordless sudo
7. SSH-copy-id from Ansible VM

| VM | IP |
|---|---|
| nf-docker-ubuntu | 192.168.100.20 |
| nf-ai-ubuntu | 192.168.100.30 |
| nf-kasm-ubuntu | 192.168.100.40 |
| nf-security-ubuntu | 192.168.100.50 |
| nf-fivem-ubuntu | 192.168.100.60 |

**ANSIBLE** — After all VMs are accessible:

```bash
# Harden all VMs
ansible-playbook -i inventory/hosts.ini playbooks/base-hardening.yml --limit lab

# Install Docker on all VMs
ansible-playbook -i inventory/hosts.ini playbooks/docker-install.yml -e "target=lab"
```

✅ **Verify before continuing:**
- `ansible lab -i inventory/hosts.ini -m ping` — all return pong

---

## Step 6 — Deploy Core Services

**ANSIBLE**

```bash
# Deploy core stack — Portainer, Pi-hole, NPM, Uptime Kuma
ansible-playbook -i inventory/hosts.ini playbooks/deploy-core-stack.yml

# Deploy utilities stack
ansible-playbook -i inventory/hosts.ini playbooks/deploy-utilities-stack.yml

# Deploy AI stack
ansible-playbook -i inventory/hosts.ini playbooks/deploy-ai-stack.yml

# Deploy MariaDB for FiveM
ansible-playbook -i inventory/hosts.ini ../fivem/ansible/deploy-mariadb.yml

# Deploy FiveM
ansible-playbook -i inventory/hosts.ini ../fivem/ansible/deploy-fivem.yml

# Install Ollama
ansible-playbook -i inventory/hosts.ini playbooks/install-ollama.yml
```

✅ **Verify before continuing:**
- `http://192.168.100.20:9000` — Portainer loads
- `http://192.168.100.20:8080/admin` — Pi-hole loads
- `http://192.168.100.20:81` — NPM loads
- `http://192.168.100.60:40120` — txAdmin loads

---

## Step 7 — Configure DNS and Proxy Hosts

**ANSIBLE**

```bash
# Configure Pi-hole DNS records
ansible-playbook -i inventory/hosts.ini playbooks/configure-pihole-dns.yml

# Configure NPM proxy hosts
ansible-playbook -i inventory/hosts.ini playbooks/configure-npm-proxy-hosts.yml
```

✅ **Verify before continuing:**
- Pi-hole Local DNS shows all 11 records
- NPM shows all 9 proxy hosts

---

## Step 8 — SSL Certificate

**MANUAL**

Generate self-signed wildcard cert on Docker VM:

```bash
ssh daniel@192.168.100.20
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout ~/nerdfolio.key \
  -out ~/nerdfolio.crt \
  -subj "/CN=*.nerdfolio/O=Nerdfolio/C=US"
```

Copy to Windows:
```powershell
scp daniel@192.168.100.20:~/nerdfolio.crt C:\Users\YOUR_USER\Downloads\
scp daniel@192.168.100.20:~/nerdfolio.key C:\Users\YOUR_USER\Downloads\
```

In NPM at `http://192.168.100.20:81`:
1. SSL Certificates → Add SSL Certificate → Custom
2. Upload `nerdfolio.crt` and `nerdfolio.key`
3. Save — note the certificate ID number

Re-run NPM proxy hosts with cert ID:

Update `configure-npm-proxy-hosts.yml` — change `certificate_id: 0` to the actual ID, then:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/configure-npm-proxy-hosts.yml
```

✅ **Verify before continuing:**
- `https://portainer.nerdfolio` loads with SSL

---

## Step 9 — Security Lab

**ANSIBLE**

```bash
# Provision Kali VM
ansible-playbook -i inventory/hosts.ini ../security-lab/playbooks/provision-kali.yml
```

**MANUAL** — Install Kali:
1. Attach Kali ISO:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/hyperv-attach-iso.yml \
  -e "vm_name=nf-kali" \
  -e "iso_path=E:\\Hyper-V\\ISOs\\kali-linux-2026.1-installer-amd64.iso"
```
2. Disable Secure Boot:
```powershell
Set-VMFirmware -VMName "nf-kali" -EnableSecureBoot Off
```
3. Move NIC to External, install Kali, move back to Isolated
4. Set static IP 10.10.10.10
5. Configure dnsmasq for DHCP

**ANSIBLE** — Provision vulnerable VMs:
```bash
ansible-playbook -i inventory/hosts.ini ../security-lab/playbooks/provision-vulnvm.yml \
  -e "vm_name=kioptrix-1" -e "vm_ram=536870912"

ansible-playbook -i inventory/hosts.ini ../security-lab/playbooks/provision-vulnvm.yml \
  -e "vm_name=mr-robot" -e "vm_ram=1073741824"

ansible-playbook -i inventory/hosts.ini ../security-lab/playbooks/provision-vulnvm.yml \
  -e "vm_name=dc-1" -e "vm_ram=536870912"

ansible-playbook -i inventory/hosts.ini ../security-lab/playbooks/provision-vulnvm.yml \
  -e "vm_name=basic-pentesting-1" -e "vm_ram=536870912"
```

Note: VulnHub VHDX files must be in `D:\Hyper-V\Virtual Hard Disks\` before running.

✅ **Verify before continuing:**
- `Get-VMNetworkAdapter -VMName "nf-kali"` shows vSwitch-Isolated
- All four vulnerable VMs show vSwitch-Isolated

---

## Step 10 — FiveM Server

**MANUAL**

1. Access txAdmin at `http://192.168.100.60:40120`
2. Enter PIN from server logs:
```bash
sudo journalctl -u fivem | grep "PIN"
```
3. Complete txAdmin setup wizard:
   - Select Qbox framework
   - Server name: Sunset Paradise
   - Database: `mysql://fivem:DB_PASSWORD@localhost/Qbox_XXXXXX?charset=utf8mb4`
   - License key: your CFX key
4. Grant database permissions if needed:
```bash
ssh daniel@192.168.100.60
docker exec -it fivem-mariadb mariadb -u root -p
GRANT ALL PRIVILEGES ON *.* TO 'fivem'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```
5. Add yourself as admin in server.cfg:
add_principal identifier.fivem:YOUR_FIVEM_ID group.admin

✅ **Verify before continuing:**
- FiveM client connects to `192.168.100.60:30120`
- Can walk around the server

---

## Step 11 — Kasm

**MANUAL**

```bash
ssh daniel@192.168.100.40
sudo bash /tmp/kasm_release/install.sh
```

Note credentials printed at end of install — save to Vaultwarden immediately.

✅ **Verify before continuing:**
- `https://192.168.100.40` loads Kasm login

---

## Step 12 — Final Verification

**MANUAL**

Run through the complete service checklist:

| Service | URL | Expected |
|---|---|---|
| Portainer | https://portainer.nerdfolio | Login page |
| Pi-hole | https://pihole.nerdfolio | Dashboard |
| NPM | http://192.168.100.20:81 | Proxy host list |
| Uptime Kuma | https://uptime.nerdfolio | Status page |
| Vaultwarden | https://vault.nerdfolio | Login page |
| Gitea | https://git.nerdfolio | Git interface |
| Code Server | https://code.nerdfolio | VS Code interface |
| Dashy | https://dash.nerdfolio | Dashboard |
| Stirling PDF | https://pdf.nerdfolio | PDF tools |
| Open WebUI | https://ai.nerdfolio | Chat interface |
| Wazuh | https://192.168.100.50 | Security dashboard |
| Kasm | https://192.168.100.40 | Remote desktop |
| FiveM | 192.168.100.60:30120 | Game server |
| txAdmin | http://192.168.100.60:40120 | Server management |

---

## Known Manual Steps Summary

These steps cannot be automated and must be done manually every rebuild:

1. Hyper-V virtual switch creation
2. Ubuntu OS installation on each VM
3. SSH key generation and GitHub registration
4. Ansible Vault recreation
5. Kali OS installation
6. VulnHub VHDX conversion from downloaded OVA files
7. txAdmin setup wizard — license key and database config
8. SSL certificate generation and NPM upload
9. Kasm installer — credentials are randomly generated
10. Vaultwarden account creation and credential entry
11. FiveM admin identifier in server.cfg

---

## Post-Rebuild Notes

- Change all default passwords immediately
- Save all generated credentials to Vaultwarden
- Pi-hole DNS records are automated — no manual entry needed
- NPM proxy hosts are automated — SSL cert ID must be updated after cert upload
- Uptime Kuma monitors must be re-added manually
- Dashy dashboard config must be restored or reconfigured
