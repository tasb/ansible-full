# Run Ansible in Windows

## Install IIS

```bash
ansible-playbook -i inventory iis.yml -k
```

## Install notepad++

```bash
ansible-playbook -i inventory install-notepad.yml -k
```

## Create user and group

```bash
ansible-playbook -i inventory users-groups.yml --ask-vault-pass -k
```
