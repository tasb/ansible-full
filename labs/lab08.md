# Lab 08 - Manage Windows hosts with Ansible

## Table of Contents

- [Objectives](#objectives)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 01: Prepare Control Node](#step-01-prepare-control-node)
  - [Step 03: Create a Windows VM](#step-03-create-a-windows-vm)
  - [Step 04: Confirm your Windows host have WinRM enabled](#step-04-confirm-your-windows-host-have-winrm-enabled)
  - [Step 05: Create a new inventory file](#step-05-create-a-new-inventory-file)
  - [Step 06: Test your connection](#step-06-test-your-connection)
  - [Step 07: Create a playbook](#step-07-create-a-playbook)
- [Conclusion](#conclusion)

## Objectives

- Configure a Windows host to be managed by Ansible
- Create a playbook to install Notepad++ on a Windows host

## Prerequisites

- [ ] Create a folder named `lab09` inside `ansible-labs` on your home directory
- [ ] Navigate to `lab09` folder

## Guide

### Step 01: Prepare Control Node

Before you start, you need to install the following packages:

```bash
sudo apt update
sudo apt install -y python3-pip
pip install "pywinrm>=0.3.0"
```

### Step 03: Create a Windows VM

You can create a Windows VM on your local machine or you can align your efforts with your final project group members and create a Windows VM on the cloud.

After creating the VM, make sure you can access it from your control node and you get the following information:

- IP Address
- Username
- Password

### Step 04: Confirm your Windows host have WinRM enabled

You can confirm if your Windows host has WinRM enabled by running the following command on your Windows host:

```powershell
winrm enumerate winrm/config/Listener
```

You must see an output similar to this:

```powershell
Listener
    Address = *
    Transport = HTTP
    Port = 5985
    Hostname
    Enabled = true
    URLPrefix = wsman
    CertificateThumbprint
    ListeningOn = xxxxxxxxx
```

Don't forget to open the port 5985 to be reachable from your control node. On Azure, you may need to open it on network security group.

## Step 05: Create a new inventory file

Create a new inventory file named `inventory.yml` with the following content:

```yaml
windows:
  hosts:
    windows-server:
      ansible_host: <WINDOWS_IP>
```

Then create a new file named `group_vars/windows.yml` with the following content:

```yaml
ansible_port: 5985
ansible_user: <WINDOWS_USERNAME>
ansible_connection: winrm
ansible_winrm_server_cert_validation: ignore
ansible_winrm_transport: ntlm
ansible_winrm_scheme: http
```

## Step 06: Test your connection

Run the following command to test your connection:

```bash
ansible windows -i inventory.yml -m win_ping -k
```

You need to enter your user password to be able to connect to the Windows host.

You should see an output similar to this:

```bash
<WINDOWS_IP> | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 07: Create a playbook

Create a playbook named `notepad.yml` with the following content:

```yaml
---
- name: Installing Notepad ++
  hosts: server
  gather_facts: true
  tasks:
  - name: Download the Notepad++ installer
    ansible.windows.win_get_url:
        url: https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.9.1/npp.7.9.1.Installer.x64.exe
        dest: C:\npp.7.9.1.Installer.x64.exe

  - name: Execute Installer
    ansible.windows.win_package: 
        path: C:\npp.7.9.1.Installer.x64.exe
        arguments: /S
        state: present
```

Now, find the appropriate command to run the playbook.

## Conclusion

You configured a Windows host to be managed by Ansible and created a playbook to install Notepad++ on it.
