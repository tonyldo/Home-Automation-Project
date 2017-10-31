# home-automation-mqtt-hass
Personal project with a broker mqtt (mosquitto), home assistant project (HASS), docker and a lot of esp8266

# Configuring the server (Ubuntu 16.10+) 

$ sudo apt-get install git docker mosquitto-clients

$ sudo groupadd docker

$ sudo usermod -aG docker $USER

# Cloning this respository and execute the install script.

$ git clone https://github.com/tonyldo/home-automation-mqtt-hass.git

$ cd /path/to/dir/home-automation-mqtt-hass

$ chmod +x install.sh

$ ./install.sh $MOSQUITTO_USER $MOSQUITTO_USER_PASS

# Testing

$ curl -X POST -H "Content-Type: application/json" -d '{"payload": "Teste", "topic": "hello/world", "retain": "True"}' http://localhost:8123/api/services/mqtt/publish

$ mosquitto_sub -u $MOSQUITTO_USER -P $MOSQUITTO_USER_PASS -t hello/world -q 2

Go to https://github.com/tonyldo/home-assistant-device-simulator for futher information how to test other Home Assistant features.
