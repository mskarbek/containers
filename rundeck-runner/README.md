# rundeck-runner
### Image configuration
* From: [`openssh`](../systemd/README.md)
* Command: N/A
* Envs: N/A
* Volumes: N/A
* Secrets:
    * `root-pubkey` - public key that will be imported into `authorized_keys` for root, if not present skipped

### Running
OpenSSH requires `CAP_AUDIT_WRITE` which means that `--cap-add=AUDIT_WRITE` is needed to properly start container.

#### Example
```bash
podman secret create root-pubkey /home/<USER>/.ssh/id_ed25519.pub
podman run -d --name=rundeck-runner --cap-add=AUDIT_WRITE --secret=root-pubkey,type=mount <REGISTRY_URL>/rundeck-runner:latest
```
