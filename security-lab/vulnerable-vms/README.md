# Vulnerable VMs

Downloaded from VulnHub — https://www.vulnhub.com

## Conversion Process

VulnHub VMs are distributed as OVA files built for VMware/VirtualBox.
They must be converted to VHDX for Hyper-V.

### Tools Needed

Download StarWind V2V Converter (free):
https://www.starwindsoftware.com/starwind-v2v-converter

### Steps

1. Download OVA from VulnHub
2. Rename .ova to .tar and extract — contains a .vmdk file
3. Open StarWind V2V Converter
4. Source: Local file — select the .vmdk
5. Destination: Local file — VHDX, fixed size
6. Save to: `D:\Hyper-V\Virtual Hard Disks\`
7. Run conversion

### Deploy via Ansible

```bash
cd ~/nerdfolio/ansible
ansible-playbook -i inventory/hosts.ini \
  ../security-lab/playbooks/provision-vulnvm.yml \
  -e "vm_name=kioptrix-1" \
  -e "vm_vhd_path=D:\\Hyper-V\\Virtual Hard Disks\\kioptrix-1.vhdx" \
  -e "vm_ram=536870912"
```

### Destroy after session

```bash
ansible-playbook -i inventory/hosts.ini \
  ../security-lab/playbooks/destroy-vulnvm.yml \
  -e "vm_name=kioptrix-1"
```

## Recommended Starting VMs

| Name | Difficulty | Focus | VulnHub URL |
|---|---|---|---|
| Kioptrix Level 1 | Beginner | SMB, Apache | https://www.vulnhub.com/entry/kioptrix-level-1-1,22/ |
| Mr. Robot | Beginner/Int | Web, WordPress | https://www.vulnhub.com/entry/mr-robot-1,151/ |
| DC-1 | Beginner/Int | Drupal, privesc | https://www.vulnhub.com/entry/dc-1,292/ |
| Basic Pentesting 1 | Beginner | Multiple | https://www.vulnhub.com/entry/basic-pentesting-1,216/ |

## Notes

- Generation 1 VMs for VulnHub boxes — most were built for older hypervisors
- Secure Boot must be disabled for Gen 1 VMs
- All VMs connect to vSwitch-Isolated only
- Never attach a vulnerable VM to vSwitch-External or vSwitch-Internal

## Known Issues

### DHCP on vSwitch-Isolated
Older VulnHub VMs (particularly Kioptrix Level 1) may not obtain
a DHCP lease from dnsmasq on the isolated network. Possible causes:

- Legacy network adapter type incompatible with Hyper-V Gen 1
- Old DHCP client not compatible with dnsmasq

**Workarounds to investigate:**
- Change VM network adapter type in Hyper-V settings
- Boot Kioptrix and manually check what network adapter is configured
- Try assigning a static IP via the VM console
- Use nmap ARP scan to find self-assigned APIPA addresses
