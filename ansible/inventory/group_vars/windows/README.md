# group_vars/windows

This directory contains variable files for the [windows] inventory group.

## Structure

- `vault.yml` — encrypted credentials via Ansible Vault. Never committed to
  the repo. Listed in .gitignore. Must be created locally after cloning.

## After Cloning

This file is not in the repo. To recreate it:

    ansible-vault create group_vars/windows/vault.yml

Add the following variable:

    vault_windows_password: <ansible local account password>

The vault password is stored separately — in a password manager or secure
location. Never in the repo.
