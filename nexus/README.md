# nginx
### Image configuration
* From: `systemd`
* Command: N/A
* Envs: N/A
* Volumes:
    * `/var/lib/sonatype-work`
* Secrets:
    * `nexus-password`

### Running
Nexus requires `nexus-password` secret.

#### Example
```bash
mkdir -p /srv/nexus-container/sonatype-work

printf "NEXUS_PASSWORD=password123"|podman secret create nexus-password -

podman run -d\
 -v /srv/nexus-container/sonatype-work:/var/lib/sonatype-work:Z\
 --name=nexus\
 --secret=nexus-password,type=mount\
 <REGISTRY_URL>/nexus:latest
```
