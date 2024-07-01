# Demo: Run playbook

## Dry-run playbook for dev env

```bash
ansible-playbook -i inventory/hosts.yml  --check  webserver.yml
```

## Run playbook on dev env

```bash
ansible-playbook -i inventory  webserver.yml
```

## Re-run playbook on dev env

```bash
ansible-playbook -i inventory  webserver.yml
```

## Run cleanup playbook on all envs

```bash
ansible-playbook -i inventory  webserver-clean.yml
```
