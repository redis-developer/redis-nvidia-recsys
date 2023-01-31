- hosts: localhost
  connection: local
  tasks:
    - name: Import Grafana dashboard RE Cluster
      grafana_dashboard:
        grafana_url: "${grafana_url}"
        url_username: admin
        url_password: "secret"
        state: present
        overwrite: yes
        path: /tmp/cluster.json

    - name: Import Grafana dashboard RE Node
      grafana_dashboard:
        grafana_url: "${grafana_url}"
        url_username: admin
        url_password: "secret"
        state: present
        overwrite: yes
        path: /tmp/node.json

    - name: Import Grafana dashboard RE Database
      grafana_dashboard:
        grafana_url: "${grafana_url}"
        url_username: admin
        url_password: "secret"
        state: present
        overwrite: yes
        path: /tmp/database.json