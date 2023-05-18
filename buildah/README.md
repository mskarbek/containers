# buildah
This image is configured to use ZFS as a `buildah` storage backend.

### Image configuration
* From: `systemd`
* Command: N/A
* Envs: N/A
* Volumes:
    * `/var/lib/containers/storage` - needs to be a ZFS dataset
* Secrets: N/A

### Running
#### Example
```bash
zfs create -o mountpoint=legacy <ZFS_POOL>/buildah-containers-strage

podman volume create --opt=type=zfs --opt=device=<ZFS_POOL>/buildah-containers-strage buildah-containers-strage

podman run -d\
 -v buildah-containers-strage:/var/lib/containers/storage:Z\
 --name=buildah\
 <REGISTRY_URL>/buildah:latest
```
