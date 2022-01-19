# podman
This image is configured to use ZFS as a `podman` storage backend.

### Image configuration
* From: `systemd`
* Command: N/A
* Envs: N/A
* Volumes:
    * `/var/lib/containers/storage` - needs to be a ZFS dataset
    * `/var/lib/volumes/storage` - needs to be a ZFS dataset
* Secrets: N/A

### Running
#### Example
```bash
zfs create -o mountpoint=legacy <ZFS_POOL>/podman-containers-strage
zfs create -o mountpoint=legacy <ZFS_POOL>/podman-volumes-strage

podman volume create --opt=type=zfs --opt=device=<ZFS_POOL>/podman-containers-strage podman-containers-strage
podman volume create --opt=type=zfs --opt=device=<ZFS_POOL>/podman-volumes-strage podman-volumes-strage

podman run -d\
 -v podman-containers-strage:/var/lib/containers/storage:Z\
 -v podman-volumes-strage:/var/lib/volumes/storage:Z\
 --name=podman\
 <REGISTRY_URL>/podman:latest
```
