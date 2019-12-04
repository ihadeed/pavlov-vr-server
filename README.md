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
docker run --name pavlov -d -p 7500:7500 -v $(pwd)/Game.ini:/home/steam/pavlovserver/Pavlov/Saved/Config/LinuxServer/Game.ini ihadeed/pavlov-server
```

#### Docker compose
Check the provided `docker-compose.yml` file in this repository for example usage.

#### Modifying item prices and stats
Mount the provided `BalancingTable.csv` to `/home/steam/pavlovserver/Pavlov/Content/BalancingTable.csv` and (re)start the server.

In case the provided file is ever out of date, you can retrieve an up to date version from the running docker container:

```shell
# assuming the container name is pavlov
# make sure that you don't have a file mounted at the BalancingTable.csv path
docker exec pavlov cat /home/steam/pavlovserver/Pavlov/Content/BalancingTable.csv > BalancingTable.csv
```

- The buy menu in game will still display the normal prices and will restrict you from buying something you cannot afford
- Providing a negative price for an item would give you money when purchased
- Providing a negative armor damage value with 0 base damage would result in increasing the target armor instead of hitting them

#### Admins, whitelisting, blacklisting
Create the desired file (`mods.txt`, `whitelist.txt` and/or `blacklist.txt`) as [specified here](http://wiki.pavlov-vr.com/index.php?title=Dedicated_server#Admin.2FModerator_list) 
and mount it to the config directory.

#### Updating the server
When an update is released, check this docker image to see if it has been re-built. If so, you can pull the image again and restart the server to deploy the latest version.

In case this image is out of date, restart the server and it will download any required updates automatically before running again.
