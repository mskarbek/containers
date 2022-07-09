# discosrv

## Configuration
```
-cert=<file>
    Certificate file (default “./cert.pem”).
-db-dir=<string>
    Database directory, where data is stored (default “./discovery.db”).
-debug
    Enable debug output.
-http
    Listen on HTTP (behind an HTTPS proxy).
-key=<file>
    Key file (default “./key.pem”).
-listen=<address>
    Listen address (default “:8443”).
-metrics-listen=<address>
    Prometheus compatible metrics endpoint listen address (default disabled).
-replicate=<peers>
    Replication peers, id@address, comma separated
-replication-listen=<address>
    Listen address for incoming replication connections (default “:19200”).
```

Write `OPTS=""` into `/etc/stdiscosrv/ENV` with desired set of configuration.

`OPTS="-db-dir=/var/lib/stdiscosrv -http"`
