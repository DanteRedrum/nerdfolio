# Philosophy

Nerdfolio exists because documentation is discipline.

The north star: clone this repo and rebuild the entire environment from scratch.
Proxmox, networking, Docker services, FiveM server, security lab — all
provisioned via Ansible. No tribal knowledge. No "I'll remember that."
Everything written down, version controlled, and reproducible.

## Principles

**Nothing gets built manually twice.**
If it's worth doing, it's worth automating. If it's automated, it's documented.

**The repo tells the whole story.**
Not just what was built, but why decisions were made. Architecture docs exist
for future me as much as anyone else.

**Phases overlap intentionally.**
Ansible starts in Phase 2 but never stops. The security lab is Phase 5 but its
isolation requirements are designed in Phase 1. That's not scope creep —
that's thinking ahead.

**Honest over polished.**
This is a living project. Incomplete phases exist. Things break and get fixed.
The commit history is part of the documentation.