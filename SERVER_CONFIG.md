# Server Configuration

The following configuration is based off of the Vault [Server Configuration](https://www.vaultproject.io/docs/config/index.html)
and has been modified for 12-factor use by way of environment variables.

## Reference

* `VAULT_BACKEND` (required) - Configures the storage backend where Vault data
  is stored. There are multiple options available for storage backends,
  and they're documented below.

* `VAULT_HA_BACKEND` (optional) - Configures the storage backend where Vault HA
  coordination will take place. Must be an HA-supporting backend using the
  configuration options as documented below. If not set, HA will be attempted
  on the backend given in the `backend` parameter.

* `VAULT_CACHE_SIZE` (optional) - If set, the size of the read cache used
  by the physical storage subsystem will be set to this value, in bytes.
  Defaults to 1048576 (1MB).

* `VAULT_DISABLE_CACHE` (optional) - A boolean. If true, this will disable all caches
  within Vault, including the read cache used by the physical storage
  subsystem. This will very significantly impact performance.

* `VAULT_DISABLE_MLOCK` (optional) - A boolean. If true, this will disable the
  server from executing the `mlock` syscall to prevent memory from being
  swapped to disk. This is not recommended in production (see below).

* `VAULT_DEFAULT_LEASE_TTL` (optional) - Configures the default lease duration
  for tokens and secrets. This is a string value using a suffix, e.g. "720h".
  Default value is 30 days. This value cannot be larger than `max_lease_ttl`.

* `VAULT_MAX_LEASE_TTL` (optional) - Configures the maximum possible
  lease duration for tokens and secrets. This is a string value using a suffix,
  e.g. "720h". Default value is 30 days.

In production it is a risk to run Vault on systems where `mlock` is
unavailable or the setting has been disabled via the `VAULT_DISABLE_MLOCK`.
Disabling `mlock` is not recommended unless the systems running Vault only
use encrypted swap or do not use swap at all.  Vault only supports memory
locking on UNIX-like systems (Linux, FreeBSD, Darwin, etc).  Non-UNIX like
systems (e.g. Windows, NaCL, Android) lack the primitives to keep a process's
entire memory address space from spilling to disk and is therefore automatically
disabled on unsupported platforms.

In Docker, to give the Vault executable the ability to use the `mlock` syscall
by adding `--cap-add IPC_LOCK` to `docker run`

```shell
docker run --cap-add IPC_LOCK jwaldrip/12f-vault
```

## Listener Reference

The supported options are:

  * `VAULT_LISTENER_TCP_ADDRESS` (optional) - The address to bind to for listening. This
      defaults to "127.0.0.1:8200".

  * `VAULT_LISTENER_TCP_CLUSTER_ADDRESS` (optional) - The address to bind to for cluster
      server-to-server requests. This defaults to one port higher than the
      value of `address`, so with the default value of `address`, this would be
      "127.0.0.1:8201".

  * `VAULT_LISTENER_TCP_TLS_DISABLE` (optional) - If true, then TLS will be disabled.
      This will parse as boolean value, and can be set to "0", "no",
      "false", "1", "yes", or "true". This is an opt-in; Vault assumes
      by default that TLS will be used.

  * `VAULT_LISTENER_TCP_TLS_CERT_FILE` (required unless disabled) - The path to the certificate
      for TLS. To configure the listener to use a CA certificate, concatenate
      the primary certificate and the CA certificate together. The primary
      certificate should appear first in the combined file. This is reloaded
      via SIGHUP.

  * `VAULT_LISTENER_TCP_TLS_KEY_FILE` (required unless disabled) - The path to the private key
      for the certificate. This is reloaded via SIGHUP.

  * `VAULT_LISTENER_TCP_TLS_MIN_VERSION` (optional) - If provided, specifies
      the minimum supported version of TLS. Accepted values are "tls10", "tls11"
      or "tls12". This defaults to "tls12". WARNING: TLS 1.1 and lower
      are generally considered less secure; avoid using these if
      possible.

## Telemetry Reference

* `VAULT_TELEMETRY_STATSITE_ADDRESS` (optional) - An address to a [Statsite](https://github.com/armon/statsite)
  instance for metrics. This is highly recommended for production usage.

* `VAULT_TELEMETRY_STATSD_ADDRESS` (optional) - This is the same as `statsite_address` but
  for StatsD.

* `VAULT_TELEMETRY_DISABLE_HOSTNAME` (optional) - Whether or not to prepend runtime telemetry
  with the machines hostname. This is a global option. Defaults to false.

* `VAULT_TELEMETRY_CIRCONUS_API_TOKEN`
  A valid [Circonus](http://circonus.com/) API Token used to create/manage check. If provided, metric management is enabled.

* `VAULT_TELEMETRY_CIRCONUS_APP`
  A valid app name associated with the API token. By default, this is set to "consul".

* `VAULT_TELEMETRY_CIRCONUS_API_URL`
  The base URL to use for contacting the Circonus API. By default, this is set to "https://api.circonus.com/v2".

* `VAULT_TELEMETRY_CIRCONUS_SUBMISSION_INTERVAL`
  The interval at which metrics are submitted to Circonus. By default, this is set to "10s" (ten seconds).

* `VAULT_TELEMETRY_CIRCONUS_SUBMISSION_URL`
  The `check.config.submission_url` field, of a Check API object, from a previously created HTTPTRAP check.

* `VAULT_TELEMETRY_CIRCONUS_CHECK_ID`
  The Check ID (not **check bundle**) from a previously created HTTPTRAP check. The numeric portion of the `check._cid` field in the Check API object.

* `VAULT_TELEMETRY_CIRCONUS_CHECK_FORCE_METRIC_ACTIVATION`
  Force activation of metrics which already exist and are not currently active. If check management is enabled, the default behavior is to add new metrics as they are encountered. If the metric already exists in the check, it will **not** be activated. This setting overrides that behavior. By default, this is set to "false".

* `VAULT_TELEMETRY_CIRCONUS_CHECK_INSTANCE_ID`
  Serves to uniquely identify the metrics coming from this *instance*.  It can be used to maintain metric continuity with transient or ephemeral instances as they move around within an infrastructure. By default, this is set to hostname:application name (e.g. "host123:consul").

* `VAULT_TELEMETRY_CIRCONUS_CHECK_SEARCH_TAG`
  A special tag which, when coupled with the instance id, helps to narrow down the search results when neither a Submission URL or Check ID is provided. By default, this is set to service:app (e.g. "service:consul").

* `VAULT_TELEMETRY_CIRCONUS_BROKER_ID`
  The ID of a specific Circonus Broker to use when creating a new check. The numeric portion of `broker._cid` field in a Broker API object. If metric management is enabled and neither a Submission URL nor Check ID is provided, an attempt will be made to search for an existing check using Instance ID and Search Tag. If one is not found, a new HTTPTRAP check will be created. By default, this is not used and a random Enterprise Broker is selected, or, the default Circonus Public Broker.

* `VAULT_TELEMETRY_CIRCONUS_BROKER_SELECT_TAG`
  A special tag which will be used to select a Circonus Broker when a Broker ID is not provided. The best use of this is to as a hint for which broker should be used based on *where* this particular instance is running (e.g. a specific geo location or datacenter, dc:sfo). By default, this is not used.

## Backend Reference

The supported physical backends are shown below. Vault requires that the backend
itself will be responsible for backups, durability, etc. The backend can be set
using the `BACKEND` environment variable using any of the following values.

  * `consul` - Store data within [Consul](https://www.consul.io). This
    backend supports HA. It is the most recommended backend for Vault and has
    been shown to work at high scale under heavy load.

  * `etcd` - Store data within [etcd](https://coreos.com/etcd/).
    This backend supports HA. This is a community-supported backend.

  * `zookeeper` - Store data within [Zookeeper](https://zookeeper.apache.org/).
    This backend supports HA. This is a community-supported backend.

  * `dynamodb` - Store data in a [DynamoDB](https://aws.amazon.com/dynamodb/) table.
    This backend optionally supports HA. This is a community-supported backend.

  * `s3` - Store data within an S3 bucket [S3](https://aws.amazon.com/s3/).
    This backend does not support HA. This is a community-supported backend.

  * `azure` - Store data in an Azure Storage container [Azure](https://azure.microsoft.com/en-us/services/storage/).
    This backend does not support HA. This is a community-supported backend.

  * `swift` - Store data within an OpenStack Swift container [Swift](http://docs.openstack.org/developer/swift/).
    This backend does not support HA. This is a community-supported backend.

  * `mysql` - Store data within MySQL. This backend does not support HA. This
    is a community-supported backend.

  * `postgresql` - Store data within PostgreSQL. This backend does not support HA. This
    is a community-supported backend.

  * `inmem` - Store data in-memory. This is only really useful for
    development and experimentation. Data is lost whenever Vault is
    restarted.

  * `file` - Store data on the filesystem using a directory structure.
    This backend does not support HA.


#### High Availability Options

All HA backends support the following options. These are discussed in much more
detail in the [High Availability concepts
page](https://www.vaultproject.io/docs/concepts/ha.html).

  * `VAULT_REDIRECT_ADDR` (optional) - This is the address to advertise to other
    Vault servers in the cluster for client redirection.

  * `VAULT_BACKEND_HA_VAULT_ADDR` (optional) - This is the address to advertise to other Vault
    servers in the cluster for request forwarding. This can also be set via the
    `VAULT_CLUSTER_ADDR` environment variable, which takes precedence.

  * `VAULT_DISABLE_CLUSTERING` (optional) - This controls whether clustering features
    (currently, request forwarding) are enabled. Setting this on a node will
    disable these features _when that node is the active node_. In 0.6.1 this
    is `"true"` (note the quotes) by default, but will become `"false"` by
    default in the next release.

#### Backend Reference: Consul

For Consul, the following options are supported:

  * `VAULT_BACKEND_CONSUL_PATH` (optional) - The path within Consul where data will be stored.
    Defaults to "vault/".

  * `VAULT_BACKEND_CONSUL_ADDRESS` (optional) - The address of the Consul agent to talk to.
    Defaults to the local agent address, if available.

  * `VAULT_BACKEND_CONSUL_SCHEME` (optional) - "http" or "https" for talking to Consul.

  * `VAULT_BACKEND_CONSUL_CHECK_TIMEOUT` (optional) - The check interval used to send health check
    information to Consul.  Defaults to "5s".

  * `VAULT_BACKEND_CONSUL_DISABLE_REGISTRATION` (optional) - If true, then Vault will not register
    itself with Consul.  Defaults to "false".

  * `VAULT_BACKEND_CONSUL_SERVICE` (optional) - The name of the service to register with Consul.
    Defaults to "vault".

  * `VAULT_BACKEND_CONSUL_SERVICE_TAGS` (optional) - Comma separated list of tags that are to be
    applied to the service that gets registered with Consul.

  * `VAULT_BACKEND_CONSUL_TOKEN` (optional) - An access token to use to write data to Consul.

  * `VAULT_BACKEND_CONSUL_MAX_PARALLEL` (optional) - The maximum number of concurrent requests to Consul.
    Defaults to `"128"`.

  * `VAULT_BACKEND_CONSUL_TLS_SKIP_VERIFY` (optional) - If non-empty, then TLS host verification
    will be disabled for Consul communication.  Defaults to false.

  * `VAULT_BACKEND_CONSUL_TLS_MIN_VERSION` (optional) - Minimum TLS version to use. Accepted values
    are 'tls10', 'tls11' or 'tls12'. Defaults to 'tls12'.

The following settings should be set according to your [Consul encryption
settings](https://www.consul.io/docs/agent/encryption.html):

  * `VAULT_BACKEND_CONSUL_TLS_CA_FILE` (optional) - The path to the CA certificate used for Consul
    communication.  Defaults to system bundle if not specified.  Set
    accordingly to the
    [ca_file](https://www.consul.io/docs/agent/options.html#ca_file) setting in
    Consul.

  * `VAULT_BACKEND_CONSUL_TLS_CERT_FILE` (optional) - The path to the certificate for Consul
    communication.  Set accordingly to the
    [cert_file](https://www.consul.io/docs/agent/options.html#cert_file)
    setting in Consul.

  * `VAULT_BACKEND_CONSUL_TLS_KEY_FILE` (optional) - The path to the private key for Consul
    communication.  Set accordingly to the
    [key_file](https://www.consul.io/docs/agent/options.html#key_file) setting
    in Consul.

Once properly configured, an unsealed Vault installation should be available
on the network at `active.vault.service.consul`. Unsealed Vault instances in
the standby state are available at `standby.vault.service.consul`.  All
unsealed Vault instances are available as healthy in the
`vault.service.consul` pool. Sealed Vault instances will mark themselves as
critical to avoid showing up by default in Consul's service discovery.

#### Backend Reference: etcd (Community-Supported)

For etcd, the following options are supported:

  * `VAULT_BACKEND_ETCD_PATH` (optional) - The path within etcd where data will be stored.
    Defaults to "vault/".

  * `VAULT_BACKEND_ETCD_ADDRESS` (optional) - The address(es) of the etcd instance(s) to talk to.
    Can be comma separated list (protocol://host:port) of many etcd instances.
    Defaults to "http://localhost:2379" if not specified. May also be specified
    via the ETCD_ADDR environment variable.

  * `VAULT_BACKEND_ETCD_SYNC` (optional) - Should we synchronize the list of available etcd
    servers on startup?  This is a **string** value to allow for auto-sync to
    be implemented later. It can be set to "0", "no", "n", "false", "1", "yes",
    "y", or "true".  Defaults to on.  Set to false if your etcd cluster is
    behind a proxy server and syncing causes Vault to fail.

  * `VAULT_BACKEND_ETCD_USERNAME` (optional) - Username to use when authenticating with the etcd
    server.  May also be specified via the ETCD_USERNAME environment variable.

  * `VAULT_BACKEND_ETCD_PASSWORD` (optional) - Password to use when authenticating with the etcd
    server.  May also be specified via the ETCD_PASSWORD environment variable.

  * `VAULT_BACKEND_ETCD_TLS_CA_FILE` (optional) - The path to the CA certificate used for etcd
    communication.  Defaults to system bundle if not specified.

  * `VAULT_BACKEND_ETCD_TLS_CERT_FILE` (optional) - The path to the certificate for etcd
    communication.

  * `VAULT_BACKEND_ETCD_TLS_KEY_FILE` (optional) - The path to the private key for etcd
    communication.

#### Backend Reference: Zookeeper (Community-Supported)

For Zookeeper, the following options are supported:

  * `VAULT_BACKEND_ZOOKEEPER_PATH` (optional) - The path within Zookeeper where data will be stored.
    Defaults to "vault/".

  * `VAULT_BACKEND_ZOOKEEPER_ADDRESS` (optional) - The address(es) of the Zookeeper instance(s) to talk
    to. Can be comma separated list (host:port) of many Zookeeper instances.
    Defaults to "localhost:2181" if not specified.

The following optional settings can be used to configure zNode ACLs:

  * `VAULT_BACKEND_ZOOKEEPER_AUTH_INFO` (optional) - Authentication string in Zookeeper AddAuth format
    (`schema:auth`). As an example, `digest:UserName:Password` could be used to
    authenticate as user `UserName` using password `Password` with the `digest`
    mechanism.

  * `VAULT_BACKEND_ZOOKEEPER_ZNODE_OWNER` (optional) - If specified, Vault will always set all
    permissions (CRWDA) to the ACL identified here via the Schema and User
    parts of the Zookeeper ACL format. The expected format is
    `schema:user-ACL-match`. Some examples:
    * `digest:UserName:HIDfRvTv623G==` - Access for the user `UserName` with
      the corresponding digest `HIDfRvTv623G==`
    * `ip:127.0.0.1` - Access from localhost only
    * `ip:70.95.0.0/16` - Any host on the 70.95.0.0 network (CIDRs are
      supported starting from Zookeeper 3.5.0)

If neither of these is set, the backend will not authenticate with Zookeeper
and will set the OPEN_ACL_UNSAFE ACL on all nodes. In this scenario, anyone
connected to Zookeeper could change Vault’s znodes and, potentially, take Vault
out of service.

#### Backend Reference: DynamoDB (Community-Supported)

The DynamoDB optionally supports HA. Because Dynamo does not support session
lifetimes on its locks, a Vault node that has failed, rather than shut down in
an orderly fashion, will require manual cleanup rather than failing over
automatically. See the documentation of `recovery_mode` to better understand
this process. To enable HA, set the `ha_enabled` option.

The DynamoDB backend has the following options:

  * `VAULT_BACKEND_DYANMODB_TABLE` (optional) - The name of the DynamoDB table to store data in. The
    default table name is `vault-dynamodb-backend`. This option can also be
    provided via the environment variable `AWS_DYNAMODB_TABLE`. If the
    specified table does not yet exist, it will be created during
    initialization.

  * `VAULT_BACKEND_DYANMODB_READ_CAPACITY` (optional) - The read capacity to provision when creating
    the DynamoDB table. This is the maximum number of reads consumed per second
    on the table. The default value is 5. This option can also be provided via
    the environment variable `AWS_DYNAMODB_READ_CAPACITY`.

  * `VAULT_BACKEND_DYANMODB_WRITE_CAPACITY` (optional) - The write capacity to provision when creating
    the DynamoDB table. This is the maximum number of writes performed per
    second on the table. The default value is 5. This option can also be
    provided via the environment variable `AWS_DYNAMODB_WRITE_CAPACITY`.

  * `VAULT_BACKEND_DYANMODB_ACCESS_KEY` - (required) The AWS access key. It must be provided, but it
    can also be sourced from the `AWS_ACCESS_KEY_ID` environment variable.

  * `VAULT_BACKEND_DYANMODB_SECRET_KEY` - (required) The AWS secret key. It must be provided, but it
    can also be sourced from the `AWS_SECRET_ACCESS_KEY` environment variable.

  * `VAULT_BACKEND_DYANMODB_SESSION_TOKEN` - (optional) The AWS session token. It can also be sourced
    from the `AWS_SESSION_TOKEN` environment variable.

  * `VAULT_BACKEND_DYANMODB_TOKEN` - (optional) An alternative (AWS compatible) DynamoDB endpoint
    to use. It can also be sourced from the `AWS_DYNAMODB_ENDPOINT` environment
    variable.

  * `VAULT_BACKEND_DYANMODB_REGION` (optional) - The AWS region. It can be sourced from the
    `AWS_DEFAULT_REGION` environment variable and will default to `us-east-1`
    if not specified.

  * `VAULT_BACKEND_DYANMODB_MAX_PARALLEL` (optional) - The maximum number of concurrent requests to
    DynamoDB. Defaults to `"128"`.

  * `VAULT_BACKEND_DYANMODB_HA_ENABLED` (optional) - Setting this to `"1"`, `"t"`, or `"true"` will
    enable HA mode. Please ensure you have read the documentation for the
    `recovery_mode` option before enabling this. This option can also be
    provided via the environment variable `DYNAMODB_HA_ENABLED`. If you are
    upgrading from a version of Vault where HA support was enabled by default,
    it is _very important_ that you set this parameter _before_ upgrading!

  * `VAULT_BACKEND_DYANMODB_RECOVERY_MODE` (optional) - When the Vault leader crashes or is killed
    without being able to shut down properly, no other node can become the new
    leader because the DynamoDB table still holds the old leader's lock record.
    To recover from this situation, one can start a single Vault node with this
    option set to `"1"`, `"t"`, or `"true"` and the node will remove the old
    lock from DynamoDB. It is important that only one node is running in
    recovery mode! After this node has become the leader, other nodes can be
    started with regular configuration. This option can also be provided via
    the environment variable `RECOVERY_MODE`.

For more information about the read/write capacity of DynamoDB tables, see the
[official AWS DynamoDB
docs](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithTables.html#ProvisionedThroughput).
If you are running your Vault server on an EC2 instance, you can also make use
of the EC2 instance profile service to provide the credentials Vault will use
to make DynamoDB API calls. Leaving the `access_key` and `secret_key` fields
empty will cause Vault to attempt to retrieve credentials from the metadata
service.

#### Backend Reference: S3 (Community-Supported)

For S3, the following options are supported:

  * `VAULT_BACKEND_S3_BUCKET` (required) - The name of the S3 bucket to use. It must be provided, but it can also be sourced from the `AWS_S3_BUCKET` environment variable.

  * `VAULT_BACKEND_S3_ACCESS_KEY` - (required) The AWS access key. It must be provided, but it can also be sourced from the `AWS_ACCESS_KEY_ID` environment variable.

  * `VAULT_BACKEND_S3_SECRET_KEY` - (required) The AWS secret key. It must be provided, but it can also be sourced from the `AWS_SECRET_ACCESS_KEY` environment variable.

  * `VAULT_BACKEND_S3_SESSION_TOKEN` - (optional) The AWS session token. It can also be sourced from the `AWS_SESSION_TOKEN` environment variable.

  * `VAULT_BACKEND_S3_ENDPOINT` - (optional) An alternative (AWS compatible) S3 endpoint to use. It can also be sourced from the `AWS_S3_ENDPOINT` environment variable.

  * `VAULT_BACKEND_S3_REGION` (optional) - The AWS region. It can be sourced from the `AWS_DEFAULT_REGION` environment variable and will default to `us-east-1` if not specified.

If you are running your Vault server on an EC2 instance, you can also make use
of the EC2 instance profile service to provide the credentials Vault will use to
make S3 API calls.  Leaving the `access_key` and `secret_key` fields empty
will cause Vault to attempt to retrieve credentials from the metadata service.
You are responsible for ensuring your instance is launched with the appropriate
profile enabled. Vault will handle renewing profile credentials as they rotate.

#### Backend Reference: Azure (Community-Supported)

  * `VAULT_BACKEND_AZURE_ACCOUNT_NAME` (required) - The Azure Storage account name

  * `VAULT_BACKEND_AZURE_ACCOUNT_KEY`  (required) - The Azure Storage account key

  * `VAULT_BACKEND_AZURE_CONTAINER`   (required) - The Azure Storage Blob container name

  * `VAULT_BACKEND_AZURE_MAX_PARALLEL` (optional) - The maximum number of concurrent requests to Azure. Defaults to `"128"`.

The current implementation is limited to a maximum of 4 MBytes per blob/file.

#### Backend Reference: Swift (Community-Supported)

For Swift, the following options are supported:

  * `VAULT_BACKEND_SWIFT_CONTAINER` (required) - The name of the Swift container to use. It must be provided, but it can also be sourced from the `OS_CONTAINER` environment variable.

  * `VAULT_BACKEND_SWIFT_USERNAME` - (required) The OpenStack account/username. It must be provided, but it can also be sourced from the `OS_USERNAME` environment variable.

  * `VAULT_BACKEND_SWIFT_PASSWORD` - (required) The OpenStack password. It must be provided, but it can also be sourced from the `OS_PASSWORD` environment variable.

  * `VAULT_BACKEND_SWIFT_AUTH_URL` - (required) Then OpenStack auth endpoint to use. It can also be sourced from the `OS_AUTH_URL` environment variable.

  * `VAULT_BACKEND_SWIFT_TENANT` (optional) - The name of Tenant to use. It can be sourced from the `OS_TENANT_NAME` environment variable and will default to default tenant of for the username if not specified.

  * `VAULT_BACKEND_SWIFT_MAX_PARALLEL` (optional) - The maximum number of concurrent requests to Swift. Defaults to `"128"`.

#### Backend Reference: MySQL (Community-Supported)

The MySQL backend has the following options:

  * `VAULT_BACKEND_MYSQL_USERNAME` (required) - The MySQL username to connect with.

  * `VAULT_BACKEND_MYSQL_PASSWORD` (required) - The MySQL password to connect with.

  * `VAULT_BACKEND_MYSQL_ADDRESS` (optional) - The address of the MySQL host. Defaults to
    "127.0.0.1:3306.

  * `VAULT_BACKEND_MYSQL_DATABASE` (optional) - The name of the database to use. Defaults to "vault".

  * `VAULT_BACKEND_MYSQL_TABLE` (optional) - The name of the table to use. Defaults to "vault".

  * `VAULT_BACKEND_MYSQL_TLS_CA_FILE` (optional) - The path to the CA certificate to connect using TLS

#### Backend Reference: PostgreSQL (Community-Supported)

The PostgreSQL backend has the following options:

  * `VAULT_BACKEND_POSTGRESQL_CONNECTION_URL` (required) - The connection string used to connect to PostgreSQL.
  * `VAULT_BACKEND_POSTGRESQL_TABLE` (optional) - The name of the table to write vault data to. Defaults to "vault_kv_store".


#### Backend Reference: Inmem

The in-memory backend has no configuration options.

#### Backend Reference: File

The file backend has the following options:

  * `VAULT_BACKEND_FILE_PATH` (required) - The path on disk to a directory where the
      data will be stored.
