#!/usr/bin/env bash
set -e

# Set defaults
export VAULT_PORT=${VAULT_PORT-8200}
[[ "$VAULT_LISTENER_TCP_TLS_DISABLE" = "true" ]] && scheme="http" || scheme="https"
export VAULT_ADDR=${VAULT_ADDR-"$scheme://$(hostname -i):$VAULT_PORT"}

# Functions
config() {
  if ! echo "$@" | grep "\-config" > /dev/null ; then
    if ! getpcaps $$ 2>&1 | grep -o cap_ipc_lock > /dev/null ; then
      >&2 echo "WARNING: mlock is disabled, run docker with --cap-add IPC_LOCK to fix this."
      >&2 echo "         Running without mlock is not recommended for production."
      export VAULT_DISABLE_MLOCK=true
    fi
    export VAULT_REDIRECT_ADDR=${VAULT_REDIRECT_ADDR-"$scheme://$(hostname -i):$VAULT_PORT"}
    export VAULT_LISTENER_TCP_ADDRESS=${VAULT_LISTENER_TCP_ADDRESS-0.0.0.0:$VAULT_PORT}
    confd -onetime
    sed -i '/^\s*$/d' /usr/share/vault.hcl
    echo "-config /usr/share/vault.hcl $@"
  else
    echo "$@"
  fi
}

server() {
  if echo $@ | grep '\-dev' > /dev/null ; then
    unset VAULT_BACKEND
  fi
  exec vault server $(config $@)
}

case "$1" in
  bash)
    shift
    exec bash $@
  ;;
  config)
    config $@ > /dev/null
    if [ -f /usr/share/vault.hcl ]; then
      exec cat /usr/share/vault.hcl
    else
      echo 'No generated config...'
    fi
  ;;
  server)
    shift
    server $@
  ;;
  *)
    exec vault $@
  ;;
esac
