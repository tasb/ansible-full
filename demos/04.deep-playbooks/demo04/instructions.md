# Handlers

## Run first time

```bash
ansible-playbook -i ../inventory/prod handlers.yml
```

Check Handler3 runs at the end

## Run with changed_when

Uncomment `changed_when: true` in `handlers.yml`

```bash
ansible-playbook -i ../inventory/prod  handlers.yml
```

Check all handlers run at the end. Point out Handler2 runs with listen

## Force handlers execution

Uncomment `- meta: flush_handlers` in `handlers.yml`

```bash
ansible-playbook -i ../inventory/prod  handlers.yml
```

Check all handlers unless Handler3 run after the meta task
