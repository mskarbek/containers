#/etc/default/grub
#GRUB_CMDLINE_LINUX="rd.luks.uuid= systemd.unified_cgroup_hierarchy=1 psi=1"
#grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
#setsebool container_manage_cgroup on


#dnf -y \
#    --installroot=/var/cache/proxy \
#    --releasever=8.4 \
#    --setopt=module_platform_id=platform:el8 \
#    --setopt=install_weak_deps=false \
#    --nodocs \
#    makecache


zfs create -o mountpoint=legacy f6191baf-fb6c-4937-ba65-8b8bf6b658e1/datafs/var/lib/volumes/240e3b42-e352-11eb-8fe4-c8d9d235d84b
podman volume create --opt type=zfs --opt device=f6191baf-fb6c-4937-ba65-8b8bf6b658e1/datafs/var/lib/volumes/240e3b42-e352-11eb-8fe4-c8d9d235d84b 240e3b42-e352-11eb-8fe4-c8d9d235d84b
podman run -d --network cni1 --ip 192.168.123.1 --name bootstrap01 --privileged -v 240e3b42-e352-11eb-8fe4-c8d9d235d84b:/var/lib/containers:z -v /tmp/id_ed25519.pub:/root/.ssh/authorized_keys 10.88.0.249:8082/bootstrap:2021.07.19-1


