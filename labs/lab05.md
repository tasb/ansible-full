# Lab 05 - Author your first Ansible Role

## Table of Contents

- [Objectives](#objectives)
- [Prerequisites](#prerequisites)
- [Guide](#guide)
  - [Step 01: Understand the role structure](#step-01-understand-the-role-structure)
  - [Step 02: Update documentation and meta files](#step-02-update-documentation-and-meta-files)
  - [Step 03: Create variables file](#step-03-create-variables-file)
  - [Step 04: Create tasks files](#step-04-create-tasks-files)
  - [Step 05: Create handlers file](#step-05-create-handlers-file)
  - [Step 06: Use the role in a playbook](#step-06-use-the-role-in-a-playbook)
  - [Step 07: Run the playbook](#step-07-run-the-playbook)
  - [Step 08: [Optional] Make the role available on a Git repository and use it in a playbook](#step-08-optional-make-the-role-available-on-a-git-repository-and-use-it-in-a-playbook)
- [Conclusion](#conclusion)

## Objectives

- Understand the role structure
- Create a role
- Use the role in a playbook
- Understand the role variables
- [Optional] Make the role available on a Git repository and use it in a playbook

## Prerequisites

- [ ] Navigate to `ansible` folder inside your home folder on control node

## Guide

### Step 01: Understand the role structure

A role is a way of organizing tasks, handlers, variables, and other files in a structured way.

When you create a role, you create a directory structure that contains the role's tasks, handlers, and other files.

Let's create a role named `lab.usersandgroups`:

```bash
ansible-galaxy role init --init-path=./roles/ lab.usersandgroups
```

This command will create a directory structure for the role in the `roles` folder.

Navigate to the `roles/lab.usersandgroups` folder and check the files created.

You must see the following files and directories:

```bash
.
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

On next steps you'll update the files and directories created.

**Pay attention when pasting the content of the files, because the files have been initialized with some content that you'll need to replace.**

**If you not replace that code, you'll get errors when executing the playbook.**

## Step 02: Update documentation and meta files

Update the `README.md` file with the role description and usage with the content available on this [README.md](lab05/README.md) file.

Update the `meta/main.yml` file with the role metadata with following content:

```yaml
galaxy_info:
  role_name: usersandgroups
  author: Ansible Training
  description: Manage users and groups on Linux/Unix systems
  company: Ansible Training
  min_ansible_version: "2.9"
  license: MIT

  # List of platforms you support and the versions, e.g., EL (Enterprise Linux) 7, 8, Ubuntu 18.04 (Bionic)
  platforms:
    - name: Rocky
      versions:
        - "8.0"
        - "9.0"
    - name: Ubuntu
      versions:
        - bionic
        - focal
    - name: Debian
      versions:
        - stretch
        - buster
        - bullseye

  # List of categories this role falls into, from Galaxy's predefined list
  galaxy_tags:
    - system
    - users
    - groups
    - management

  # Dependencies are other roles that this role depends upon to function
dependencies: []
```

## Step 03: Create variables file

Edit the `defaults/main.yml` file with the following content:

```yaml
---
users_list:
  - name: exampleuser
    state: present
    password: "{{ 'examplepassword' | password_hash('sha512') }}"
    groups: ["examplegroup"]
    shell: "/bin/bash"
    createhome: yes
    generate_ssh_key: true
    default_folders:
      - "Documents"
      - "Downloads"
      - "Music"
      - "Pictures"
      - "Videos"

# Default list of groups to manage
groups_list:
  - name: examplegroup
    state: present

# Path to keep the fetched SSH keys
destination_path_on_control_node: "/tmp"
```

Please go through the file and understand the variables defined.

These list are the parameters that you can use to manage users and groups.

Check the password hash generation using the `password_hash` filter: `{{ 'examplepassword' | password_hash('sha512') }}`.

This filter will generate the password hash for the user `exampleuser` using the `sha512` algorithm.

For now we're setting this sensitive information in plain text, but in a real-world scenario you should use Ansible Vault to encrypt this information.

We'll go through Ansible Vault in the next lab.

## Step 04: Create tasks files

On this step, you'll use the `include_tasks` module to include the tasks from the `users.yml` and `groups.yml` file.

Let's update the `tasks/main.yml` file with the following content:

```yaml
---
# Loop to create groups
- name: Create groups
  include_tasks: groups.yml # include the tasks from the groups.yml file
  loop: "{{ groups_list }}" # loop over the groups_list variable
  loop_control:
    loop_var: group # change the loop variable name to group

# Loop to create users and subfolders
- name: Create user and subfolders
  include_tasks: users.yml # include the tasks from the users.yml file
  loop: "{{ users_list }}" # loop over the users_list variable
  loop_control:
    loop_var: user # change the loop variable name to user
```

Now, let's create a `users.yml` file inside the `tasks` directory with the following content:

```yaml
---
- name: Print user details
  debug:
    var: user
# Create users
- name: Ensure users are present or absent
  ansible.builtin.user:
    name: "{{ user.name }}"
    state: "{{ user.state }}"
    password: "{{ user.password }}"
    groups: "{{ user.groups }}"
    shell: "{{ user.shell }}"
    createhome: "{{ user.createhome }}"
    generate_ssh_key: "{{ user.generate_ssh_key }}"
    ssh_key_bits: 2048
    ssh_key_file: ".ssh/id_rsa"

- name: Ensure home subfolders exist
  ansible.builtin.file:
    path: "/home/{{ user.name }}/{{ item }}"
    state: directory
    owner: "{{ user.name }}"
    group: "{{ user.name }}"
    mode: '0755'
  loop: "{{ user.default_folders}}"

- name: Fetch private SSH key to control node
  ansible.builtin.fetch:
    src: "/home/{{ user.name }}/.ssh/id_rsa"
    dest: "{{ destination_path_on_control_node }}/{{ inventory_hostname }}_{{ user.name }}_id_rsa"
    flat: yes
  notify: reload sshd
```

On this file you created the following tasks:

- The first task will print the user details to the console.
- The second task will create the user referenced in the `user` variable, that was defined on the loop in the `main.yml` file.
- The third task will ensure the home subfolders exist for the user.
- The fourth task will fetch the private SSH key to the control node.

Then, let's create a `groups.yml` file inside the `tasks` directory with the following content:

```yaml
---
- name: Ensure groups are present or absent
  ansible.builtin.group:
    name: "{{ group.name }}"
    state: "{{ group.state }}"
```

This file is simpler than the `users.yml` file, it only ensures that the groups are present or absent.

## Step 05: Create handlers file

Now, let's edit the `handlers/main.yml` file with the following content:

```yaml
---
# Optional: Reload SSH daemon if necessary
- name: Reload SSH daemon
  ansible.builtin.service:
    name: sshd
    state: reloaded
  listen: "reload sshd"
```

This handler show another way to use handlers, you can use the `listen` directive to define a custom trigger for the handler instead of using the handler name.

The handler is notified by the `fetch` task in the `users.yml` file.

Since the handlers only run when notified by a task that results in a change, you only see this handler to run if the `fetch` task copied a newer version of the SSH key to the control node.

## Step 06: Use the role in a playbook

Now it's time for you to use the role in a playbook.

Create a playbook named `playbook.yml` on folder `lab05`.

This playbook will use the role `lab.usersandgroups` to manage the users and groups.

The file should have the following content:

```yaml
---
- name: Manage users and groups
  hosts: db
  become: true
  roles:
    - role: lab.usersandgroups
      when: ansible_os_family == "RedHat"
  vars:
    users_list:
      - name: adminuser
        state: present
        password: "{{ 'password123' | password_hash('sha512') }}"
        groups: ["wheel"]
        createhome: yes
        generate_ssh_key: true
        shell: "/bin/bash"
        default_folders:
          - "Documents"
          - "Downloads"
          - "Music"
          - "Pictures"
          - "Videos"
      - name: devuser
        state: present
        password: "{{ 'password123' | password_hash('sha512') }}"
        groups: ["wheel", "developers"]
        createhome: yes
        generate_ssh_key: true
        shell: "/bin/bash"
        default_folders:
          - "Documents"
          - "Downloads"
          - "Work"
      - name: testeruser
        state: present
        password: "{{ 'password123' | password_hash('sha512') }}"
        groups: ["testers"]
        createhome: yes
        generate_ssh_key: true
        shell: "/bin/bash"
        default_folders:
          - "Documents"
          - "Downloads"
          - "Tests"
    groups_list:
      - name: developers
        state: present
      - name: testers
        state: present
```

On this playbook you use your role for creating 2 groups and 3 users.

Pay attention on the `when` directive on the role definition, this is a conditional statement that will only run the role if the `ansible_os_family` is `RedHat`.

## Step 07: Run the playbook

Run the playbook using the following command:

```bash
ansible-playbook -i inventory playbook.yml
```

Take some time to look at the output and understand what is happening.

Now execute the playbook again using the following command:

```bash
ansible-playbook -i inventory playbook.yml
```

Check the output and see if there's any change.

In particular, check that the handler is not running again, because the SSH key was already fetched.

Since you didn't change the `destination_path_on_control_node` variable, the SSH keys were fetch for the folder `/tmp` on the control node as defined as default on the `defaults/main.yml` file.

Just confirm that you got the keys from each user, running the following command:

```bash
ls -l /tmp
```

## Step 08: [Optional] Make the role available on a Git repository and use it in a playbook

If you want to make your role available on a Git repository, you can use the following steps:

1. Create a new repository on GitHub
2. Clone the repository to your local machine
3. Copy the `lab.usersandgroups` role to the repository. The root dir of your repo should contain the folders of the role.
4. Commit and push the changes to the repository
5. Create a `requirements.yml` file with the following content:

    ```yaml
    - src: <URL of your git repo>
    version: main
    name: lab.usersandgroups
    ```

6. Delete the `lab.usersandgroups` role from your local machine
7. Run the following command to install the role from the repository:

    ```bash
    ansible-galaxy install -r requirements.yml
    ```

8. Run the playbook using the role from the repository:

    ```bash
    ansible-playbook -i inventory playbook.yml
    ```

9. Check the output and see if there's any change. Since you didn't changed the variables for using the role, you should not see any change.

## Conclusion

You've created your first Ansible role and used it in a playbook.

This lab allow you to understand the role structure, how to create a role, use the role in a playbook and understand the role variables.

Additionally, you used some other techniques when authoring Ansible code.
