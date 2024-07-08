# Demo: Gather facts

## Display facts for all hosts

```bash
ansible-playbook -i ../inventory all ansible_facts.yml
```

## Disable facts gathering for all hosts

Edit ansible_facts.yml and remove comment.

Run playbook again.

```bash
ansible-playbook -i ../inventory all ansible_facts.yml
```
