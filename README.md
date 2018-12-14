# home-automation-mqtt-hass
Personal project with a broker mqtt (mosquitto), home assistant project (HASS) with docker...

# Install Docker.

See: https://docs.docker.com/install/

# Install Docker-Compose. # Only HomeAssistant....

See: https://docs.docker.com/compose/install/ docker-compose -f docker-compose.yml

# Clone this repository

git clone --recursive https://github.com/tonyldo/home-automation-mqtt-hass.git

# HomeAssitant w/ Mosquitto Broker integration...

docker-compose -f docker-compose.yml -f docker-compose-w-mqtt.yml -f MosquittoDockerComposeInstall/docker-compose.yaml

# HomeAssitant w/ Mosquitto Broker integration and Bridge to another external MQTT Broker like cloudmqtt.com...

docker-compose -f docker-compose.yml -f docker-compose-w-mqtt.yml -f MosquittoDockerComposeInstall/docker-compose.yaml -f MosquittoDockerComposeInstall/docker-compose-bridgemqtt.yaml

# Testing

$ curl -X POST -H "x-ha-access: $INTERFACE_PASS" -H "Content-Type: application/json" -d '{"payload": "Teste", "topic": "hello/world", "retain": "True"}' http://localhost:8123/api/services/mqtt/publish

$ mosquitto_sub -u $MOSQUITTO_USER -P $MOSQUITTO_USER_PASS -t hello/world -q 2

Go to https://github.com/tonyldo/home-assistant-device-simulator for futher information how to test other Home Assistant features.
