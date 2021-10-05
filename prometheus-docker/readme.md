# Steps

Create a docker network for communication between the different containers.

`docker network create mynetwork`

Start the Node Exporter container.

`docker run -d  --network mynetwork -p 9100:9100 --name node-exporter -v "/:/host:ro,rslave"   quay.io/prometheus/node-exporter:latest --path.rootfs=/host`

Create the following Prometheus config file `prometheus.yml` which specify the metric endpoints to be scrapped and the scrape intervals.


```
global:
  scrape_interval: 5s
  external_labels:
    monitor: 'node'
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090'] 
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100'] 
  - job_name: 'mysql-exporter'
    static_configs:
      - targets: ['mysql-exporter:9104'] 
```

Start Prometheus:

`docker run -d --network mynetwork  --name prometheus -p 9090:9090 -v /home/user/k8slearn/prometheus-docker/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus`


Access the metrics exposed by the node exporter at 

```
http://localhost:9100/
```

Access Prometheus at 

```
http://localhost:9090/
```


Try the following metrics in Prometheus
- node_memory_MemAvailable_bytes
- node_memory_MemTotal_bytes 
- node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes


Run Grafana:

```
docker run -d --network mynetwork --name=grafana -p 3000:3000 grafana/grafana
```

Access localhost:3000. The username and password is `admin`.

Add your data source->select prometheus. Set the URL to be `http://prometheus:9090`. Test and Save the data source.


Visit the Explore page in Grafana  Create a dashboard to show the total and available memory of the nodes (in Gigabytes) using the following metric

- node_memory_MemAvailable_bytes/(1024*1024*1024)
- node_memory_MemTotal_bytes/(1024*1024*1024)


In Grafana, import the dashboard `1860` into your Grafana.  The details about the dashboard is available at https://grafana.com/grafana/dashboards/1860.

# MySQL Exporter

Start a MySQL 8 database server container.

```
docker run -d --name mysql8 --network mynetwork -e MYSQL_ROOT_PASSWORD=12345 mysql:8
```


The mysqld exporter requires a MySQL user to be used for monitoring purposes. 

Connect to the MySQL server:

```
docker exec -it mysql8 mysql -u root -p12345
```

Create the user `exporter` and grant permission to the user.

```
CREATE USER 'exporter'@'%' IDENTIFIED BY '12345';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'%';
```

Exit the mysql command line tool.

```
exit
```

Run the mysqld exporter.

```
docker run -d --name mysql-exporter --network mynetwork -p 9104:9104 -e DATA_SOURCE_NAME="exporter:12345@(mysql8:3306)/" prom/mysqld-exporter
```

Visit `localhost:9104` to access the metrics exposed by the mysqld exporter.

In Grafana, import the following dashboard in Grafana using the dashboard IDs.
- https://grafana.com/grafana/dashboards/6239
- https://grafana.com/grafana/dashboards/14057
- https://grafana.com/grafana/dashboards/4031

# References

- How Prometheus Monitoring works | Prometheus Architecture explained 
  - https://www.youtube.com/watch?v=h4Sl21AKiDg
- Docker Dashboard Using Grafana, Prometheus & Node Exporter
  - https://www.youtube.com/watch?v=83LWo7h_hvs
- How to Monitor MySQL Containers with Prometheus
  - https://severalnines.com/database-blog/how-monitor-mysql-containers-prometheus-deployment-standalone-and-swarm-part-one
- Prometheus querying basics
  - https://prometheus.io/docs/prometheus/latest/querying/basics/
