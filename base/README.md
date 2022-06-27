# base
Equivalent of [ubi9/ubi](https://catalog.redhat.com/software/containers/ubi9/ubi/615bcf606feffc5384e8452e), but built without `rpm` and `dnf`/`microdnf` packages, removing entirely package management from the image and reducing size (~140 MB comparing to ~235 MB). Build will prepare image for `systemd` enablement.

### Image configuration
* From: [`micro`](../micro/README.md)
* Command: N/A
* Envs: N/A
* Volumes: N/A
* Secrets: N/A
