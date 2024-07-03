# Lab 04 - Deep dive into Ansible Playbooks

## Table of Contents

- [Goals](#goals)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 1: Install Redis](#step-1-install-redis)
  - [Step2: Work with handlers](#step2-work-with-handlers)
  - [Step 3: Configure Redis](#step-3-configure-redis)
  - [Step 4: Install PostgreSQL](#step-4-install-postgresql)
  - [Step 5: Configure Apache](#step-5-configure-apache)
  - [Step 6: Run the full playbook](#step-6-run-the-full-playbook)
- [Conclusion](#conclusion)

## Goals

- Install and configure a Apache web server
- Install and configure a PostgreSQL database server
- Install and configure Redis on both servers

## Prerequisites

- [ ] Navigate to `ansible` folder inside your home folder on control node
- [ ] Finish [Lab 03](lab03.md) to ensure you have access to managed nodes

## Guide

### Step 1: Install Redis

Create a file named `full_playbook.yml` inside `ansible` folder.

Add the following content to the file:

```yaml
---
- name: Install and configure Redis
  hosts: all
  become: true
  tags:
    - redis
  tasks:
    - name: Install Redis
      ansible.builtin.yum:
        name: redis
        state: present
      when: ansible_facts['os_family'] == "RedHat"
      notify:
        - Start Redis

    - name: Install Redis
      ansible.builtin.apt:
        name: redis-server
        state: present
      when: ansible_facts['os_family'] == "Debian"
      notify:
        - Start Redis

    - name: Test Redis
      ansible.builtin.command: redis-cli ping
      register: redis_ping

    - name: Print Redis ping
      ansible.builtin.debug:
        msg: "{{ redis_ping.stdout }}"

  handlers:
    - name: Start Redis
      service:
        name: redis
        state: started
        enabled: true
```

On this playbook, we are:

- Installing Redis on RedHat and Debian based systems using the `yum` and `apt` modules
- Using Ansible facts to determine the OS family and using a conditional to run the correct task
- Using the `notify` option to trigger the `Start Redis` handler
- Using the `service` module to start the Redis service
- Using the `command` module to run the `redis-cli ping` command and register the output
- Using the `debug` module to print the output of the `redis-cli ping` command

On play definition we're including the tag `redis` to the play. This will allow us to run only the tasks with this tag.

Now let's run the playbook:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml
```

You should see an error on the output when trying to run `Test Redis` task.

This is because even you installed Redis, you didn't started the service.

You notified the `Start Redis` handler, but it will only run when the all playbook tasks run.

### Step2: Work with handlers

Now let's add a `meta` task to force the handler to run. Edit the file `full_playbook.yml` and add the following task before the `Test Redis` task:

```yaml
- name: Force handler execution
  meta: flush_handlers
```

Pay attention to the indentation. This task should be at the same level as the other tasks.

Now let's run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml
```

Even forcing the handler to run, you'll get an error on the `Test Redis` task.

This is because that the task `Install Redis` returned an `OK` result and Ansible only runs the handler notified by a task if the task returns a `Changed` result.

To force the handler to run, you need to change the `Install Redis` task to return a `Changed` result. You will use the `changed_when` option to do this.

Edit the file `full_playbook.yml` and change the `Install Redis` task to the following:

```yaml
- name: Install Redis
  ansible.builtin.yum:
    name: redis
    state: present
  when: ansible_facts['os_family'] == "RedHat"
  register: redis_installed
  changed_when: redis_installed.rc == 0
  notify:
    - Start Redis

- name: Install Redis
  ansible.builtin.apt:
    name: redis-server
    state: present
  when: ansible_facts['os_family'] == "Debian"
  register: redis_installed
  changed_when: redis_installed.rc == 0
  notify:
    - Start Redis
```

Pay attention to the indentation. The `changed_when` option should be at the same level as the `register` option.

On this task, you are using the `changed_when` option to change the result of the task to `Changed` when the `rc` attribute of the `redis_installed` variable is `0`.

The `rc` attribute is the return code of the task. When the task runs without any error, the return code is `0`.

Let's run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml
```

Now everything should run fine and you get an output for the `Test Redis` task similar to the following:

```bash
TASK [Print Redis ping] ***************************
ok: [server-0] => {
    "msg": "PONG"
}
ok: [server-1] => {
    "msg": "PONG"
}
```

### Step 3: Configure Redis

On this step, we'll configure Redis to add a password.

Edit the file `full_playbook.yml` and add the following task after the `Print Redis ping` task:

```yaml
- name: Configure Redis
  ansible.builtin.replace:
    path: /etc/redis/redis.conf
    regexp: '^# requirepass foobared'
    replace: 'requirepass ansible'
    backup: yes
  notify:
    - Restart Redis
```

On this task, we are using the `replace` module to replace the line `# requirepass foobared` with `requirepass ansible` on the file `/etc/redis.conf`.

Then we are using the `notify` option to trigger the `Restart Redis` handler.

So you need to create the handler. Edit the file `full_playbook.yml` and add the following handler after the `Start Redis` handler:

```yaml
- name: Restart Redis
  ansible.builtin.service:
    name: redis
    state: restarted
```

Now let's run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml
```

Take a look to the output of this run and check how the task run and at the end you see the handler running.

Now let's run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml
```

As expected, everything run fine since you're using idempotent tasks. If not, you'll get an error on the `Configure Redis` task because the regular expression will not match.

But you may notice a difference on the output of the `Print Redis ping` task:

```bash
TASK [Print Redis ping] **************************
ok: [server-1] => {
    "msg": "NOAUTH Authentication required."
}
ok: [server-2] => {
    "msg": "NOAUTH Authentication required."
}
```

This is because you change the configuration of Redis and now it requires authentication.

So let's change the `Print Redis ping` task to use the `redis-cli` command with the password.

First, create a variable named `redis_password` with the value `ansible` on the `vars` section of the playbook:

```yaml
vars:
  redis_password: ansible
```

This block should be added before the `tasks` section. Pay attention to the indentation.

Then, edit the `Test Redis` task and change the `command` module to use the `redis-cli` command with the password:

```yaml
- name: Test Redis
  ansible.builtin.command: redis-cli -a {{ redis_password }} ping
  register: redis_ping
```

Finally, to make use of the variable, edit the `Configure Redis` task and change the `replace` module to use the variable:

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

Let's run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml
```

Now you should see the output of the `Print Redis ping` task similar to the following:

```bash
TASK [Print Redis ping] ***************************
ok: [server-1] => {
    "msg": "PONG"
}
ok: [server-2] => {
    "msg": "PONG"
}
```

Having the password on the playbook is not a good practice. We're doing this way just for learning purposes and to be changed in a later lab when we introduce Ansible Vault.

### Step 4: Install PostgreSQL

Now let's install PostgreSQL.

Edit the file `full_playbook.yml` and add a new play after the `Install and configure Redis` play:

```yaml
- name: Install and configure PostgreSQL
  hosts: db
  become: true
  gather_facts: false
  tags:
    - postgresql
```

Let's understand what we're doing here:

- Creating a new play with the name `Install and configure PostgreSQL`
- Using the `hosts` option to run this play only on the `db` group
- Using the `become` option to run the tasks with `sudo`
- Set the `gather_facts` option to `false` to avoid gathering facts on this play
- Using the `tags` option to add the `postgresql` tag to this play

Now let's add the task to install PostgreSQL:

```yaml
  tasks:
    - name: Install PostgreSQL
      ansible.builtin.package:
        name: postgresql-server
        state: present
```

Check that we're using the `ansible.builtin.package` module to install the `postgresql-server` package.

This module can be used on both RedHat and Debian based systems and uses the correct package manager for each system.

You can check more details about this module on the [Ansible documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html).

Then, you need to add the task to initialize the database:

```yaml
    - name: "Find out if PostgreSQL is initialized"
      ansible.builtin.stat:
        path: "/var/lib/pgsql/data/pg_hba.conf"
      register: postgres_data
    
    - name: "Initialize PostgreSQL"
      ansible.builtin.shell: "postgresql-setup --initdb"
      when: not postgres_data.stat.exists
```

These tasks will check if the file `/var/lib/pgsql/data/pg_hba.conf` exists and if not, will initialize the database.

Pay attention to the `when` condition on the second task. This task will only run if the file doesn't exist.

When adding this to the file pay attention to the indentation. These tasks should be at the same level as the `Install PostgreSQL` task.

Then, you need to add the task to start the service:

```yaml
- name: Start PostgreSQL
  ansible.builtin.service:
    name: postgresql
    state: started
    enabled: true
```

This task will use the `service` module to start the PostgreSQL service.

Finally, you need to add the tasks to test if PostgreSQL is running:

```yaml
- name: Test PostgreSQL
  become: true
  become_user: postgres
  ansible.builtin.shell: |
    psql -c "SELECT version();"
  register: postgresql_version
    
- name: Print PostgreSQL version
  ansible.builtin.debug:
    msg: "{{ postgresql_version.stdout }}"  
```

On this task you are using the `shell` module to run the `psql -c "SELECT version();"` command as the `postgres` user and register the output.

Check the line `become_user: postgres`. This is needed because the `postgres` user is the one that can run the `psql` command.

Now let's run the playbook:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml --tags postgresql
```

On the command above, you're running the playbook and filtering the tasks by the `postgresql` tag.

You should run everything without any error.

Now let's run the playbook again:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml --tags postgresql
```

And confirm that only the testing tasks returns a `Changed` result.

### Step 5: Configure Apache

Now you need to add to this playbook the tasks to install and configure Apache.

Those tasks already exists on the `webserver.yml` playbook from the previous lab.

Then, edit the file `full_playbook.yml` and use the `import_playbook` module to import the `webserver.yml` playbook:

```yaml
- name: Install and configure web server
  tags:
    - webserver
  import_playbook: webserver.yml
```

This should be added after the last play.

Let's run the playbook:

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml --tags webserver
```

You should see the tasks from the `webserver.yml` playbook running.

### Step 6: Run the full playbook

After you added all the tasks, your `full_playbook.yml` should look like this:

```yaml
---
- name: Install and configure Redis
  hosts: all
  become: true
  tags:
    - redis
  vars:
    redis_password: ansible
  tasks:
    - name: Install Redis
      ansible.builtin.yum:
        name: redis
        state: present
      when: ansible_facts['os_family'] == "RedHat"
      register: redis_installed
      changed_when: redis_installed.rc == 0
      notify:
        - Start Redis

    - name: Install Redis
      ansible.builtin.apt:
        name: redis-server
        state: present
      when: ansible_facts['os_family'] == "Debian"
      register: redis_installed
      changed_when: redis_installed.rc == 0
      notify:
        - Start Redis

    - name: Print
      ansible.builtin.debug:
        msg: "{{ redis_installed }}"

    - meta: flush_handlers

    - name: Test Redis
      ansible.builtin.command: redis-cli -a {{ redis_password }} ping
      register: redis_ping

    - name: Print Redis ping
      ansible.builtin.debug:
        msg: "{{ redis_ping.stdout }}"

    - name: Configure Redis
      ansible.builtin.replace:
        path: /etc/redis/redis.conf
        regexp: '^# requirepass foobared'
        replace: 'requirepass {{ redis_password }}'
        backup: yes
      notify:
        - Restart Redis

  handlers:
    - name: Start Redis
      service:
        name: redis
        state: started
        enabled: true

    - name: Restart Redis
      service:
        name: redis
        state: restarted

- name: Install and configure PostgreSQL
  hosts: db
  become: true
  gather_facts: false
  tags:
    - postgresql
  tasks:
    - name: Install PostgreSQL
      ansible.builtin.package:
        name: postgresql-server
        state: present

    - name: "Find out if PostgreSQL is initialized"
      ansible.builtin.stat:
        path: "/var/lib/pgsql/data/pg_hba.conf"
      register: postgres_data

    - name: "Initialize PostgreSQL"
      shell: "postgresql-setup --initdb"
      when: not postgres_data.stat.exists

    - name: Start PostgreSQL
      service:
        name: postgresql
        state: started
        enabled: true

    - name: Test PostgreSQL
      become: true
      become_user: postgres
      ansible.builtin.shell: |
        psql -c "SELECT version();"
      register: postgresql_version

    - name: Print PostgreSQL version
      ansible.builtin.debug:
        msg: "{{ postgresql_version.stdout }}"

- name: Install and configure web server
  tags:
    - webserver
  import_playbook: webserver.yml
```

Now let's run the full playbook without setting any tag.

```bash
ansible-playbook -i inventory/hosts.yml full_playbook.yml
```

You should see all the tasks running and not making any change on the server unless on testing tasks.

## Conclusion

On this lab you learned how to create a playbook to install and configure multiple services on different servers.
