# Pavlov VR Server
Docker image to deploy a Pavlov VR Community Server

## Basic usage

```shell
# pull latest image
docker pull ihadeed/pavlov-server

# create Game.ini file with any text editor
# see http://wiki.pavlov-vr.com/index.php?title=Dedicated_server#Server_Configuration for more details
#
# example:
cat << EOF > Game.ini
[/Script/Pavlov.DedicatedServer]
bEnabled=true
ServerName="Pavlov VR"
MaxPlayers=24
bSecured=true
MapRotation=(MapId="datacenter", GameMode="SND")
MapRotation=(MapId="sand", GameMode="DM")
EOF

# run it in daemon mode, mount Game.ini, and expose required ports
# by default the image runs the server on port 7500
# you can override it with the PORT environment variable
docker run --name pavlov -d \
-p 7500:7500/udp \
-p 7900:7900/udp \
-e PORT=7500 \
-v $(pwd)/Game.ini:/home/steam/pavlovserver/Pavlov/Saved/Config/LinuxServer/Game.ini \
ihadeed/pavlov-server
```

#### Docker compose
Check the provided `docker-compose.yml` file in this repository for a example usage that only mounts `Game.ini` and `RconSettings.txt`.

#### Modifying item prices and stats
Mount the provided `BalancingTable.csv` to `/home/steam/pavlovserver/Pavlov/Content/BalancingTable.csv` and (re)start the server.

In case the provided file is ever out of date, you can retrieve an up to date version from the running docker container:

```shell
#
# assuming the container name is pavlov
# make sure that you don't have a file mounted at the BalancingTable.csv path so it reads the default file
docker exec pavlov cat /home/steam/pavlovserver/Pavlov/Content/BalancingTable.csv > BalancingTable.csv
```

- The buy menu in game will still display the normal prices and will restrict you from buying something you cannot afford
- Providing a negative price for an item would give you money when purchased
- Providing a negative armor damage value with 0 base damage would result in increasing the target armor instead of hitting them

#### Admins, whitelisting, blacklisting
Create the desired file (`mods.txt`, `whitelist.txt` and/or `blacklist.txt`) as [specified here](http://wiki.pavlov-vr.com/index.php?title=Dedicated_server#Admin.2FModerator_list) 
and mount it to the config directory.

#### Rcon
Edit the provided `RconSettings.txt` file or create your own. Make sure to expose the TCP port that you specify in that file. 

#### Updating server config
If you modify any of the configuration files and wish to restart the server to apply them, here are a few options:
```shell
# Fastest method is to restart the same container
# This will retain any temporary data the game downloaded (custom maps)
# 
# Docker example:
docker restart pavlov
#
# Docker compose example:
docker-compose restart pavlov

# Recreate the container
# This will spin up a fresh new container with no extras
# 
# First we need to remove the existing one, then recreate it using the initial command we used
# 
# Docker example:
docker rm pavlov
docker run --name pavlov ... # rest of arguements here
#
# Docker compose example:
docker-compose up --force-recreate -t 1
```

#### Updating the server game files
When an update is released, check this docker image to see if it has been re-built. If so, you can pull the image again and restart the server to deploy the latest version.

To pull latest image run this command:
```shell
# With docker
docker pull ihadeed/pavlov-vr-server

# With docker compose (must be ran in same directory that contains docker-compose.yml)
docker-compose pull
```

In case this image is out of date, restart the server and it will download any required updates automatically before running again.


#### Bonus tutorial
Here's a tutorial on how to setup an Ubuntu 18.04 server from scratch and get a server running:
```shell
#
# This guide assumes you are logged in to your server as a privilaged (root) user

# Update package repository
apt update -y

# Install docker & docker-compose
apt install -y docker.io docker-compose

# Ensure Docker service is enabled
# So it's always running, and auto-starts if server ever reboots
systemctl enable --now docker

# Docker should be running as soon as you install it.
# We can verify that with one of the following commands:

# This checks that the service is running
systemctl status docker

# This lists the running apps/containers. List should be empty
# It will display an error if docker is having issues
docker ps

# Let's make a directory where we will keep config files for our server
# We can later copy this directory & modify the settings if we want multiple servers
mkdir pavlov-server

cd pavlov-server

# Pull the docker-compose.yml, Game.ini, and RconSettings.txt files provided in this repo
curl -sO https://raw.githubusercontent.com/ihadeed/pavlov-vr-server/master/docker-compose.yml
curl -sO https://raw.githubusercontent.com/ihadeed/pavlov-vr-server/master/Game.ini
curl -sO https://raw.githubusercontent.com/ihadeed/pavlov-vr-server/master/RconSettings.txt

# Edit Game.ini using your favorite text editor to change the server settings
# examples:
# vim Game.ini
# nano Game.ini

# Edit RconSettings.txt and change the password, change the port too if you prefer (if you're running multiple servers on the same host)
# vim RconSettings.txt
# nano RconSettings.txt

# Start up the server
docker-compose up -d

# To read logs:
docker-compose logs pavlov

# To read last 20 lines of logs, and print all new logs:
docker-compose logs -f --tail=20 pavlov 

# To see all options available for viewing logs:
docker-compose logs --help

#
# Your server may or may not have a firewall enabled by default. 
# It is a good idea to enable the firewall to restrict access to some ports (like SSH + Rcon).
#
# Assuming your hosting provider isn't using an external firewall and is relying on the OS to do it,
# the chances are UFW is being used.
# 
# To check if UFW is enabled, run:
ufw status
 
# The first line of the output should indicate whether it's active or inactive
#
# If UFW is inactive and you wish to keep it that way, you're done! no need to read the remaining of this guide.
# Your server should be visible in game shortly after you ran `docker-compose up -d` command.

#
# It's important that you allow access to port 22 before enabling the firewall,
# so you can remain connected to server & be able to access it later on.
# 
# You can allow access to port 22 to all ports, but it's recommended to whitelist your IP address only (in case it's static).
# Example if my IP was 160.100.100.1:
# $ ufw allow from 160.100.100.1 to any port 22
# 
# To allow any port to connect:
ufw allow 22

#
# You can configure Rcon port the same way as SSH
# 
# For example:
ufw allow from 160.100.100.1 to any port 15200

# 
# You need to allow everyone to access the ports that the game server is using
# There are two ports that you need to enable for each server.
#
# You can either enable them individually like so:
ufw allow 7500/udp
ufw allow 7900/udp

# Or enable a range of IP address if you're planning on deploying multiple servers later on
# We can allow traffic to all ports between 7500 and 8000
# This lets us deploy up to 100 servers that use ports in a sequencial order
# (Don't try to deploy 100 servers on the same machine.. not going to happen)
ufw allow 7500:8000/udp

# Once you're done configuring your firewall
# Run this command if it was disabled before:
ufw enable

# and run this if it was already enabled:
ufw reload
```
