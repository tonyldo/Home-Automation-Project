#!/bin/bash

rm $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config
mkdir $HOME/.mosquitto/data/ $HOME/.mosquitto/config $HOME/.mosquitto/log $HOME/.homeassistant/config

cp ./config/mosquitto.conf $HOME/.mosquitto/config

docker stop home-assistant mosquitto

docker system prune home-assistant mosquitto

docker run -d --user $UID:$GROUPS --name="mosquitto" -p 1883:1883 -p 9001:9001 -v $HOME/.mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $HOME/.mosquitto/data/:/mosquitto/data/ -v $HOME/.mosquitto/log/:/mosquitto/log/ eclipse-mosquitto

docker run -d --user $UID:$GROUPS --name="home-assistant" -p 8123:8123 -v $HOME/.homeassistant/config/:/config -v /etc/localtime/:/etc/localtime:ro homeassistant/home-assistant

echo "mqtt:" >> $HOME/.homeassistant/config/configuration.yaml

echo " broker: 172.17.0.1" >> $HOME/.homeassistant/config/configuration.yaml

docker restart home-assistant
