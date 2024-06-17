# Ansible Vault

## Encrypt Passwords

- Create encrypted password using dev vault

```bash
ansible-vault encrypt_string 'dev_password' --name 'bd_pass'
```

## Run Playbook

```bash
ansible-playbook -i inventory vault-var.yml --ask-vault-pass
```

## Encrypt File

```bash
ansible-vault create confidential_data.txt
```

- Add content: "API_KEY=1234567890"

## Verify Encrypted File

```bash
cat confidential_data.txt
```

## Edit Encrypted File

```bash
ansible-vault edit confidential_data.txt
```

## Use password file

- Add password on file

```bash
echo "password" > vault_pass.txt
```

```bash
ansible-playbook vault.yml --vault-password-file vault_pass.txt
```
