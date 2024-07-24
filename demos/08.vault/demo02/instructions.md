# Ansible Vault ID

## Create vault password files

```bash
echo 'vault1_password' > .vault1_pass.txt
echo 'vault2_password' > .vault2_pass.txt
```

## Create confidential data

```bash
ansible-vault create --vault-id vault1@.vault1_pass.txt api-key.txt
```

Add the following content:

```bash
api_key: 1234567890
```

## Create string secret

```bash
ansible-vault encrypt_string --vault-id vault2@.vault2_pass.txt 'dev_password' --name 'bd_pass'
```

## Run playbook

```bash
ansible-playbook -i ../inventory/hosts.yml multi-vault.yml --vault-id vault1@.vault1_pass.txt --vault-id vault2@.vault2_pass.txt
```
