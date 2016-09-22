# Vault-CoreOS

Vault, designed for Core-OS to be run via systemd / fleet, and configured with an etcd backend.

## Usage / Example Unit file

```
[Unit]
Description=Vault Service
Requires=docker.service
Requires=etcd2.service
After=docker.service
After=etcd2.service

[Service]
EnvironmentFile=/etc/environment
ExecStartPre=-/usr/bin/docker rm -f %p
ExecStartPre=/usr/bin/docker pull jwaldrip/vault-coreos
ExecStart=/usr/bin/docker run \
  --rm \
  --name %p \
  -e SERVICE_NAME=vault \
  -e ETCD_ADDRESS="http://${COREOS_PRIVATE_IPV4}:2379" \
  -e ETCD_ADVERTISE_ADDR="http://${COREOS_PRIVATE_IPV4}:8200" \
  -e VAULT_LISTEN="0.0.0.0:8200" \
  -e VAULT_TLS_DISABLE=1 \
  -p 8200:8200 \
  --cap-add IPC_LOCK \
  jwaldrip/vault-coreos
Restart=always
RestartSec=5

[X-Fleet]
Conflicts=%p@*.service
```

## Available Variables

#### ETCD_PATH
(optional) - The path within etcd where data will be stored. Defaults to "vault/".

#### ETCD_ADDRESS
(optional) - The address(es) of the etcd instance(s) to talk to. Can be comma separated list (protocol://host:port) of many etcd instances. Defaults to "http://localhost:2379" if not specified.

#### ETCD_SYNC
(optional) - Should we synchronize the list of available etcd servers on startup? This is a string value to allow for auto-sync to be implemented later. It can be set to "0", "no", "n", "false", "1", "yes", "y", or "true". Defaults to on. Set to false if your etcd cluster is behind a proxy server and syncing causes Vault to fail.

#### ETCD_USERNAME
(optional) Username to use when authenticating with the etcd server.

#### ETCD_PASSWORD
(optional) Password to use when authenticating with the etcd server.

#### ETCD_TLS_CA_FILE
(optional) The path to the CA certificate used for etcd communication. Defaults to system bundle if not specified.

#### ETCD_TLS_CERT_FILE
(optional) - The path to the certificate for etcd communication.

#### ETCD_TLS_KEY_FILE
(optional) - The path to the private key for etcd communication.

#### VAULT_ADDRESS
(optional) - The address to bind to for listening. This defaults to "127.0.0.1:8200".

#### VAULT_TLS_DISABLE
(optional) - If true, then TLS will be disabled. This will parse as boolean value, and can be set to "0", "no", "false", "1", "yes", or "true". This is an opt-in; Vault assumes by default that TLS will be used.

#### VAULT_TLS_CERT_FILE
(required unless disabled) - The path to the certificate for TLS.

#### VAULT_TLS_KEY_FILE
(required unless disabled) - The path to the private key for the certificate. This is reloaded via SIGHUP.

#### VAULT_TLS_MIN_VERSION
(optional) - If provided, specifies the minimum supported version of TLS. Accepted values are "tls10", "tls11" or "tls12". This defaults to "tls12". WARNING: TLS 1.1 and lower are generally considered less secure; avoid using these if possible.

#### VAULT_DISABLE_CACHE
(optional) - A boolean. If true, this will disable the read cache used by the physical storage subsystem. This will very significantly impact performance.

#### VAULT_DISABLE_MLOCK
(optional) - A boolean. If true, this will disable the server from executing the `mlock` syscall to prevent memory from being swapped to disk. This is not recommended in production.

#### VAULT_STATSITE_ADDRESS
(optional) - An address to a Statsite instances for metrics. This is highly recommended for production usage.

#### VAULT_STATSD_ADDRESS
 (optional) - This is the same as statsite_address but for StatsD.

#### VAULT_DISABLE_HOSTNAME
(optional) - Whether or not to prepend runtime telemetry with the machines hostname. This is a global option. Defaults to false.

#### VAULT_DEFAULT_LEASE_TTL
(optional) - Configures the default lease duration for tokens and secrets. This is a string value using a suffix, e.g. "720h". Default value is 30 days. This value cannot be larger than `VAULT_MAX_LEASE_TTL`.

#### VAULT_MAX_LEASE_TTL
(optional) - Configures the maximum possible lease duration for tokens and secrets. This is a string value using a suffix, e.g. "720h". Default value is 30 days.
