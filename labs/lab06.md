# Lab 06 - Using Templates with Jinja2

## Table of Contents

- [Objectives](#objectives)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 01: Create a nginx role](#step-01-create-a-nginx-role)
  - [Step 02: Update `defaults/main.yml`](#step-02-update-defaultsmainyml)
  - [Step 03: Create a template file](#step-03-create-a-template-file)
  - [Step 04: Update `tasks/main.yml`](#step-04-update-tasksmainyml)
  - [Step 05: Update `handlers/main.yml`](#step-05-update-handlersmainyml)
  - [Step 06: Create a playbook](#step-06-create-a-playbook)
  - [Step 07: Run the playbook](#step-07-run-the-playbook)
  - [Step 08: Access the server](#step-08-access-the-server)
- [Conclusion](#conclusion)

## Objectives

- Understand how to use Jinja2 templates with Ansible
- Understand how to use variables inside a template
- Create a role that uses a Jinja2 template
- Create a playbook that uses a role with a Jinja2 template

## Prerequisites

- [ ] Navigate to `ansible` folder inside your home folder on control node

## Guide

### Step 01: Create a nginx role

Create a role named `lab.nginx` using the following command:

```bash
ansible-galaxy role init --init-path=./roles/ lab.nginx
```

Now let's update role's files to install the `nginx` package and start the service.

### Step 02: Update `defaults/main.yml`

Update the `defaults/main.yml` file, removing all file content and include the following content:

```yaml
---
version: "1.18.0"
template_file: "templates/index.html.j2"
```

With these variables, you may use a specific version of `nginx` and a template file to configure it.

### Step 03: Create a template file

Create a file named `index.html.j2` inside `templates` with the following content:

```html
<!DOCTYPE html>

<html>
  <head>
    <title>Welcome to {{ ansible_hostname }}</title>
  </head>
  <body>
    <h1>Welcome to {{ ansible_hostname | upper }}</h1>
    <p>This is a sample page created using Jinja2 template.</p>
    <p>Version: {{ version }}</p>
    <p>Date: {{ ansible_date_time.date }}</p>
  </body>
</html>
```

Take a look at the variables used inside the template file. You can use any variable available in Ansible to create a dynamic template.

On this example, you are using the following variables:

- `ansible_hostname | upper`: The hostname of the machine in uppercase
- `version`: The version of `nginx` to be installed
- `ansible_date_time.date`: The current date

### Step 04: Update `tasks/main.yml`

Update the `tasks/main.yml` file removing all content and to include the following content:

```yaml
---
- name: Install nginx
  package:
    name: nginx
    state: present

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes

- name: Create index.html
  template:
    src: "{{ template_file }}"
    dest: /usr/share/nginx/html/index.html
  notify: Restart nginx
```

### Step 05: Update `handlers/main.yml`

Update the `handlers/main.yml` file removing all content and to include the following content:

```yaml
---
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

### Step 06: Create a playbook

Create a playbook named `nginx.yml` with the following content:

```yaml
---
- name: Install nginx
  hosts: all
  become: yes
  roles:
    - lab.nginx
```

### Step 07: Run the playbook

Run the playbook using the following command:

```bash
ansible-playbook -i inventory nginx.yml
```

### Step 08: Access the server

On the control node, run the following `curl` commands to access the servers:

```bash
curl http://<server-1-private-ip>
curl http://<server-2-private-ip>
```

You should see the `index.html` file created using the Jinja2 template.

For each server, the hostname and the date should be different.

## Conclusion

You've learned how to use Jinja2 templates with Ansible. You've created a role that uses a template file to create a dynamic `index.html` file for `nginx` server.
