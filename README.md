# home-automation-mqtt-hass
Personal project with a broker mqtt (mosquitto), home assistant project (HASS) with docker...

## 1 - Install Docker.
> See: https://docs.docker.com/install/

## 2 - Install Docker-Compose.
> See: https://docs.docker.com/compose/install/

## 3 - Clone this repository.
```
$ git clone --recursive https://github.com/tonyldo/Home-Automation-Project.git
```
## 4 - Install only Home Assistant...
``` 
$ docker-compose -f docker-compose.yaml '''
```
## 5 - Or homeAssitant w/ Mosquitto Broker integration...
> first you need edit "MosquittoDockerComposeInstall/mqtt.env" file and setting the user and pass for the new mosquitto server. 
```
$docker-compose -f docker-compose.yaml -f docker-compose-w-mqtt.yaml -f MosquittoDockerComposeInstall/docker-compose.yaml up --build -d
```
## 6 - Or homeAssitant w/ Mosquitto Broker integration and Bridge to another external MQTT Broker like cloudmqtt.com...
> You need now edit the .env file with CACERT_FILE path Ex:"/etc/ssl/certs/ca-certificates.crt". Also you need edit the "MosquittoDockerComposeInstall/mqtt_bridge.env" file and setting the server, ssl port, user and pass for the external mqtt server.
```
$docker-compose -f docker-compose.yaml -f docker-compose-w-mqtt.yaml -f MosquittoDockerComposeInstall/docker-compose.yaml -f MosquittoDockerComposeInstall/docker-compose-bridgemqtt.yaml  up --build
```
## 7 - Or homeAssitant w/ Mosquitto Broker integration, Bridge to another external MQTT Broker and restoring backuped file from pre defined folder...
> You need now edit the the option RECOVERY_CONFIGFILES_DIR=/Path-to/Home-Assistant-Configuration-Files-Dir/ on .env file
```
$docker-compose -f docker-compose.yaml -f docker-compose-w-mqtt.yaml -f MosquittoDockerComposeInstall/docker-compose.yaml -f MosquittoDockerComposeInstall/docker-compose-bridgemqtt.yaml -f docker-compose-recovery-configfiles.yaml up --build
```
## 8 - If you need a fresh install:
> add this "-f docker-compose-fresh-install.yaml" to any above options, TO DELETE ALL CONFIGURATION files before install process.
```
-f docker-compose-fresh-install.yaml
```
## 9 - Testing
```
$ mosquitto_sub -u $MOSQUITTO_USER -P $MOSQUITTO_USER_PASS -t +/# -v
```

