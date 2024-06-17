# Ansible Tags

## Run the playbook

```bash
ansible-playbook -i ../inventory/dev tags.yml
```

## Run only task1

```bash
ansible-playbook -i ../inventory/dev tags.yml --tags task1
```

## Run only task2

```bash
ansible-playbook -i ../inventory/dev tags.yml --tags task2
```

## Run with not existing task3

```bash
ansible-playbook -i ../inventory/dev tags.yml --tags task3
```

## Run task1 and task2

```bash
ansible-playbook -i ../inventory/dev tags.yml --tags task1,task2
```

## Run all tasks except task2

```bash
ansible-playbook -i ../inventory/dev tags.yml --skip-tags task2
```
