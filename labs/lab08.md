# Lab 08 - Manage Windows hosts with Ansible

## Table of Contents

- [Objectives](#objectives)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 01: Prepare Control Node](#step-01-prepare-control-node)
  - [Step 02: Create a Windows VM](#step-02-create-a-windows-vm)
  - [Step 03: Confirm your Windows host have WinRM enabled](#step-03-confirm-your-windows-host-have-winrm-enabled)
  - [Step 04: Create a new inventory file](#step-04-create-a-new-inventory-file)
  - [Step 05: Test your connection](#step-05-test-your-connection)
  - [Step 06: Create a playbook](#step-06-create-a-playbook)
  - [Step 07: Configure IIS](#step-07-configure-iis)
- [Conclusion](#conclusion)

## Objectives

- Configure a Windows host to be managed by Ansible
- Create a playbook to install Notepad++ on a Windows host

## Prerequisites

- [ ] Navigate to `ansible` folder inside your home folder on control node

## Guide

### Step 01: Prepare Control Node

Before you start, you need to install the following packages on your control node:

```bash
sudo apt update
sudo apt install -y python3-pip
pip install "pywinrm>=0.3.0"
```

### Step 02: Create a Windows VM

Create a Windows VM on Azure, with the following details:

- **Resource Group**: `<your-prefix>-ansible-lab`
- **Region**: `West Europe`
- **Virtual Machine Name**: `<your-prefix>-windows-node`
- **Availability options**: `No infrastructure redundancy required`
- **Image**: `Windows Server 2019 Datacenter - x64 Gen2`
- **Size**: `Standard_D4s_v3`
- **Username**: `azureuser`
- **Password**: Select a password that will remeber after :)

You need to go to the `Networking` tab and select the previously create virtual network. This will ensure that all virtual machines are in the same network.

On the dropdown, you need to select the virtual network that starts with `<your-prefix>`.

In this case, you need to enable the public IP since you need to use RDP to access the VM to check if WinRM is enabled.
  
After creating the VM, make sure you keep this information:

- Private and public IP Address
- Username
- Password

### Step 03: Confirm your Windows host have WinRM enabled

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

Check if on the list od IPs on `ListeningOn` you have the private IP of your Windows host.

You don't need to open the port 5985 on the Windows host, since the connection will be made through the Azure network.

## Step 04: Create a new inventory file

Create a new inventory file named `windows.yml` on the `inventory` folder with the following content:

```yaml
windows:
  hosts:
    windows-server:
      ansible_host: <WINDOWS_PRIVATE_IP>
```

Then create a new file named `inventory/group_vars/windows.yml` with the following content:

```yaml
ansible_port: 5985
ansible_user: <WINDOWS_USERNAME>
ansible_connection: winrm
ansible_winrm_server_cert_validation: ignore
ansible_winrm_transport: ntlm
ansible_winrm_scheme: http
```

## Step 05: Test your connection

Run the following command to test your connection:

```bash
ansible -i inventory/windows.yml windows -m ansible.windows.win_ping -k
```

The `-k` flag will ask for your password.

You need to enter your user password to be able to connect to the Windows host.

You should see an output similar to this:

```bash
<WINDOWS_IP> | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 06: Create a playbook

Create a playbook named `notepad.yml` with the following content:

```yaml
---
- name: Installing Notepad ++
  hosts: windows
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

Now, let's run the playbook with the following command:

```bash
ansible-playbook -i inventory/windows.yml notepad.yml -k
```

You need to enter your user password to be able to connect to the Windows host.

### Step 07: Configure IIS

Create a playbook named `iis.yml` with the following content:

```yaml
- name: Installing IIS
  hosts: windows
  gather_facts: false
  tasks:
    - name: Install IIS Web-Server with sub features and management tools
      ansible.windows.win_feature:
        name: Web-Server
        state: present
        include_sub_features: true
        include_management_tools: true
      register: iis_install
      notify: Reboot

  handlers:
    - name: Reboot when Web-Server feature requires it
      ansible.windows.win_reboot:
      when: iis_install.reboot_required
      listen: Reboot
```

Check the handler `Reboot` that will be called when the `Web-Server` feature requires a reboot, using the output of the `win_feature` module.

Now run the playbook with the following command:

```bash
ansible-playbook -i inventory/windows.yml iis.yml -k
```

You need to enter your user password to be able to connect to the Windows host.

## Conclusion

You configured a Windows host to be managed by Ansible and created a playbook to install Notepad++ on it.
