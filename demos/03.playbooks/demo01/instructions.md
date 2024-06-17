# Demo: Run playbook

## Dry-run playbook for dev env

```bash
ansible-playbook -i inventory/dev  --check  webserver.yml
```

## Run playbook on dev env

```bash
ansible-playbook -i inventory/dev  webserver.yml
```

## Re-run playbook on dev env

```bash
ansible-playbook -i inventory/dev  webserver.yml
```

## Dry-run playbook for prod env

```bash
ansible-playbook -i inventory/prod  --check  webserver.yml
```

## Run playbook on prod env

```bash
ansible-playbook -i inventory/prod  webserver.yml
```

## Re-run playbook on prod env

```bash
ansible-playbook -i inventory/prod  webserver.yml
```

## Display inventory in graph for all envs

```bash
ansible-inventory -i inventory --graph
```

## Display inventory in list for all envs

```bash
ansible-inventory -i inventory --list
```

## Run cleanup playbook on all envs

```bash
ansible-playbook -i inventory  webserver-clean.yml
```
