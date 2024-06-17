# lab.usersandgroups

This Ansible role facilitates the management of users and groups on Linux/Unix systems. It allows for the creation, modification, and removal of users and groups, supporting a wide range of configurations including setting user passwords, managing home directories, and configuring user-specific SSH access.

## Requirements

- Ansible 2.9 or later.
- SSH access to the target systems.
- Sudo privileges on the target systems for the executing user.

## Role Variables

This role uses the following variables to manage users and groups. These variables should be defined in your playbook under the `vars` section or in separate variables files.

### General Variables

- `users_list`: A list of users to manage. Each user in the list is a dictionary with specific attributes.
- `groups_list`: A list of groups to manage. Each group in the list is a dictionary with specific attributes.

### User Attributes

- `name`: The name of the user. (Required)
- `state`: Define whether the user should be `present` or `absent`. Default is `present`.
- `password`: The encrypted password for the user. Use Ansible's `password_hash` filter to generate.
- `groups`: A list of groups the user should be added to. This does not include the user's primary group.
- `shell`: The user's shell. Default is `/bin/bash`.
- `createhome`: Whether to create the user's home directory. Default is `yes`.
- `remove`: Whether to remove the user's home directory when the user is removed. Default is `no`.
- `ssh_key`: A string containing the user's public SSH key.

### Group Attributes

- `name`: The name of the group. (Required)
- `state`: Define whether the group should be `present` or `absent`. Default is `present`.
- `gid`: The GID (group ID) for the group.

## Dependencies

None.

## Example Playbook

```yaml
- hosts: all
  become: yes
  roles:
    - labs.usersandgroups
  vars:
    users_list:
      - name: johndoe
        state: present
        password: "{{ 'password123' | password_hash('sha512') }}"
        groups: ["wheel", "developers"]
        ssh_key: "{{ lookup('file', '/path/to/public/key') }}"
    groups_list:
      - name: developers
        state: present
```

## License

MIT / BSD

## Author Information

This role was created in 2024 on Ansible Training Labs
