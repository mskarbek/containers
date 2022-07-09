# relaysrv

## Configuration
```
-debug
    Enable debug output.
-ext-address=<address>
    An optional address to advertising as being available on. Allows listening on an unprivileged port with port forwarding from e.g. 443, and be connected to on port 443.
-global-rate=<bytes/s>
    Global rate limit, in bytes/s.
-keys=<dir>
    Directory where cert.pem and key.pem is stored (default “.”).
-listen=<listen addr>
    Protocol listen address (default “:22067”).
-message-timeout=<duration>
    Maximum amount of time we wait for relevant messages to arrive (default 1m0s).
-nat
    Use UPnP/NAT-PMP to acquire external port mapping
-nat-lease=<duration>
    NAT lease length in minutes (default 60)
-nat-renewal=<duration>
    NAT renewal frequency in minutes (default 30)
-nat-timeout=<duration>
    NAT discovery timeout in seconds (default 10)
-network-timeout=<duration>
    Timeout for network operations between the client and the relay. If no data is received between the client and the relay in this period of time, the connection is terminated. Furthermore, if no data is sent between either clients being relayed within this period of time, the session is also terminated. (default 2m0s)
-per-session-rate=<bytes/s>
    Per session rate limit, in bytes/s.
-ping-interval=<duration>
    How often pings are sent (default 1m0s).
-pools=<pool addresses>
    Comma separated list of relay pool addresses to join (default “https://relays.syncthing.net/endpoint”). Blank to disable announcement to a pool, thereby remaining a private relay.
-protocol=<string>
    Protocol used for listening. ‘tcp’ for IPv4 and IPv6, ‘tcp4’ for IPv4, ‘tcp6’ for IPv6 (default “tcp”).
-provided-by=<string>
    An optional description about who provides the relay.
-status-srv=<listen addr>
    Listen address for status service (blank to disable) (default “:22070”). Status service is used by the relay pool server UI for displaying stats (data transferred, number of clients, etc.)
```

Write `OPTS=""` into `/etc/strelaysrv/ENV` with desired set of configuration.

`OPTS="-protocol=tcp4 -pool=''"`
