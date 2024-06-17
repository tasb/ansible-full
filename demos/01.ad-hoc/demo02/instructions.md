# Demo: Authentication

## Run ping command

```bash
ansible all -m ping
```

## Check SSH configuration

```bash
cat ~/.ssh/config
```

## Check users on all machines

```bash
ansible all -m command -a "ls /home"
```

## Use ansible user

```bash
ansible all -m ping --user=ansible
```

## Use ansible user with proper key

```bash
ansible all -m ping --user=ansible --private-key=~/Users/tiago.bernardo/ssh-keys/ansible
```

## Use ssh key in config file

1. Edit ansible.cfg
2. Uncomment private_key_file

```bash
ansible all -m ping --user=ansible
```
