# home-automation-mqtt-hass
Personal project with a broker mqtt (mosquitto), home assistant project (HASS), docker and a lot of esp8266

# Using Docker

$ docker stop $(docker ps -aq)

$ docker system prune --all

$ docker run -it --user $UID:$GROUPS -p 1883:1883 -p 9001:9001 -v ~/.mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v ~/.mosquitto/data/:/mosquitto/data/ -v ~/.mosquitto/log/:/mosquitto/log/ eclipse-mosquitto

$ docker run -d --user 1000:1000 --name="home-assistant" -p 8123:8123  -v ~/.homeassistant/config/:/config -v /etc/localtime/:/etc/localtime:ro homeassistant/home-assistant
