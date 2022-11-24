# gitlab
GitLab has the worst possible installation method ever - an RPM package that violates every possible RPM rule. Omnibus is a shitshow, so we have to force the installation with `--noscripts` manually through `rpm` instead of a normal `dnf` installation from repo. Reconfiguration of the GitLab mess is delayed to the first start of a container and is controlled by `gitlab-reconfigure.service` unit file.
To chose between CE and EE version, update `GITLAB_TYPE` env in `./files/VERSIONS` to `ce` or `ee`.

To properly start container, we must provide `gitlab.rb` configuration file. Minimal required contains `external_url` and`package['modify_kernel_parameters']` set to `false` - it is important because containers are not allowed to modify Kernel parameters and GitLab tries to be smart during reconfiguration and mess with them a little.

As a reference:
* official image config: https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/docker/assets/gitlab.rb
* official config template: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template

### Image configuration
* From: [`openssh`](../openssh/README.md)
* Command: N/A
* Envs: N/A
* Volumes:
    * `/etc/gitlab`
    * `/var/log/gitlab`
    * `/var/opt/gitlab`
* Secrets:
    * `gitlab-password` - Gitlab will use it as a `root` password, file with one env - `GITLAB_ROOT_PASSWORD`

### Running
GitLab requires `gitlab.rb` configuration file and `gitlab-password` secret.
OpenSSH requires `CAP_AUDIT_WRITE` which means that `--cap-add=AUDIT_WRITE` is needed to properly start container.

#### Example
```bash
mkdir -p /srv/gitlab-container/etc

cat << EOF > /srv/gitlab-container/etc/gitlab.rb
external_url "http://gitlab.example.com"
package['modify_kernel_parameters'] = false
EOF

printf "GITLAB_ROOT_PASSWORD=password123"|podman secret create gitlab-password -

podman run -d\
 -v /srv/gitlab-container/etc:/etc/gitlab:Z\
 --name=gitlab\
 --cap-add=AUDIT_WRITE\
 --secret=gitlab-password,type=mount\
 <REGISTRY_URL>/gitlab:latest
```