#curl -X 'GET' \
#  'http://10.88.0.249:8081/service/rest/v1/security/ssl?host=cdn.redhat.com&port=443' \
#  -H 'accept: application/json'
#
#  {
#  "expiresOn": 1667566464000,
#  "fingerprint": "83:5B:D6:2C:50:58:79:A9:BB:17:22:5E:75:4D:41:CF:5B:68:D4:69",
#  "id": "83:5B:D6:2C:50:58:79:A9:BB:17:22:5E:75:4D:41:CF:5B:68:D4:69",
#  "issuedOn": 1604494464000,
#  "issuerCommonName": "Red Hat Entitlement Operations Authority",
#  "issuerOrganization": "Red Hat, Inc.",
#  "issuerOrganizationalUnit": "Red Hat Network",
#  "pem": "-----BEGIN CERTIFICATE-----\nMIIGaTCCBFGgAwIBAgICAewwDQYJKoZIhvcNAQELBQAwgbExCzAJBgNVBAYTAlVT\nMRcwFQYDVQQIDA5Ob3J0aCBDYXJvbGluYTEWMBQGA1UECgwNUmVkIEhhdCwgSW5j\nLjEYMBYGA1UECwwPUmVkIEhhdCBOZXR3b3JrMTEwLwYDVQQDDChSZWQgSGF0IEVu\ndGl0bGVtZW50IE9wZXJhdGlvbnMgQXV0aG9yaXR5MSQwIgYJKoZIhvcNAQkBFhVj\nYS1zdXBwb3J0QHJlZGhhdC5jb20wHhcNMjAxMTA0MTI1NDI0WhcNMjIxMTA0MTI1\nNDI0WjBxMQswCQYDVQQGEwJVUzEXMBUGA1UECAwOTm9ydGggQ2Fyb2xpbmExFjAU\nBgNVBAoMDVJlZCBIYXQsIEluYy4xGDAWBgNVBAsMD1JlZCBIYXQgTmV0d29yazEX\nMBUGA1UEAwwOY2RuLnJlZGhhdC5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw\nggIKAoICAQDSIdv3RTfeq9xCyZs150tUPr4vp3muYKA6CMBkNTZ8xOwbi1KIsY2P\naW879DMk4rCoq9ZsFz7krIDojEpe9A80avHRb/kz897JOZTAvVl6t3UFoL5anpCQ\n8jeeJCXuCySAykNRx5LBOHcqjQCilMcREPrXAu7fBT3zW5sLIJjfLzX86jp1IPgK\n+yHPnvmfo5qpoGRZ5T3QH7hR3cXZaLatkqbyEDsxA5K1TUR5mwcVc1IHc4zPY9AF\nOlXgsDjHZYSNQ4XH9s/4Yjot6GSZ+vls2V3XykVNSzkZG24l+/nnGQPEIaT9BXaT\nKn8BLLHcztTQcgTthnO9IOSpZSYLBW9mRlwJnn6WRFpCfkdmge58U9EzaHTpSKxz\nB5Aljqcys947KJnfbsbvyOb8cIIVKPW6QctRBimFN9ej1UVbCFXPKJAaNKc5+F8Z\nOt/ZhxYWEI+oZhZ4r7BZQp2lYTW/6E4MZkP2tg4Xszc0o6C5xVvk6CbqPLtGoJD9\nsWJCOYqYHtJYrOJsNLqsMTddxjeRwOEHd1GXnfLLKFATZCX4vsZgyilFjmW4Uffy\njZn+0a4KMm4cLOkPJJxEFfFUHtrRQ1BouwZ5Nl5z9x86aT+uovAXiOiNLGgpX0Nb\nnmzevv3lxjh5wYM7Q7g7P8iiy+kmZHei1bHTUZTNPQKqJcXrOLSE/QIDAQABo4HJ\nMIHGMAkGA1UdEwQCMAAwHQYDVR0OBBYEFNvkRa7Gp7pcXrzzrBCb1gh4TMhyMB8G\nA1UdIwQYMBaAFMRJeFZFnR4sYWDDZktYBTcvAyJ7MDgGCCsGAQUFBwEBBCwwKjAo\nBggrBgEFBQcwAYYcaHR0cDovL29jc3AucmhzbS5yZWRoYXQuY29tLzA/BgNVHREE\nODA2ghNzdGFnZWNkbi5yZWRoYXQuY29tgg9jZG42LnJlZGhhdC5jb22CDmNkbi5y\nZWRoYXQuY29tMA0GCSqGSIb3DQEBCwUAA4ICAQA3+BADPv2kReg8K2cPAc1DNKmB\nwS14E+4vUGnlKkXvKAhrdAAwaGlrlbcqyQlPBankR2OWcsbD8JoIf/CVo0YVuazm\nO9fARgr9qm+Mmv8T3DXeSKC0d1SEMsOPJr9XAteJUNl77f1YpQ7fSt3iQiFq3TWj\nyyTpC4usHEka6fc2gewC+kSciOI7SR1r6IqEymzbBRXXYnSj1Ix0+HL68A/zmnMY\nZMmM7X88tkA2SlXAgujG1n8/UD6AybwaidCArDn3eZXHOH/Gv+JidMfkp0NfNizS\nMUpUbMP2OB0oHCq76gbyLCIZOv7Avl0Ik0TlWptgOKm/1z08tvRR+OFX2mxRM3gn\n/ERpRn7UOBapzoSoBQDaPBRYslGw4wxPOj1iH1v1FKTgl2fi/Ed2i9wvy1xQHSVD\nJY9JUCKVRjIoqwWom2EgX6I3ksYxLXCRkN5PGfVFFk+HP1jdZUHUum9D0WMyd36C\ndmMOZqw4R+piLAZwU1a6e5ET8NbWfPMe8eQ9D9ZVEQszJyzboLsYcFIPu42tfZSd\n1jTRG+Hcr70Hs4YfKAmlDhaeGHXwyZoN1wPmJAc/9am3aCdyEOf9iIp2G/ixOXXg\nY6BdhnMKY0P1zCmzwsgbr6SWPz40+3UYyaDm1XjjuAtFyGLmGYEaOc1QAVzZK+Mx\nfaEW9mhjU/ixacS/nA==\n-----END CERTIFICATE-----\n",
#  "serialNumber": "492",
#  "subjectCommonName": "cdn.redhat.com",
#  "subjectOrganization": "Red Hat, Inc.",
#  "subjectOrganizationalUnit": "Red Hat Network"
#}
#
#
#curl -X 'POST' \
#  'http://10.88.0.249:8081/service/rest/v1/security/ssl/truststore' \
#  -H 'accept: application/json' \
#  -H 'Content-Type: application/json' \
#  -d ''
