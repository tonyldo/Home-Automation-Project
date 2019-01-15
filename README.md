# home-automation-mqtt-hass
Personal project with a broker mqtt (mosquitto), home assistant project (HASS) with docker...

# Install Docker.

See: https://docs.docker.com/install/

# Install Docker-Compose. # Only HomeAssistant....

See: https://docs.docker.com/compose/install/

# Clone this repository

git clone --recursive https://github.com/tonyldo/home-automation-project.git

# HomeAssitant w/ Mosquitto Broker integration...

docker-compose -f docker-compose.yml -f docker-compose-w-mqtt.yml -f MosquittoDockerComposeInstall/docker-compose.yaml up --build -d

# HomeAssitant w/ Mosquitto Broker integration and Bridge to another external MQTT Broker like cloudmqtt.com...

docker-compose -f docker-compose.yml -f docker-compose-w-mqtt.yml -f MosquittoDockerComposeInstall/docker-compose.yaml -f MosquittoDockerComposeInstall/docker-compose-bridgemqtt.yaml up --build -d

# Testing

$ mosquitto_sub -u $MOSQUITTO_USER -P $MOSQUITTO_USER_PASS -t +/# -v

