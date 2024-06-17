# Error Handling

## Run playbook and check first task fails

```bash
ansible-playbook -i ../inventory error-handling.yml
```

## Ignore error on first task

1. Uncomment `ignore_errors: yes` in `error_handling.yml`
2. Run playbook again

```bash
ansible-playbook -i ../inventory error-handling.yml
```

## Check unreachable host behavior

1. Check how unreachable host behaves
2. Uncomment `ignore_unreachable: yes` in `error_handling.yml`
3. Run playbook again

```bash
ansible-playbook -i ../inventory error-handling.yml
```

## Check behavior when stat module fails

1. Run playbook again

```bash
ansible-playbook -i ../inventory error-handling.yml
```

## Check how any_errors_fatal works

1. Uncomment `any_errors_fatal: yes` in `error_handling.yml`
2. Run playbook again

```bash
ansible-playbook -i ../inventory error-handling.yml
```
