# group_vars/lab

Variable files for the [lab] inventory group.

## vault.yml

Encrypted credentials — gitignored, must be recreated after cloning.

    ansible-vault create inventory/group_vars/lab/vault.yml

Add the following:

    pihole_password: your_pihole_password
    npm_password: your_npm_password
