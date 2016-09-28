# 12 Factor Vault

Vault, designed for 12 factor configuration inside a docker container.

## Running

Vault can be run with docker and configured with environment variables see
[server config](./SERVER_CONFIG.md) for reference.

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
