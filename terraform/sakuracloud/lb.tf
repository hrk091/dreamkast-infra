resource sakuracloud_proxylb_acme "uploader" {
  proxylb_id        = sakuracloud_proxylb.uploader.id
  accept_tos        = true
  common_name       = "uploader.cloudnativedays.jp"
  subject_alt_names = ["uploader.cloudnativedays.jp"]
  update_delay_sec  = 120
  depends_on = [
    aws_route53_record.uploader
  ]
}

resource "sakuracloud_proxylb" "uploader" {
  name           = "uploader"
  plan           = 500
  vip_failover   = true
  sticky_session = true
  gzip           = true
  proxy_protocol = true
  timeout        = 10
  region         = "is1"

  health_check {
    protocol    = "http"
    delay_loop  = 10
    host_header = "uploader.cloudnativedays.jp"
    path        = "/"
  }

  bind_port {
    proxy_mode = "http"
    port       = 80
    response_header {
      header = "Cache-Control"
      value  = "public, max-age=10"
    }
  }

  server {
    ip_address = sakuracloud_server.uploader.ip_address
    port       = 80
    group      = "group1"
  }

  rule {
    host  = "uploader.cloudnativedays.jp"
    path  = "/"
    group = "group1"
  }

  description = "LB for uploader"
  tags        = ["app=uploader", "stage=production"]
}
