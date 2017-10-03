#!/bin/bash

echo "Create directories..."
rm $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config -r
mkdir $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config

echo "Copy config file for mosquitto..."
cp ./config/mosquitto.conf $HOME/.mosquitto/config

echo "Run Containers..."
docker stop home-assistant mosquitto

docker system prune -a

docker run -d --user $UID:$GROUPS --name="mosquitto" -p 1883:1883 -p 9001:9001 -v $HOME/.mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $HOME/.mosquitto/data/:/mosquitto/data/ -v $HOME/.mosquitto/log/:/mosquitto/log/ eclipse-mosquitto

docker run -d --user $UID:$GROUPS --name="home-assistant" -p 8123:8123 -v $HOME/.homeassistant/config/:/config -v /etc/localtime/:/etc/localtime:ro homeassistant/home-assistant

echo "Integrating HASS and Mosquitto..."

while [ ! -f $HOME/.homeassistant/config/configuration.yaml ]
do
  sleep 5
done

ls -l $HOME/.homeassistant/config/configuration.yaml

echo " " >> $HOME/.homeassistant/config/configuration.yaml

echo "mqtt:" >> $HOME/.homeassistant/config/configuration.yaml

echo " broker: 172.17.0.1" >> $HOME/.homeassistant/config/configuration.yaml

docker restart home-assistant

echo "Finish."

