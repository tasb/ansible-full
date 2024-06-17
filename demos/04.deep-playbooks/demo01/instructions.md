# Demo: Gather facts

## Display facts for all hosts

```bash
ansible-playbook -i inventory all ansible_facts.yml
```

## Disable facts gathering for all hosts

Edit ansible_facts.yml and remove comment.

Run playbook again.

```bash
ansible-playbook -i inventory all ansible_facts.yml
```

## Customize facts gathering for all hosts

Show files on custom_facts folder.

## Show custom facts for all hosts

```bash
ansible-playbook -i inventory all custom_facts.yml
```

Check you only get static facts.

## Show dynamic custom facts for all hosts

Uncomment fact_path on playbook

```bash
ansible-playbook -i inventory all custom_facts.yml
```
