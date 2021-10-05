# Steps

Create docker network:

`docker network create mynetwork`

Start Node Exporter:

`docker run -d  --network mynetwork -p 9100:9100 --name node-exporter -v "/:/host:ro,rslave"   quay.io/prometheus/node-exporter:latest   --path.rootfs=/host`

Create Prometheus config `prometheus.yml` as follows.
```
global:
  scrape_interval: 5s
  external_labels:
    monitor: 'node'
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.68.127:9090'] ## IP Address of the localhost
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['192.168.68.127:9100'] ## IP Address of the localhost
```

Start Prometheus:

`docker run -d --network mynetwork  --name prometheus -p 9090:9090 -v /home/user/k8slearn/prometheus-docker/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus`


Acess node exporter at 

`http://localhost:9100/`

Access prometheus at 

`http://localhost:9090/`


Try the following metrics in Prometheus
- node_memory_MemAvailable_bytes
- node_memory_MemTotal_bytes 
- node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

Run Grafana:

`docker run -d --network mynetwork --name=grafana -p 3000:3000 grafana/grafana`

Access localhost:3000. the username and password is `admin`.

Add your data source->select prometheus. Set the URL to be `http://prometheus:9090`. Test and Save the data source.


Visit the Explore page in Grafana  Create a dashboard to show the total and available memory of the nodes (in Gigabytes) using the following metric

- node_memory_MemAvailable_bytes/(1024*1024*1024)
- node_memory_MemTotal_bytes/(1024*1024*1024)


In Grafana, import the dashboard `1860` into your Grafana.  The details about the dashboard: https://grafana.com/grafana/dashboards/1860

# MySQL Exporter

Required grants
```
CREATE USER 'exporter'@'localhost' IDENTIFIED BY '12345';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'localhost';
GRANT SELECT ON performance_schema.* TO 'exporter'@'localhost';
```

docker run -d -p 9104:9104 --link=my_mysql_container:bdd  \
        -e DATA_SOURCE_NAME="user:password@(bdd:3306)/database" prom/mysqld-exporter

Access localhost:9104

https://grafana.com/grafana/dashboards/6239
https://grafana.com/grafana/dashboards/14057
https://grafana.com/grafana/dashboards/4031

# Reference

- https://www.youtube.com/watch?v=83LWo7h_hvs
- https://stackoverflow.com/questions/48835035/average-memory-usage-query-prometheus
- https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-2-c869581e9f29
- https://hub.docker.com/r/prom/mysqld-exporter
- https://severalnines.com/database-blog/how-monitor-mysql-containers-prometheus-deployment-standalone-and-swarm-part-one


# others

appStarts_total{job="shinyproxy"}[15m]