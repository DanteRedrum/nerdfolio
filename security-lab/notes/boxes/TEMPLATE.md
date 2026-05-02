# [Box Name]

**Source:** VulnHub / HTB
**URL:** https://www.vulnhub.com/entry/BOXNAME
**Difficulty:** Beginner / Intermediate / Advanced
**Date:** YYYY-MM-DD
**OS:** Linux / Windows

---

## Summary

One paragraph describing the box and the overall attack path.

---

## Reconnaissance

### Port Scan Results

Paste nmap output here

### Interesting Services

| Port | Service | Version | Notes |
|---|---|---|---|
| 80 | HTTP | Apache 2.x | Default page |
| 22 | SSH | OpenSSH 7.x | |

### Web Enumeration

Paste gobuster/nikto output here

---

## Exploitation

### Vulnerability Identified

**What:** Description of the vulnerability
**Why it works:** Brief explanation
**Reference:** CVE / exploit-db link if applicable

### Steps

```bash
# Exact commands used
```

### Shell Obtained
Paste shell prompt showing whoami/hostname

---

## Privilege Escalation

### Vector Identified

**What:** Description of privesc vector
**Why it works:** Brief explanation

### Steps

```bash
# Exact commands used
```

### Root Obtained
Paste root shell prompt

---

## Flags

| Flag | Value | Location |
|---|---|---|
| User | `flag{...}` | /home/user/user.txt |
| Root | `flag{...}` | /root/root.txt |

---

## Lessons Learned

- What was new or challenging
- Tools or techniques used for the first time
- What you'd do differently

---

## Commands Reference

Quick reference of key commands used in this box.

```bash
# Key commands
```