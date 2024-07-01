# Lab 01 - Run Ad-Hoc Commands

## Contents

- [Goals](#goals)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 1: Create Azure VMs for Control Node](#step-1-create-azure-vms-for-control-node)
  - [Step 2: Create Azure VMs for Managed Nodes](#step-2-create-azure-vms-for-managed-nodes)
  - [Step 3: Install Ansible](#step-3-install-ansible)
  - [Step 4: Configure access to managed nodes](#step-4-configure-access-to-managed-nodes)
  - [Step 5: Verify python installation](#step-5-verify-python-installation)
  - [Step 6: Create an inventory file for the managed node](#step-6-create-an-inventory-file-for-the-managed-node)
  - [Step 7: Run an Ansible ad-hoc command on the managed node](#step-7-run-an-ansible-ad-hoc-command-on-the-managed-node)
  - [Step 8: Copy file to managed nodes](#step-8-copy-file-to-managed-nodes)
  - [Step 9: Run more commands on managed nodes](#step-9-run-more-commands-on-managed-nodes)
  - [Step 10: Install a package on the managed node](#step-10-install-a-package-on-the-managed-node)
- [Conclusion](#conclusion)

## Goals

- Create Azure VMs for Control Node
- Create Azure VMs for Managed Nodes
- Install Ansible
- Configure access to managed nodes
- Verify python installation
- Create an inventory file for the managed node
- Run Ansible ad-hoc commands on the managed node

## Prerequisites

- [ ] Have access to Azure Subscription

## Guide

### Step 1: Create Azure VMs for Control Node

For all resources created in this lab, you should use a prefix to identify the resources. This prefix should be unique within the Azure subscription.

The prefix should be the first letter of your first name and full last name. For example, in my case `Tiago Bernardo`, the prefix would be `tbernardo`.

On the following instructions, replace `<your-prefix>` with the prefix you defined.

All resources in Azure needs to be created in a Resource Group. Navigate to the [Azure Portal](https://portal.azure.com/#create/Microsoft.ResourceGroup) and create a new Resource Group with the following configurations:

- **Name**: `<your-prefix>-ansible-lab`
- **Region**: `West Europe`

Navigate to the [Azure Portal](https://portal.azure.com/#browse/Microsoft.Compute%2FVirtualMachines) and create 1 virtual machine with the following configurations:

- **Resource Group**: `<your-prefix>-ansible-lab`
- **Region**: `West Europe`
- **Virtual Machine Name**: `<your-prefix>-control-node`
- **Availability options**: `No infrastructure redundancy required`
- **Image**: `Ubuntu Server 20.04 LTS`
- **Size**: `Standard_D2s_v3`
- **Username**: `azureuser`

All the other configurations can be left as default.

Click on `Review + create` and then `Create`.

You should see a pop-up for you to download the private key. Download it and save it in a secure location.

After the deployment is completed, you should see the public IP address of the virtual machine. Save it for future reference.

### Step 2: Create Azure VMs for Managed Nodes

Now you need to create the managed nodes.

Please create 2 virtual machines using the same configurations as the control node, but using the following names: `<your-prefix>-server-1` and `<your-prefix>-server-2`.

You need to go to the `Networking` tab and select the previously create virtual network. This will ensure that all virtual machines are in the same network.

On the dropdown, you need to select the virtual network that starts with `<your-prefix>`.

You should remove the public IP address from the managed nodes. You should only have a public IP address on the control node.

Again, you need to download the private key for each VM and save it in a secure location.

After the deployment is completed, you should keep the private IP address of the virtual machines. Save it for future reference.

### Step 3: Install Ansible

Now you need to install Ansible on the control node.

First, SSH into the control node using the following command:

```bash
ssh -i <path-to-control-node-private-key> azureuser@<control-node-public-ip>
```

You should replace `<path-to-control-node-private-key>` with the path to the private key you downloaded and `<control-node-public-ip>` with the public IP address of the control node.

You may get an error message saying that the permissions of the private key are too open. You can fix this by running the following command:

```bash
chmod 400 <path-to-control-node-private-key>
```

If you are in a Windows machine, you can use [PuTTY](https://www.putty.org/) to connect to the VM.

After login into the control node, run the following commands to install Ansible:

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

After the installation is completed, you can check the version of Ansible by running the following command:

```bash
ansible --version
```

### Step 4: Configure access to managed nodes

Now you need to configure access to the managed nodes.

First, you need to copy the private key to the control node. You can use the following command to copy the private key to the control node:

```bash
scp -i <path-to-control-node-private-key> <path-to-managed-node-private-key> azureuser@<control-node-public-ip>:~/.ssh/
```

If you are in a Windows machine, you can use [WinSCP](https://winscp.net/eng/index.php) to copy the file. Or, on a more "traditional" way, you can copy+paste the content of the private key to a new file in the control node.

You should replace `<path-to-managed-node-private-key>` with the path to the private key of the managed nodes.

After copying the private key, you need to SSH into the control node and change the permissions of the private key:

```bash
chmod 400 ~/.ssh/<managed-node-private-key>
```

Let's test the connection to the managed nodes. Run the following command to SSH into the managed nodes:

```bash
ssh -i ~/.ssh/<managed-node-private-key> azureuser@<managed-node-private-ip>
```

Repeat this process for all managed nodes.

### Step 5: Verify python installation

You need to have Python on the managed nodes, which is required by Ansible to run commands on the managed node.

The installed version of Ubuntu 20.04 should come with Python 3 installed by default but let's confirm it.

Use the same process on step 4 to SSH into the managed nodes and run the following command:

```bash
python3 --version
```

You should see the output similar to the following:

```plaintext
Python 3.8.10
```

### Step 6: Create an inventory file for the managed node

Create a folder named `ansible` in the home directory of the `azureuser` user on the control node.

Create a file named `inventory.yml` inside that folder with the following content:

```yaml
nodes:
  hosts:
    server1:
      ansible_host: <server-1-private-ip>
      ansible_user: azureuser
      ansible_ssh_private_key_file: /home/azureuser/.ssh/<private-key-server1>
    server2:
      ansible_host: <server-2-private-ip>
      ansible_user: azureuser
      ansible_ssh_private_key_file: /home/azureuser/.ssh/<private-key-server2>
```

Please replace all the placeholders with the correct values.

This inventory file contains the details of the managed nodes, which is required by Ansible to connect to the managed node.

### Step 7: Run an Ansible ad-hoc command on the managed node

Run the following command to test the connection between the control node and the managed node:

```bash
cd ~/ansible/
ansible -i inventory.yml nodes -m ansible.builtin.ping
```

You should see the output similar to the following:

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

### Step 8: Copy file to managed nodes

To copy a file, you need to create a file first.

Run the following command to create a file named `hello.txt` in `/tmp` on the control node:

```bash
echo "Hello World" > /tmp/hello.txt
```

Then, run the following command to copy the previous created file to `/tmp` on all nodes:

```bash
ansible -i inventory.yml all -m ansible.builtin.copy -a "src=/tmp/hello.txt dest=/tmp/"
```

You should see output similar to the following:

```bash
server1 | CHANGED => {
    "changed": true,
    "checksum": "d41d8cd98f00b204e9800998ecf8427e",
    "dest": "/tmp/hello.txt",
    "gid": 0,
    "group": "root",
    "md5sum": "d41d8cd98f00b204e9800998ecf8427e",
    "mode": "0644",
    "owner": "root",
    "size": 0,
    "src": "/home/lab-admin/.ansible/tmp/ansible-tmp-1648530733.3-1-1234/AnsiballZ_copy.py",
    "state": "file",
    "uid": 0
}
```

### Step 9: Run more commands on managed nodes

Run the following command to list `/tmp` folder on all nodes:

```bash
ansible -i inventory.yml all -m ansible.builtin.shell -a "ls /tmp"
```

You should see output similar to the following:

```bash
server1 | CHANGED | rc=0 >>
hello.txt
...
```

Let's check if the file was copied correctly:

```bash
ansible -i inventory.yml all -m ansible.builtin.shell -a "cat /tmp/hello.txt"
```

You should see output similar to the following:

```bash
server1 | CHANGED | rc=0 >>
Hello World
```

### Step 10: Install a package on the managed node

Next, let's run an ad-hoc command to install a package on the managed node.

Run the following command:

```bash
ansible -i inventory.yml nodes -m ansible.builtin.apt -a "name=nginx state=present" --become
```

After install the package, you can run the following command to verify the status of the `nginx` service:

```bash
ansible -i inventory.yml nodes -m ansible.builtin.service -a "name=nginx state=started" --become
```

Now, let's use `curl` to check if the service is running. Run the following command:

```bash
curl http://<server-1-private-ip>
curl http://<server-2-private-ip>
```

Please replace `<server-1-private-ip>` and `<server-2-private-ip>` with the private IP address of the managed nodes.

### Step 11: Stop the VMs

At the end of all labs, you should stop the VMs to avoid unnecessary costs.

Go to the Azure Portal and stop all VMs created in this lab.

## Conclusion

In this lab you created all the necessary resources to run Ansible commands on managed nodes. You also tested the connection between the control node and the managed nodes and ran some ad-hoc commands.
