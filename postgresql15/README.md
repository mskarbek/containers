# postgresql15
### Image configuration
* From: `systemd`
* Command: N/A
* Envs: N/A
* Volumes:
    * `/var/lib/pgsql/15/data`
* Secrets:
    * `postgres-password`

### Running
PostgreSQL requires `postgres-password` secret.

#### Example
```bash
mkdir -p /srv/postgres-container/data

printf password123|podman secret create postgres-password -

podman run -d\
 -v /srv/postgres-container/data:/var/lib/pgsql/15/data:Z\
 --name=postgres\
 --secret=postgres-password,type=mount\
 <REGISTRY_URL>/postgresql15:latest
```
