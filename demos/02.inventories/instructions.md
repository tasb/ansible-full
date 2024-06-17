# Demo: Using Inventories and Variables

## Check inventory for dev env

```bash
ansible-inventory -i inventory/dev --list
```

## Check inventory for prod env

```bash
ansible-inventory -i inventory/prod --list --yaml
```

## Check inventory in graph format

```bash
ansible-inventory -i inventory/prod --graph
```

## Run ping command on dev env

```bash
ansible -i inventory/dev all -m ping
```

## Run ping command on prod env

```bash
ansible -i inventory/prod all -m ping
```

## Run ping command on dev env with webserver group

```bash
ansible -i inventory/dev webserver -m ping
```

## Check the variable locale value

```bash
ansible -i inventory/dev all -m debug -a "var=locale"
```
