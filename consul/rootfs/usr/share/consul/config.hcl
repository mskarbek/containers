node_name = "node1"
server    = true
bootstrap = true
ui_config {
  enabled = true
}
datacenter = "dc1"
data_dir   = "/var/lib/consul"
log_level  = "INFO"
addresses {
  http = "0.0.0.0"
}
