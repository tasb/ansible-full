# Lab 02 - Creating a Static YAML Inventory with Group Variables in Ansible

## Contents



## Objective



## Prerequisites

- [ ] Navigate to `ansible/lab01` folder inside your home folder on control node
- [ ] Finish [Lab 01](lab01.md) to ensure you have access to managed nodes

## Guide

### Step 1: Test Inventory File

Test your inventory file using the `ansible-inventory` command:

```bash
ansible-inventory -i inventory.yml --list
```

This will display your inventory in a JSON format, showing the groups, hosts, and variables.

### Step 2: Run a Simple Ansible Command

To test, run a simple Ansible command like ping:

```bash
ansible -i inventory.yml all -m ansible.builtin.ping
```

This will ping both servers in your inventory. You should see output similar to the following:

```bash
server-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
server-2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Now let's try to run a command on a specific group. Run the following command:

```bash
ansible -i inventory.yml nodes -m command -a "hostname"
```

You should see output similar to the following:

```bash
server-1 | CHANGED | rc=0 >>
```

### Step 3: Create new groups on inventory file

Edit the `inventory.yml` file and add the following content at the end of the file:

```yaml
webserver:
  hosts:
    server1:
db:
  hosts:
    server2:
`

Now let's try to run a command on the other group. Run the following command:

```bash
ansible -i inventory/inventory.yml db -m command -a "hostname"
```

You should see output similar to the following:

```bash
servidor-1 | CHANGED | rc=0 >>
servidor-1
```

Finally let's try to run on a specific host. Run the following command:

```bash
ansible -i inventory/inventory.yml servidor-0 -m command -a "hostname"
```

### Step 4: Create Group Variables

Create one directory named `group_vars` inside `inventory` folder.

Inside the `group_vars` folder, create two files named `webserver.yml` and `db.yml`.

Add the following content to the `webserver.yml` file:

```yaml
http_port: 80
max_clients: 200
```

Add the following content to the `db.yml` file:

```yaml
db_port: 3306
db_name: mydatabase
```

### Step 5: Test Group Variables

Test your inventory file using the `ansible-inventory` command:

```bash
ansible-inventory -i inventory/inventory.yml --list
```

Now run an ansible command to check the variables on `webserver` group:

```bash
ansible -i inventory/inventory.yml webserver -m ansible.builtin.debug -a "var=http_port"
```

You should see output similar to the following:

```bash
servidor-0 | SUCCESS => {
    "http_port": 80
}
```

Now run an ansible command to check the variables on `db` group:

```bash
ansible -i inventory/inventory.yml db -m ansible.builtin.debug -a "var=db_port"
```

### Conclusion

By completing this lab, you will have created a static YAML inventory file for Ansible, categorized two servers into different groups, and defined custom variables for each group.
This setup is fundamental for organizing your managed nodes and configuring them based on their roles in your infrastructure.
