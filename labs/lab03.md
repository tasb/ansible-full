# Lab 03 - Author and run your first playbook

## Contents

- [Objective](#objective)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 1: Add connection details on inventory](#step-1-add-connection-details-on-inventory)
  - [Step 2: Create the Playbook](#step-2-create-the-playbook)
  - [Step 3: Run the Playbook](#step-3-run-the-playbook)
  - [Step 4: Test the Web Server](#step-4-test-the-web-server)
  - [Step 5: Change homepage](#step-5-change-homepage)
  - [Step 6: Add a smoke test](#step-6-add-a-smoke-test)
- [Conclusion](#conclusion)

## Objective

Create an Ansible playbook that installs and configures a web server on a managed node.

## Prerequisites

- [ ] Create a folder named `lab03` inside `ansible-labs`
- [ ] Navigate to `lab03` folder
- [ ] Copy the `inventory` folder from `lab02` to `lab03`

## Guide

### Step 1: Add connection details on inventory

Create a file called `all.yml` inside `inventory/group_vars` folder.

Add the following content to the file:

```yaml
ansible_private_key_file: /home/vagrant/.ssh/ansible
ansible_user: vagrant
```

With this, we are telling Ansible to use the private key file `/home/vagrant/.ssh/ansible` to connect to the managed nodes and to use the user `vagrant`.

This configuration replace the need to use `ansible.cfg` file.

Let's test the connection:

```bash
ansible -i inventory all -m ping
```

You should see output similar to the following:

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

### Step 2: Create the Playbook

Create a file named `webserver.yml` inside `lab03` folder.

Add the following content to the file:

```yaml
---
- name: Install and configure web server
  hosts: webserver
  become: true
  tasks:
    - name: Install Apache
      ansible.builtin.yum:
        name: httpd
        state: latest
    - name: Start Apache
      ansible.builtin.service:
        name: httpd
        state: started
```

On this playbook, we are:

- Installing Apache web server
- Starting Apache web server
- Setting the `become` option to `true` to run the tasks as root
- Setting the `hosts` option to `webserver` to run the tasks on the hosts in the `webserver` group

### Step 3: Run the Playbook

Run the playbook using the `ansible-playbook` command:

```bash
ansible-playbook -i inventory/inventory.yml webserver.yml
```

This will run the playbook on the hosts in the `webserver` group.

You should see output similar to the following:

```bash
PLAY [Install and configure web server] ****************************************************

TASK [Gathering Facts] *********************************************************************
ok: [servidor-0]

TASK [Install Apache] **********************************************************************
changed: [servidor-0]

TASK [Start Apache] ************************************************************************
changed: [servidor-0]

PLAY RECAP *********************************************************************************
servidor-0          : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### Step 4: Test the Web Server

Run the following command to test the web server:

```bash
curl http://servidor-0.seg-social.virt
```

You should get an HTML page as output.

You can also open the URL on your browser to see the page.

### Step 5: Change homepage

First, let's create a new file named `index.html` inside `lab03` folder.

Add the following content to the file:

```html
<html>
  <head>
    <title>Ansible Lab</title>
  </head>
  <body>
    <h1>Ansible Lab</h1>
    <p>This is a test page</p>
  </body>
</html>
```

Now, let's update the playbook to copy the file to the web server.

Update the `webserver.yml` file to add a new task to copy the file to the web server.

Add the following content to the file after the last task:

```yaml
    - name: Copy index.html
      ansible.builtin.copy:
        src: index.html
        dest: /var/www/html/index.html
```

Pay attention to the indentation. The task should be at the same level as the `Start Apache` task.

Run the playbook again:

```bash
ansible-playbook -i inventory/inventory.yml webserver.yml
```

You should see output similar to the following:

```bash
PLAY [Install and configure web server] **************************************

TASK [Gathering Facts] *******************************************************
ok: [servidor-0]

TASK [Install Apache] ********************************************************
ok: [servidor-0]

TASK [Start Apache] **********************************************************
ok: [servidor-0]

TASK [Copy index.html] *******************************************************
changed: [servidor-0]

PLAY RECAP ************************************************************************************************
servidor-0          : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Now navigate to the URL <http://servidor-0.seg-social.virt> and you should see the new page.

### Step 6: Add a smoke test

Update the `webserver.yml` file to add a new task to run a smoke test.

Add the following content to the `webserver.yml` file after the `Copy index.html` task:

```yaml
    - name: Run smoke test
      ansible.builtin.uri:
        url: http://servidor-0.seg-social.virt
        return_content: yes
      register: result
    - name: Debug smoke test
      ansible.builtin.debug:
        msg: "{{ result.content }}"
```

Let's run the playbook again:

```bash
ansible-playbook -i inventory/inventory.yml webserver.yml
```

The playbook file context at the end should look like this:

```yaml
---
- name: Install and configure web server
  hosts: webserver
  become: true
  tasks:
    - name: Install Apache
      ansible.builtin.yum:
        name: httpd
        state: latest
    - name: Start Apache
      ansible.builtin.service:
        name: httpd
        state: started
    - name: Copy index.html
      ansible.builtin.copy:
        src: index.html
        dest: /var/www/html/index.html
    - name: Run smoke test
      ansible.builtin.uri:
        url: http://servidor-0.seg-social.virt
        return_content: yes
      register: result
    - name: Debug smoke test
      ansible.builtin.debug:
        msg: "{{ result.content }}"
```

## Conclusion

In this lab, we created our first playbook to install and configure a web server. You also learned how to run a playbook and how to update it to add new tasks.
