CREATE USER 'exporter'@'%' IDENTIFIED BY '12345';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'%';