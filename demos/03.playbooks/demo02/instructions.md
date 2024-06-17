# Demo: Run playbook

## Run playbook on dev env with invalid host

```bash
ansible-playbook -i inventory/dev webserver.yml
```

## Run playbook on dev env with valid hosts

```bash
ansible-playbook -i inventory/dev -l webserver webserver.yml
```

## Re-run playbook on dev env

```bash
ansible-playbook -i inventory/dev -l webserver webserver.yml
```

## Run cleanup playbook on all envs

```bash
ansible-playbook -i inventory  webserver-clean.yml
```
