# Author a role

## Bootstrap a role

```bash
index
```

## Review the role structure

- Discuss about the role structure
- Show the different files created

## Update the files

- Use <https://github.com/tasb/ansible-role-tasb-nginx> as reference

## Run the playbook

- Uncomment the role on the playbook

```bash
ansible-playbook -i ../inventory/dev playbook.yml
```

- Explain that you don't need to specify the roles path because it's a default path

## Run again using the var for local index.html

```bash
ansible-playbook -i ../inventory/dev playbook.yml
```

- Check the output with different HTML
