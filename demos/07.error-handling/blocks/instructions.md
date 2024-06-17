# Blocks

## Run playbook with block

```bash
ansible-playbook -i ../inventory blocks.yml
```

Check that the task and the playbook failed

## Run playbook with block and rescue

1. Uncomment `failed_when: true` block in `blocks.yml`
2. Run playbook again

```bash
ansible-playbook -i ../inventory blocks.yml
```
