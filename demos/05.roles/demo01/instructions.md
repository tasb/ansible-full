# Use role on a playbook

## Run the playbook

```bash
ansible-playbook -i ../inventory/dev playbook.yml
```

- You should get an error message because the role is not defined yet.

## Install the role

- Show requirements.yml file

```bash
ansible-galaxy install -r requirements.yml
```

## Run the playbook again

```bash
ansible-playbook -i ../inventory/dev playbook.yml
```

- Discuss about the huge amount of tasks run by the role.

## Review playbook to discuss option on vars definition

- Global vars
- Role vars
- Vars using a file
