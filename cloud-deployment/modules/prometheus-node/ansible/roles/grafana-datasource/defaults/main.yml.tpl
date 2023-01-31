---
grafana_url: "${grafana_url}"
grafana_user: admin
grafana_password: "secret"
org_id: "1"

data_source:
  - name: DS_PROMETHEUS1
    ds_type: "prometheus"
    ds_url: "${prometheus_url}"
    tls_skip_verify: true