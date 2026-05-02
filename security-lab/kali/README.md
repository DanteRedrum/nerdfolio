# Kali

## Kali Attack VM (nf-kali)

Full Kali Linux installation on vSwitch-Isolated.
Used for attacking vulnerable VMs in the lab.

### Provisioning

```bash
cd ~/nerdfolio/ansible
ansible-playbook -i inventory/hosts.ini \
  ../security-lab/playbooks/provision-kali.yml
```

Then attach the Kali ISO and install manually — same process
as other lab VMs. Use the latest Kali ISO from:
https://www.kali.org/get-kali/#kali-installer-images

### Network Config

Static IP on vSwitch-Isolated:

Address: 10.10.10.10
Netmask: 255.255.255.0
Gateway: none
DNS: none

No internet access by default. To update tools temporarily:
1. Shut down vulnerable VMs
2. Move nf-kali NIC to vSwitch-External
3. Update: `sudo apt update && sudo apt upgrade`
4. Move NIC back to vSwitch-Isolated

### Essential Tools (pre-installed in Kali)

- nmap, netdiscover
- gobuster, nikto, dirb
- metasploit
- burpsuite
- john, hashcat
- searchsploit
- enum4linux
- smbclient

### Additional Tools to Install

```bash
sudo apt install -y feroxbuster seclists
```

## Kasm Kali Workspace (Phishing Sandbox)

Kali running as a Kasm workspace on nf-kasm-ubuntu.
Used for safely opening suspicious links and attachments.

### Setup

1. Log into Kasm at https://192.168.100.40
2. Go to Workspaces → Add Workspace
3. Select Kali Linux from the registry
4. Launch a session when needed
5. Session is destroyed after use — nothing persists

### Use Cases

- Opening phishing email links
- Downloading and analyzing suspicious attachments
- Browsing unknown URLs
- Testing suspicious executables in an isolated environment