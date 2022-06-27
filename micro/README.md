# micro
Equivalent of [ubi9/ubi-micro](https://catalog.redhat.com/software/containers/ubi9/ubi-micro/615bdf943f6014fa45ae1b58), but slightly larger due to the fact of `ca-certificates` package installation (~53 MB comparing to ~39 MB). Its main function is to be the fundamental building block of all other containers in this collection.

`build.sh` will copy any PEM file from `./files` directory and rebuild CA database during container build, enabling inclusion of corporate root CA and removing the need of dealing with root CA in each individual container.

Container can be built in *normal* and *bootstrap* mode. Normal mode will also copy `./files/proxy.repo` file that will substitute all other repo files in future containers builds based on `micro` image. Bootstrap mode skips this step, assuming no proxy infrastructure exists yet and relies on host repo files.

### Image configuration
* From: `scratch`
* Command: `/usr/bin/bash`
* Envs:
    * `container=oci` - internal, helps systemd, otherwise irrelevant
* Volumes: N/A
* Secrets: N/A
