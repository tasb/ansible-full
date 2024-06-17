# Demo: Conditional and loops

## Run the conditionals playbook

```bash
ansible-playbook -i ../inventory conditionals.yml
```

## Run again to get ok result

```bash
ansible-playbook -i ../inventory conditionals.yml
```

## Run with setting state to absent

```bash
ansible-playbook -i ../inventory conditionals.yml --extra-vars "state=absent"
```

## Run loops playbook

```bash
ansible-playbook -i ../inventory loops.yml
```

## Run loops playbook again to get ok result

```bash
ansible-playbook -i ../inventory loops.yml
```

## Run loops playbook with setting state to absent

```bash
ansible-playbook -i ../inventory loops.yml -e "state=absent"
```

## Run loops_conditionals playbook

```bash
ansible-playbook -i ../inventory loops_conditionals.yml
```

## Run loops_conditionals playbook to get ok result

```bash
ansible-playbook -i ../inventory loops_conditionals.yml
```
