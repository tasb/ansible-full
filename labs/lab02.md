# Lab 02 - Creating a Static YAML Inventory with Group Variables in Ansible

## Contents

- [Objective](#objective)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 1: Create the Inventory File](#step-1-create-the-inventory-file)
  - [Step 2: Test Inventory File](#step-2-test-inventory-file)
  - [Step 3: Run a Simple Ansible Command](#step-3-run-a-simple-ansible-command)
  - [Step 4: Create Group Variables](#step-4-create-group-variables)
  - [Step 5: Test Group Variables](#step-5-test-group-variables)
- [Conclusion](#conclusion)

## Objective

Create an Ansible static inventory file in YAML format that categorizes two servers into webserver and db groups and define some example group variables for these groups.

## Prerequisites

- [ ] Create a folder named `lab02` inside `ansible-labs`
- [ ] Navigate to `lab02` folder
- [ ] Finish [Lab 01](lab02.md) to ensure you have access to managed nodes
- [ ] Copy the `ansible.cfg` file from `lab01` folder to `lab02` folder

## Guide

### Step 1: Create the Inventory File

Create a folder named `inventory` inside `lab02` folder.

Inside the `inventory` folder, create a file named `inventory.yml`.

Add the following content to the file:

```yaml
webserver:
  hosts:
    servidor-0:
      ansible_host: 10.0.3.100
db:
  hosts:
    servidor-1:
      ansible_host: 10.0.3.101
```

### Step 2: Test Inventory File

Test your inventory file using the `ansible-inventory` command:

```bash
ansible-inventory -i inventory/inventory.yml --list
```

This will display your inventory in a JSON format, showing the groups, hosts, and variables.

### Step 3: Run a Simple Ansible Command

To test, run a simple Ansible command like ping:

```bash
ansible -i inventory/inventory.yml all -m ping
```

This will ping both servers in your inventory. You should see output similar to the following:

```bash
servidor-0 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
servidor-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Now let's try to run a command on a specific group. Run the following command:

```bash
ansible -i inventory/inventory.yml webserver -m command -a "hostname"
```

You should see output similar to the following:

```bash
servidor-0 | CHANGED | rc=0 >>
servidor-0
```

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
