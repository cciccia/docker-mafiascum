# MafiaScum Docker
This container is meant to be used to develop/deploy the mafiascum.net codebase.

## Docker Setup
You will need to have docker installed to use this container. Setup instructions for various operating systems can be found [here](https://docs.docker.com/engine/installation/). Fair warning, this has only been tested on Docker for linux. I cannot confirm whether or not it will work under Windows and/or Mac OSX. **You only need to install Docker once!**

For reference, this is how I have setup docker under Ubuntu 16.04 LTS:
```bash
# Get required packages
sudo apt update
sudo apt install apt-transport-https ca-certificates

# Add the key and apt repo
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list

# Install additional requirements and the docker engine
sudo apt update
sudo apt install linux-image-extra-$(uname -r)
sudo apt install docker-engine

# Start Docker and configure it to start on boot
sudo service docker start
sudo systemctl enable docker

# Create a docker group and add yourself to it
sudo groupadd docker
sudo usermod -aG docker $USER

# Confirm docker is working
docker run hello-world
```
## Cloning
### Official Repo
If you want to use the official mafiascum repo the clone is fairly easy:
```bash
# Clone the main repo
git clone git@github.com:ccatlett2000/docker-mafiascum.git
cd docker-mafiascum

# Pull the official repo
git submodule init
git submodule update --remote
```

### Personal Repo
You probably want to use this to develop, so you'll need to know how to point it at your personal repo instead of the official one. In this example I'll be using my own copy.

```bash
# Clone the main repo
git clone git@github.com:ccatlett2000/docker-mafiascum.git
cd docker-mafiascum

# Add your personal repo
git config --file=.gitmodules submodule.src.url git@github.com:ccatlett2000/mafiascum.git

# Pull your personal repo
git submodule init
git submodule update --remote
```
After that you can make changes in `src/` just as if you had cloned the repo. You can also do git just like normal (commit, push, etc).

## Running
### MariaDB
You'll need an SQL server to point the forum at. I personally use [MariaDB](https://mariadb.org/), a fork of MySQL with some extra features. However, feel free to use MySQL instead here.
```bash
# Run the container
docker run -d --name mariadb -e MYSQL_ROOT_PASSWORD=examplepass mariadb:latest

# Import the base schema
curl -L http://www.mafiascum.net/downloads/ms_phpbb3_skeleton_20160414.sql.tar.gz | tar -xz -C /tmp/
echo "CREATE DATABASE IF NOT EXISTS ms_phpbb3; USE ms_phpbb3;" | cat - /tmp/ms_phpbb3.sql > /tmp/ms_phpbb3_fixed.sql
docker cp /tmp/ms_phpbb3_fixed.sql mariadb:/tmp/ms_phpbb3_fixed.sql
docker exec -it mariadb sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < /tmp/ms_phpbb3_fixed.sql'
```

### Webserver
You'll probably also want to run the webserver to access the website. This assumes you used the password 'examplepass' from the MariaDB example above. You'll need to change it if that isn't the case. You can also change what port it locally listens on.
```bash
# Build the webserver container
docker build -t mafiascum:localdev .

# Run the webserver container
docker run -d --name mafiascum -p 80:80 --link mariadb:mysql -e DB_HOST=mysql -e DB_PORT=3306 -e DB_NAME=ms_phpbb3 -e DB_USER=root -e DB_PASS=examplepass mafiascum:localdev

# Use the password 'differentpass' instead
docker run -d --name mafiascum -p 80:80 --link mariadb:mysql -e DB_HOST=mysql -e DB_PORT=3306 -e DB_NAME=ms_phpbb3 -e DB_USER=root -e DB_PASS=differentpass mafiascum:localdev

# Bind to localhost:8080 instead
docker run -d --name mafiascum -p 8080:80 --link mariadb:mysql -e DB_HOST=mysql -e DB_PORT=3306 -e DB_NAME=ms_phpbb3 -e DB_USER=root -e DB_PASS=examplepass mafiascum:localdev
```

## Tips
A collection of useful commands to help you out while developing.

### MariaDB Access
Just run this command to get a MariaDB console.
```bash
docker run -it --link mariadb:mysql --rm mariadb sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
```

### Updating the Webserver
Run these commands to update the webserver container.
```bash
docker rm -f mafiascum
docker build -t mafiascum:localdev .
```
Afterwards, just rerun it like you did the first time.

### Updating Shortcut
Rebuilding the container each update is annoying and time consuming. Using these commands you can just copy in the updates without rebuilding.
```bash
docker exec mafiascum rm -rf /var/www/html/
docker cp src/ mafiascum:/var/www/html/
```

## Cleanup
You can remove the containers by running:
```bash
docker rm -f mafiascum
docker rm -f mariadb
```
