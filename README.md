# Vault-CoreOS

Vault, designed for Core-OS to be run via systemd / fleet, and configured with an etcd backend.

## Running

Vault can be run with docker and configured with environment variables see
[SERVER_CONFIG](./SERVER_CONFIG.md) for reference.

The default command is `server` and will be passed the generated config.

```
docker run --env VAR=value jwaldrip/12f-vault
```

## Commands

### `server`

Server will execute the server command with the generated config.

### `config`

Config will print the generated configuration.

### `bash`

Bash will open a bash session in the container.

### Additional Commands
All other commands will be passed as arguments to vault. i.e. `status`
