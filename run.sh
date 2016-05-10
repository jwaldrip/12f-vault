#!/bin/bash +x
config_file="/vault/vault.hcl"

# if the following keys are not set - let vault set the defaults!
keys=(
  "ETCD_ADVERTISE_ADDR"
  "ETCD_PATH"
  "ETCD_ADDRESS"
  "ETCD_SYNC"
  "ETCD_USERNAME"
  "ETCD_PASSWORD"
  "ETCD_TLS_CA_FILE"
  "ETCD_TLS_CERT_FILE"
  "ETCD_TLS_KEY_FILE"
  "VAULT_ADDRESS"
  "VAULT_TLS_DISABLE"
  "VAULT_TLS_CERT_FILE"
  "VAULT_TLS_KEY_FILE"
  "VAULT_TLS_MIN_VERSION"
  "VAULT_DISABLE_CACHE"
  "VAULT_DISABLE_MLOCK"
  "VAULT_DEFAULT_LEASE_TTL"
  "VAULT_STATSITE_ADDRESS"
  "VAULT_STATSD_ADDRESS"
  "VAULT_DISABLE_HOSTNAME"
  "VAULT_MAX_LEASE_TTL"
)

for key in "${keys[@]}" ; do
 val=`eval echo \\$$key` # evaluate the value of the key
 if [ -z "$val" ]; then
    sed -i "/$key/d" $config_file
 else
   sed -i "s#$key#$val#g" $config_file
 fi
done

if [ "$ETCD_ANNOUNCE" = "1" ] ; then
  while true ; do
    key = `echo "$ETCD_ADVERTISE_ADDR" | base64`
    (VAULT_ADDR=$ETCD_ADVERTISE_ADDR vault status &> /dev/null && curl "$ETCD_ADDRESS/v2/keys/$ETCD_ANNOUNCE_PATH/$key" -XPUT -d ttl=10 -d value="$ETCD_ADVERTISE_ADDR") || true
    sleep 5
  done &
fi

sed -i '/^$/d' $config_file
echo "# CONFIG #"
cat $config_file
echo "# END CONFIG #"
/usr/local/bin/vault server -config $config_file -log-level $VAULT_LOG_LEVEL
