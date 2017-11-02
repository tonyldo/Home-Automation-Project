#!/bin/bash

echo "Stop Containers..."
docker stop home-assistant mosquitto

docker container prune -f
 
docker network prune -f

docker volume prune -f

while true; do
    read -p "Do you wish update home-assistant and mosquitto?" yn
    case $yn in
        [Yy]* ) docker image prune -a -f; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Create directories..."
rm $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config $HOME/.mosquitto/pwd -r
mkdir $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config $HOME/.mosquitto/pwd

SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")
echo $SCRIPTPATH

echo "Copy config file for mosquitto..."
cp $SCRIPTPATH/config/mosquitto.conf $HOME/.mosquitto/config

docker run -d --user $UID:$GROUPS --name="mosquitto" -p 1883:1883 -p 9001:9001 -v $HOME/.mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $HOME/.mosquitto/data/:/mosquitto/data/ -v $HOME/.mosquitto/log/:/mosquitto/log/ -v $HOME/.mosquitto/pwd/:/mosquitto/pwd/ eclipse-mosquitto

docker run -d --user $UID:$GROUPS --name="home-assistant" -p 8123:8123 -v $HOME/.homeassistant/config/:/config -v /etc/localtime/:/etc/localtime:ro homeassistant/home-assistant

echo "Create HASS config..."

while [ ! -f $HOME/.homeassistant/config/configuration.yaml ]
do
  sleep 5
done

echo "HASS configuration file created..."
ls -l $HOME/.homeassistant/config/configuration.yaml

read -p "Enter Username for mosquitto broker: " username
while :
do
    read -sp "Enter Password for mosquitto broker: " pwd1
    read -sp "Confirm Password: " pwd2
    if [ "$pwd1" == "$pwd2" ]
    then
		break
    else
	    echo "Password and Confirm password doesn't match...."
    fi
done

echo "Create mosquitto security file..."
docker exec mosquitto touch "/mosquitto/pwd/pass.file"
docker exec mosquitto mosquitto_passwd -b "/mosquitto/pwd/pass.file" $username $pwd1
echo "allow_anonymous false" >> $HOME/.mosquitto/config/mosquitto.conf
echo "password_file /mosquitto/pwd/pass.file" >> $HOME/.mosquitto/config/mosquitto.conf

echo "Setup password for HASS web interface..."

while :
do
    read -sp "Enter Password for HASS Web Interface: " pwd3
    read -sp "Confirm Password: " pwd4
    if [ "$pwd3" == "$pwd4" ]
    then
                break
    else
            echo "Password and Confirm password doesn't match...."
    fi
done

sed -i "/api_password:/a \  api_password: $pwd3" $HOME/.homeassistant/config/configuration.yaml

echo "Integrating HASS and Mosquitto..."
echo " " >> $HOME/.homeassistant/config/configuration.yaml

echo "mqtt:" >> $HOME/.homeassistant/config/configuration.yaml

echo " broker: 172.17.0.1" >> $HOME/.homeassistant/config/configuration.yaml
echo " username: $username" >> $HOME/.homeassistant/config/configuration.yaml
echo " password: $pwd1" >> $HOME/.homeassistant/config/configuration.yaml

echo " discovery: true" >> $HOME/.homeassistant/config/configuration.yaml
echo " discovery_prefix: homeassistant" >> $HOME/.homeassistant/config/configuration.yaml

echo "Customizing HASS..."
echo "sensor.yr_symbol:" >> $HOME/.homeassistant/config/customize.yaml 
echo "  friendly_name: Weather" >> $HOME/.homeassistant/config/customize.yaml

docker restart home-assistant mosquitto

echo "Finish."

