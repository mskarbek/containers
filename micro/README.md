# micro
Equivalent of [ubi9/ubi-micro](https://catalog.redhat.com/software/containers/ubi9/ubi-micro/615bdf943f6014fa45ae1b58), but slightly larger due to the fact of `ca-certificates` package installation (~39.7 MB comparing to ~7.3 MB). Its main function is to be the fundamental building block of all other containers in this collection.

### Image configuration
* From: `scratch`
* Command: `/usr/bin/bash`
* Envs:
    * `container=oci` - internal, helps systemd, otherwise irrelevant
* Volumes: N/A
* Secrets: N/A
