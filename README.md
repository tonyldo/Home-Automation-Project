# home-automation-mqtt-hass
Personal project with a broker mqtt (mosquitto), home assistant project (HASS) with docker...

## 1 - Install Docker.
See: https://docs.docker.com/install/

## 2 - Install Docker-Compose.
See: https://docs.docker.com/compose/install/

## 3 - Clone this repository.
$ git clone --recursive https://github.com/tonyldo/home-automation-project.git

## 4 - Install only Home Assistant...
$ docker-compose -f docker-compose.yml

## 5 - Or homeAssitant w/ Mosquitto Broker integration...
$ docker-compose -f docker-compose.yml -f docker-compose-w-mqtt.yml -f MosquittoDockerComposeInstall/docker-compose.yaml up --build -d

## 6 - Or homeAssitant w/ Mosquitto Broker integration and Bridge to another external MQTT Broker like cloudmqtt.com...
$ docker-compose -f docker-compose.yml -f docker-compose-w-mqtt.yml -f MosquittoDockerComposeInstall/docker-compose.yaml -f MosquittoDockerComposeInstall/docker-compose-bridgemqtt.yaml up --build -d

## 7 - Testing
$ mosquitto_sub -u $MOSQUITTO_USER -P $MOSQUITTO_USER_PASS -t +/# -v
