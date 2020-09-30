create database wikimedia#! /bin/bash
apt update && apt -y install mysql-server
ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "s/127.0.0.1/$ip/g" /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart 
mysql --execute="create database wikimedia;"
mysql --execute="CREATE USER 'wikimedia_user'@'10.0.%'  IDENTIFIED BY 'TOXsib6k5d1qIZPd';"
mysql --execute="GRANT SELECT ,INSERT ,UPDATE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, LOCK TABLES, DELETE, ALTER ON "wikimedia".* TO 'wikimedia_user'@'10.0.%';"
