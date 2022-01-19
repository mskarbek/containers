# kuma-dp
Kuma data plane image by its own provide no value. It is used as a sidecar for other services in podman pod. `address` in `networking` section of `dataplane.yaml` needs to be set to the IP of pod, so we need to either statically set IP of such pod during its creation or inspect infra container to determine its address if we chose to rely on CNI configuration.

### Image configuration
* From: [`systemd`](../systemd/README.md)
* Command: N/A
* Envs: N/A
* Volumes:
    * `/etc/kuma`
    * `/var/log/kuma`
* Secrets:
    * `kuma-token`
    * `kuma-config` - file with one env - `KUMA_CP_ADDRESS`

### Running
Kuma DP requires `dataplane.yaml` in `/etc/kuma` and corresponding token provided by `kuma-token` secret.

#### Example
```bash
mkdir -p /srv/kuma-container/etc

kumactl generate dataplane-token --name=redis|podman secret create kuma-token -
printf KUMA_CP_ADDRESS=https://10.88.0.2:5678/|podman secret create kuma-config -

cat << EOF > /srv/kuma-container/etc/dataplane.yaml
type: Dataplane
mesh: default
name: redis
networking: 
  address: 10.88.0.3
  inbound: 
    - port: 16379
      servicePort: 26379
      serviceAddress: 127.0.0.1
      tags: 
        kuma.io/service: redis
        kuma.io/protocol: tcp
EOF

podman pod create --name=redis-pod --ip=10.88.0.3
podman run -d\
 --pod=redis-pod
 --name=redis-app
 <REGISTRY_URL>/redis:latest

podman run -d\
 -v /srv/kuma-container/etc:/etc/kuma:Z\
 --pod=redis-pod
 --name=kuma-dp\
 --secret=kuma-token,type=mount\
 --secret=kuma-config,type=mount\
 <REGISTRY_URL>/kuma-cp:latest
```
