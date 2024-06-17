# Lab 07 - Using Ansible Vault and create a complex scenario

## Table of Contents

- [Objectives](#objectives)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 01: Create a role for each part of the playbook](#step-01-create-a-role-for-each-part-of-the-playbook)
  - [Step 02: Use template for `redis.conf`](#step-02-use-template-for-redisconf)
  - [Step 03: Use Ansible Vault to encrypt sensitive data](#step-03-use-ansible-vault-to-encrypt-sensitive-data)
  - [Step 04: Run the playbook](#step-04-run-the-playbook)
- [Conclusion](#conclusion)

## Objectives

- Create Ansible Roles from existing playbook
- Use Ansible Vault to encrypt sensitive data
- Use Templates with Jinja2 instead of regex replace

## Prerequisites

- [ ] Create a folder named `lab07` inside `ansible-labs`
- [ ] Navigate to `lab07` folder
- [ ] Copy all content from `lab04` fodler to `lab07` folder
  - Command: `cp -r ../lab04/* .`

## Guide

In this lab, you will use the playbook created on `lab04`and create roles for each part of the playbook.
You will also use Ansible Vault to encrypt sensitive data and use Jinja2 templates to update `redis.conf` file.

### Step 01: Create a role for each part of the playbook

On the playbook created on `lab04`, you have one play for Redis, another for PostgreSQL and another for Apache.

Look into this playbook and create a role for each part of it.

Then update the playbook to use the roles you've created.

Your playbook should look like this:

```yaml
---
- name: Install Redis, PostgreSQL and Apache
  hosts: all
  become: yes
  roles:
    - lab.redis
    - lab.postgresql
    - lab.apache
```

Run the playbook to make sure everything is working as expected, using the following command:

```bash
ansible-playbook -i inventory/inventory.yml full_playbook.yml
```

In case you get an error starting Apache `httpd` service, create a file named `clean-nginx.yml` with the following content:

```yaml
---
- name: Clean Nginx service
  hosts: all
  become: yes
  tasks:
  - name: Stop nginx
    service:
      name: nginx
      state: stopped
 
  - name: Remove nginx
    package:
      name: nginx
      state: absent
```

Execute the playbook using the following command:

```bash
ansible-playbook -i inventory/inventory.yml clean-nginx.yml
```

Then, execute the `full_playbook.yml` again, using the following command:

```bash
ansible-playbook -i inventory/inventory.yml full_playbook.yml
```

### Step 02: Use template for `redis.conf`

On the `lab.redis` role, you should have a task with the following content:

```yaml
- name: Configure Redis
  ansible.builtin.replace:
    path: /etc/redis/redis.conf
    regexp: '^# requirepass foobared'
    replace: 'requirepass {{ redis_password }}'
    backup: yes
  notify:
    - Restart Redis
```

This is a great opportunity to use a template instead of regex replace.

Create a template file named `redis.conf.j2` inside `templates` folder with the content of this file: [redis.conf](https://raw.githubusercontent.com/tasb/ansible-training/main/labs/lab07/redis.conf).

Find the line with the `# requirepass foobared` and replace it with `requirepass {{ redis_password }}`.

Then update the task to use the template file instead of regex replace.

After doing this, the task should look like this:

```yaml
- name: Configure Redis
  template:
    src: "templates/redis.conf.j2"
    dest: /etc/redis/redis.conf
  notify:
    - Restart Redis
```

Run the playbook to make sure everything is working as expected, using the following command:

```bash
ansible-playbook -i inventory/inventory.yml full_playbook.yml
```

### Step 03: Use Ansible Vault to encrypt sensitive data

You should have a variable file named `defaults/main.yml` inside `lab.redis` role with the following content:

```yaml
---
redis_password: ansible
```

Now, let's create an encrypted version of this variable at playbook level.

First, let's generate an encrypted password using Ansible Vault.

Run the following command:

```bash
ansible-vault encrypt_string 'ansible' --name 'redis_password'
```

You need to set a password to encrypt the variable. Use `password` as password.

You need to enter the password twice.

After that, you should get an output similar to this:

```bash
redis_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          663736336336313062....
```

Now you need to create a new `vars` block inside the playbook with the encrypted variable.

After doing this, your playbook should look like this:

```yaml
---
- name: Install Redis, PostgreSQL and Apache
  hosts: all
  become: yes
  roles:
    - lab.redis
    - lab.postgresql
    - lab.apache
  vars:
    redis_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          663736336336313062....
```

### Step 04: Run the playbook

Run the playbook using the following command:

```bash
ansible-playbook -i inventory/inventory.yml full_playbook.yml --ask-vault-pass
```

You need to enter the password you've set to encrypt the variable.

## Conclusion

Congratulations! You've created roles for each part of the playbook, used a template for `redis.conf` and encrypted sensitive data using Ansible Vault.
