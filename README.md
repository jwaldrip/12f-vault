# Vault-CoreOS

docker container for vault with builtin etcd configuration.

## how to use?

```bash
$ docker pull brandfolder/vault-coreos
$ docker run -d brandfolder/vault-coreos \              
             -e ETCD_ADDRESS="http://${COREOS_PRIVATE_IPV4}:4001"
             -e ETCD_ADVERTISE="http://${COREOS_PRIVATE_IPV4}:8200"
             -e VAULT_ADDRESS="http://0.0.0.0:8200"
             -p 8200:8200 # specific binding used for advertisement
             --cap-add IPC_LOCK # this is important!
```

## basic configuration

```hcl
backend "etcd" {
  path = "vault/"
}

listener "tcp" {
  tls_disable = 1
}
```

## flags

When the the following environment variables are set, the configuration changes accordingly:

* `ETCD_ADDRESS`:  The address(es) of the etcd instance(s) to talk to. Can be comma separated list (protocol://host:port) of many etcd instances. Defaults to "http://localhost:2379" if not specified.
* `ETCD_ADVERTISE`: The address to advertise to other Vault servers in the cluster for request forwarding.
* `VAULT_ADDRESS`: The address to bind to for listening. This defaults to "127.0.0.1:8200".
