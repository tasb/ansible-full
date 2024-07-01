# Lab 02 - YAML Inventory with Group and Host Variables in Ansible

## Contents

- [Goals](#goals)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 1: Test Inventory File](#step-1-test-inventory-file)
  - [Step 2: Run a Simple Ansible Command](#step-2-run-a-simple-ansible-command)
  - [Step 3: Create new groups on inventory file](#step-3-create-new-groups-on-inventory-file)
  - [Step 4: Change IP address on inventory file](#step-4-change-ip-address-on-inventory-file)
  - [Step 5: Create Group Variables](#step-5-create-group-variables)
  - [Step 6: Test Group Variables](#step-6-test-group-variables)
  - [Step 7: Create Host Variables](#step-7-create-host-variables)
- [Conclusion](#conclusion)

## Goals

- Create a static YAML inventory file
- Add new groups to the inventory file
- Change IP address on inventory file
- Create group variables
- Create host variables

## Prerequisites

- [ ] Navigate to `ansible` folder inside your home folder on control node
- [ ] Finish [Lab 01](lab01.md) to ensure you have access to managed nodes

## Guide

### Step 1: Test Inventory File

First, create an `inventory` directory and copy your inventory file to it:

```bash
mkdir inventory
mv inventory.yml inventory/hosts.yml
```

Test your inventory file using the `ansible-inventory` command:

```bash
ansible-inventory -i inventory/hosts.yml --list
```

This will display your inventory in a JSON format, showing the groups, hosts, and variables.

### Step 2: Run a Simple Ansible Command

To test, run a simple Ansible command like ping:

```bash
ansible -i inventory/hosts.yml all -m ansible.builtin.ping
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
ansible -i inventory/hosts.yml nodes -m ansible.builtin.command -a "hostname"
```

You should see output similar to the following:

```bash
server-1 | CHANGED | rc=0 >>
```

### Step 3: Create new groups on inventory file

Edit the `hosts.yml` file and add the following content at the end of the file:

```yaml
webserver:
  hosts:
    server1:
db:
  hosts:
    server2:
```

Now let's try to run a command on the other group. Run the following command:

```bash
ansible -i inventory/hosts.yml db -m ansible.builtin.command -a "hostname"
```

You should see output similar to the following:

```bash
server-2 | CHANGED | rc=0 >>
server-2
```

Finally let's try to run on a specific host. Run the following command:

```bash
ansible -i inventory/hosts.yml server1 -m ansible.builtin.command -a "hostname"
```

### Step 4: Change IP address on inventory file

Since you've your servers on same Virtual Network as your Control Node, you can change the IP address on the inventory file to the private IP address of the servers.

Edit the `hosts.yml` file and change the IP address of the servers to the private IP address of the servers.

You can get the private IP address of the servers on Azure Portal.

### Step 5: Create Group Variables

Create one directory named `group_vars` inside `inventory` folder.

Inside the `group_vars` folder, create a file named `all.yml` and add the following content:

```yaml
ansible_user: azureuser
```

On main `hosts.yml` file, remove `ansible_user: azureuser` from both servers.

### Step 6: Test Group Variables

Test your inventory file using the `ansible-inventory` command:

```bash
ansible-inventory -i inventory/hosts.yml --list
```

Now run an ansible command to check if you still can ping the servers:

```bash
ansible -i inventory/hosts.yml all -m ansible.builtin.ping
```

You should see output similar to the following:

```plaintext
server1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
server2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### Step 7: Create Host Variables

Create one directory named `host_vars` inside `inventory` folder.

Create a file named `server1.yml` inside `host_vars` folder and add the following content:

```yaml
ansible_ssh_private_key_file: /home/azureuser/.ssh/<private-key-server1>
```

Create a file named `server2.yml` inside `host_vars` folder and add the following content:

```yaml
ansible_ssh_private_key_file: /home/azureuser/.ssh/<private-key-server2>
```

You should delete those variables from the `hosts.yml` file.

Let's test if the host variables are working. Run the following command:

```bash
ansible -i inventory/hosts.yml all -m ansible.builtin.ping
```

### Conclusion

You've successfully created a static YAML inventory with group and host variables in Ansible.
