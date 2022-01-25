postgresql['shared_buffers'] = '1MB'
package['modify_kernel_parameters'] = false
external_url "http://git.ORG_URL"
#manage_accounts['enable'] = false

node_exporter['enable'] = false
letsencrypt['enable'] = false  
registry['enable'] = false
prometheus['enable'] = false
prometheus_monitoring['enable'] = false
alertmanager['enable'] = false
grafana['enable'] = false
gitlab_kas['enable'] = false
#redis['enable'] = false

gitlab_rails['registry_enabled'] = false
gitlab_rails['dependency_proxy_enabled'] = false
gitlab_rails['terraform_state_enabled'] = false
gitlab_rails['gitlab_kas_enabled'] = false
gitlab_rails['incoming_email_enabled'] = false
gitlab_rails['usage_ping_enabled'] = false
gitlab_rails['allowed_hosts'] = []
#gitlab_rails['trusted_proxies'] = [ '192.168.1.0/24', '192.168.2.1', '2001:0db8::/32' ]
#gitlab_rails['smtp_enable'] = true
#gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password')
