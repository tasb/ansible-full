# Lab 03 - Author and run your first playbook

## Contents

- [Goals](#goals)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 1: Prepare the servers](#step-1-prepare-the-servers)
  - [Step 2: Create the Playbook](#step-2-create-the-playbook)
  - [Step 3: Run the Playbook](#step-3-run-the-playbook)
  - [Step 4: Test the Web Server](#step-4-test-the-web-server)
  - [Step 5: Change homepage](#step-5-change-homepage)
  - [Step 6: Add a smoke test](#step-6-add-a-smoke-test)
- [Conclusion](#conclusion)

## Goals

- Author your first Ansible playbook
- Run the playbook to install and configure a web server
- Test the web server
- Change the homepage
- Add a smoke test

## Prerequisites

- [ ] Navigate to `ansible` folder inside your home folder on control node
- [ ] Finish [Lab 02](lab02.md) to ensure you have access to managed nodes

## Guide

### Step 1: Prepare the servers

Since we've installed nginx on the managed nodes, we need to remove it before installing Apache.

Run the following command to remove nginx from the managed nodes:

```bash
ansible -i inventory/hosts.yml all -m ansible.builtin.service -a "name=nginx state=stopped" --become
```

Once you've stop nginx service, you can proceed to the next step.

### Step 2: Create the Playbook

Create a file named `webserver.yml` inside `ansible` folder.

Add the following content to the file:

```yaml
---
- name: Install and configure web server
  hosts: webserver
  become: true
  tasks:
    - name: Update and upgrade apt packages
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 86400
    - name: Install Apache
      ansible.builtin.apt:
        name: apache2
        state: latest
    - name: Start Apache
      ansible.builtin.service:
        name: apache2
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
ansible-playbook -i inventory/hosts.yml webserver.yml
```

This will run the playbook on the hosts in the `webserver` group.

You should see output similar to the following:

```bash
PLAY [Install and configure web server] ****************************************************

TASK [Gathering Facts] *********************************************************************
ok: [server-1]

TASK [Install Apache] **********************************************************************
changed: [server-1]

TASK [Start Apache] ************************************************************************
changed: [server-1]

PLAY RECAP *********************************************************************************
server-1          : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### Step 4: Test the Web Server

Run the following command to test the web server:

```bash
curl http://<server-1-private-ip>
```

Please replace `<server-1-private-ip>` with the private IP address of your managed node.

You should get an HTML page as output.

You can also open the URL on your browser to see the page.

### Step 5: Change homepage

First, create a folder named `static` inside the `ansible` folder.

Then, let's create a new file named `index.html` inside `static` folder.

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
        src: static/index.html
        dest: /var/www/html/index.html
```

Pay attention to the indentation. The task should be at the same level as the `Start Apache` task.

Run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml webserver.yml
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

Now navigate run the following command to test the web server:

```bash
curl http://<server-1-private-ip>
```

You should see the new content on the page.

### Step 6: Add a smoke test

Update the `webserver.yml` file to add a new task to run a smoke test.

Add the following content to the `webserver.yml` file after the `Copy index.html` task:

```yaml
    - name: Run smoke test
      ansible.builtin.uri:
        url: http://localhost
        return_content: yes
      register: result
    - name: Debug smoke test
      ansible.builtin.debug:
        msg: "{{ result.content }}"
```

Let's run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml webserver.yml
```

Pay attention that the URL you are testing is `http://localhost` because the playbook is running on the managed node.

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
        url: http://localhost
        return_content: yes
      register: result
    - name: Debug smoke test
      ansible.builtin.debug:
        msg: "{{ result.content }}"
```

## Conclusion

Congratulations! You've created and run your first Ansible playbook.

With this playbook you've learned how to install and configure a web server on a managed node, change the homepage, and run a smoke test.
