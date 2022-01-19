# base
Equivalent of [ubi8/ubi](https://catalog.redhat.com/software/containers/ubi8/ubi/5c359854d70cc534b3a3784e), but built without `rpm` and `dnf`/`microdnf` packages, removing entirely package management from the image and reducing size (~140 MB comparing to ~235 MB). Build will prepare image for `systemd` enablement.

### Image configuration
* From: [`micro`](../micro/README.md)
* Command: N/A
* Envs: N/A
* Volumes: N/A
* Secrets: N/A
