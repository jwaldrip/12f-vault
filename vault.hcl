backend "etcd" {
  address = "ETCD_ADDRESS"
  path = "vault/"
}

listener "tcp" {
  address = "VAULT_ADDRESS"
  tls_disable = 1
  # tls_cert_file = /path/to/cert/file
  # tls_key_file = /path/to/key/file
  # tls_min_version = tls12
}
