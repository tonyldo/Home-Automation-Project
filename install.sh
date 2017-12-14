#!/bin/bash

echo "Stop Containers..."
docker stop home-assistant mosquitto

docker container prune -f
 
docker network prune -f

docker volume prune -f

while true; do
    read -p "Do you wish update home-assistant and mosquitto images?" yn
    case $yn in
        [Yy]* ) docker image prune -a -f; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Create directories..."
rm $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config $HOME/.mosquitto/pwd $HOME/.mosquitto/bridge -r
mkdir $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config $HOME/.mosquitto/pwd $HOME/.mosquitto/bridge

SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

echo "Create config file for mosquitto..."
echo "persistence true"  >> $HOME/.mosquitto/config/mosquitto.conf
echo "persistence_location /mosquitto/data/" >> $HOME/.mosquitto/config/mosquitto.conf
echo "log_dest file /mosquitto/log/mosquitto.log" >> $HOME/.mosquitto/config/mosquitto.conf

if [ -f $SCRIPTPATH/config/bridge.conf ]
   then
     cp $SCRIPTPATH/config/bridge.conf $HOME/.mosquitto/bridge/
     echo " " >> $HOME/.mosquitto/config/mosquitto.conf
     echo "include_dir /mosquitto/bridge/" >> $HOME/.mosquitto/config/mosquitto.conf
   else
     echo "config/bridge.conf not exist!"
fi

echo "Install Mosquitto mqtt broker..."
docker run -d --user $UID:$GROUPS --name="mosquitto" --restart unless-stopped -p 1883:1883 -p 9001:9001 -v $HOME/.mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $HOME/.mosquitto/data/:/mosquitto/data/ -v $HOME/.mosquitto/log/:/mosquitto/log/ -v $HOME/.mosquitto/pwd/:/mosquitto/pwd/ -v /etc/ssl/certs/:/etc/ssl/certs/ -v $HOME/.mosquitto/bridge:/mosquitto/bridge/ eclipse-mosquitto

while [ ! $(docker inspect -f '{{.State.Running}}' mosquitto) = "true" ] 
do 
  echo "Wainting for mosquitto..."
done

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

echo " "
echo "Create mosquitto security file..."
docker exec mosquitto touch "/mosquitto/pwd/pass.file"
docker exec mosquitto mosquitto_passwd -b "/mosquitto/pwd/pass.file" $username $pwd1

echo " " >> $HOME/.mosquitto/config/mosquitto.conf
echo "allow_anonymous false" >> $HOME/.mosquitto/config/mosquitto.conf
echo "password_file /mosquitto/pwd/pass.file" >> $HOME/.mosquitto/config/mosquitto.conf


echo "Install HASS..."
docker run -d --user $UID:$GROUPS --name="home-assistant" --restart unless-stopped -p 8123:8123 -v $HOME/.homeassistant/config/:/config -v /etc/localtime/:/etc/localtime:ro homeassistant/home-assistant

echo "Create HASS config..."

while [ ! -f $HOME/.homeassistant/config/configuration.yaml ]
do
  sleep 5
done

echo "HASS configuration file created..."
ls -l $HOME/.homeassistant/config/configuration.yaml

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

sed -i "/api_password:/a \  api_password: !secret http_password" $HOME/.homeassistant/config/configuration.yaml

echo "Integrating HASS and Mosquitto..."
echo " " >> $HOME/.homeassistant/config/configuration.yaml

echo "mqtt:" >> $HOME/.homeassistant/config/configuration.yaml

echo " broker: 172.17.0.1" >> $HOME/.homeassistant/config/configuration.yaml
echo " username: !secret mqtt_username" >> $HOME/.homeassistant/config/configuration.yaml
echo " password: !secret mqtt_password" >> $HOME/.homeassistant/config/configuration.yaml
echo " discovery: true" >> $HOME/.homeassistant/config/configuration.yaml
echo " discovery_prefix: homeassistant" >> $HOME/.homeassistant/config/configuration.yaml

echo "Create secrect file"
rm $HOME/.homeassistant/config/secrets.yaml
touch $HOME/.homeassistant/config/secrets.yaml
echo "http_password: $pwd3" >> $HOME/.homeassistant/config/secrets.yaml
echo "mqtt_username: $username" >> $HOME/.homeassistant/config/secrets.yaml
echo "mqtt_password: $pwd1" >> $HOME/.homeassistant/config/secrets.yaml

echo "Configure HASS..."

echo "Configure device track..."

if [ -f $SCRIPTPATH/config/device_tracker.yaml ]
   then
     cp $SCRIPTPATH/config/device_tracker.yaml $HOME/.homeassistant/config/
     echo " " >> $HOME/.homeassistant/config/configuration.yaml
     echo "device_tracker: !include device_tracker.yaml" >> $HOME/.homeassistant/config/configuration.yaml
   else
     echo "config/device_tracker.yaml not exist!"
fi

echo "Configure Zones..."

if [ -f $SCRIPTPATH/config/zones.yaml ]
   then
     cp $SCRIPTPATH/config/zones.yaml $HOME/.homeassistant/config/
     echo " " >> $HOME/.homeassistant/config/configuration.yaml
     echo "zone: !include zones.yaml" >> $HOME/.homeassistant/config/configuration.yaml
   else
     echo "config/zones.yaml not exist!"
fi


echo "Configure Cameras..."

if [ -f $SCRIPTPATH/config/zones.yaml ]
   then
     cp $SCRIPTPATH/config/cameras.yaml $HOME/.homeassistant/config/
      echo " " >> $HOME/.homeassistant/config/configuration.yaml
      echo "camera: !include cameras.yaml" >> $HOME/.homeassistant/config/configuration.yaml
   else
     echo "config/cameras.yaml not exist!"
fi

echo "Customizing HASS..."

echo "sensor.yr_symbol:" >> $HOME/.homeassistant/config/customize.yaml 
echo "  friendly_name: Weather" >> $HOME/.homeassistant/config/customize.yaml

echo "Restart Hass and Mosquitto."
docker restart home-assistant mosquitto

echo "Finish."
