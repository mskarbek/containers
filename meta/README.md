# meta

## RPM-GPG keys problem inside `installroot`
See https://bugzilla.redhat.com/show_bug.cgi?id=2039261

Manual import of required keys into rpm in installroot. 

Additionally you can modify the path to gpg keys directly from command line using --setopt.

```bash
dnf install --installroot=${TEMP_ROOT} --releasever=8 postgresql14-server postgresql14-contrib --setopt=pgdg-common.gpgkey=${TEMP_ROOT}/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
```
