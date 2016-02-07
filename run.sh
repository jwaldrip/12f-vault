#!/bin/bash
config_file="/vault/vault.hcl"

# if the following keys are not set - let vault set the defaults!
keys=( "ETCD_ADDRESS" "VAULT_ADDRESS" "ETCD_ADVERTISE")

for key in "${keys[@]}"
do
   val=`eval echo \\$$key` # evaluate the value of the key
   if [ -z "$val" ]; then
      sed -i "/$key/d" $config_file
   else
     sed -i "s#$key#$val#g" $config_file
   fi
done

/usr/local/bin/vault server -config $config_file
