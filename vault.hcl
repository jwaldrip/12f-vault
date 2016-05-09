disable_cache     = VAULT_DISABLE_CACHE
disable_mlock     = VAULT_DISABLE_MLOCK
default_lease_ttl = "VAULT_DEFAULT_LEASE_TTL"
max_lease_ttl     = "VAULT_MAX_LEASE_TTL"

backend "etcd" {
  path           = "ETCD_PATH"
  advertise_addr = "ETCD_ADVERTISE_ADDR"
  address        = "ETCD_ADDRESS"
  sync           = "ETCD_SYNC"
  username       = "ETCD_USERNAME"
  password       = "ETCD_PASSWORD"
  tls_ca_file    = "ETCD_TLS_CA_FILE"
  tls_cert_file  = "ETCD_TLS_CERT_FILE"
  tls_key_file   = "ETCD_TLS_KEY_FILE"
}

listener "tcp" {
  address         = "VAULT_ADDRESS"
  tls_disable     = VAULT_TLS_DISABLE
  tls_cert_file   = "VAULT_TLS_CERT_FILE"
  tls_key_file    = "VAULT_TLS_KEY_FILE"
  tls_min_version = "VAULT_TLS_MIN_VERSION"
}

telemetry {
  statsite_address = "VAULT_STATSITE_ADDRESS"
  statsd_address   = "VAULT_STATSD_ADDRESS"
  disable_hostname = VAULT_DISABLE_HOSTNAME
}
