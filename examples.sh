#!/bin/bash

echo 'This is a file with example commands inside, do NOT run it directly!'
exit

###
### Setup/Install
###

# Build the webserver container
docker build -t mafiascum:localdev .

# Setup MariaDB
docker run -d --name mariadb -e MYSQL_ROOT_PASSWORD=examplepass mariadb:latest

# Import the schema
curl -L http://www.mafiascum.net/downloads/ms_phpbb3_skeleton_20160414.sql.tar.gz | tar -xz -C /tmp/
echo "CREATE DATABASE IF NOT EXISTS ms_phpbb3; USE ms_phpbb3;" | cat - /tmp/ms_phpbb3.sql > /tmp/ms_phpbb3_fixed.sql
docker cp /tmp/ms_phpbb3_fixed.sql mariadb:/tmp/ms_phpbb3_fixed.sql
docker exec -it mariadb sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < /tmp/ms_phpbb3_fixed.sql'

# Run the webserver
docker run -d --name mafiascum -p 80:80 --link mariadb:mysql -e DB_HOST=mysql -e DB_PORT=3306 -e DB_NAME=ms_phpbb3 -e DB_USER=root -e DB_PASS=examplepass mafiascum:localdev




###
### Updating
###

docker rm -f mafiascum
docker build -t mafiascum:localdev .
docker run -d --name mafiascum -p 80:80 --link mariadb:mysql -e DB_HOST=mysql -e DB_PORT=3306 -e DB_NAME=ms_phpbb3 -e DB_USER=root -e DB_PASS=examplepass mafiascum:localdev




###
### Cleanup
###

# Stop and remove containers
docker rm -f mafiascum
docker rm -f mariadb

# Remove images
docker rmi mafiascum:localdev

# Remove files
rm /tmp/ms_phpbb3.sql /tmp/ms_phpbb3_fixed.sql
