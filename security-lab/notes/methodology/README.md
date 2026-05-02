# Methodology

Standard approach for attacking vulnerable VMs.
Adapt per target — not every step applies every time.

## Phase 1 — Reconnaissance

### Network Discovery
```bash
# Discover target IP
netdiscover -r 10.10.10.0/24
# or
nmap -sn 10.10.10.0/24
```

### Port Scan
```bash
# Fast initial scan
nmap -sV -sC -oN initial.txt TARGET_IP

# Full port scan
nmap -p- -T4 -oN fullports.txt TARGET_IP

# Targeted scan on discovered ports
nmap -p PORT1,PORT2 -sV -sC -oN targeted.txt TARGET_IP
```

### Service Enumeration
```bash
# Web
gobuster dir -u http://TARGET_IP -w /usr/share/wordlists/dirb/common.txt
nikto -h TARGET_IP

# SMB
enum4linux -a TARGET_IP
smbclient -L //TARGET_IP

# FTP
ftp TARGET_IP  # try anonymous login

# SSH
ssh TARGET_IP  # check banner for version
```

## Phase 2 — Vulnerability Assessment

- Search discovered versions on exploit-db.com
- Check searchsploit: `searchsploit SERVICE VERSION`
- Check CVEs for identified software versions
- Look for misconfigurations — weak credentials, anonymous access

## Phase 3 — Exploitation

- Document every command run
- Note what worked AND what didn't
- Keep a copy of any payloads used

## Phase 4 — Post Exploitation

```bash
# Basic system info
whoami
id
uname -a
cat /etc/passwd
cat /etc/os-release

# Network
ifconfig
netstat -tulnp

# Interesting files
find / -perm -4000 2>/dev/null    # SUID files
find / -writable 2>/dev/null      # Writable files
crontab -l                         # Cron jobs
cat /etc/crontab
```

## Phase 5 — Privilege Escalation

Common vectors to check:
- SUID/SGID binaries
- Sudo permissions: `sudo -l`
- Writable cron jobs
- World-writable scripts run by root
- Kernel exploits — `uname -r` then searchsploit
- Password reuse
- Sensitive files in home directories

## Phase 6 — Documentation

Complete the box write-up template in `notes/boxes/`.
Capture flags, commands, and lessons learned.