# home-automation-mqtt-haas
Personal project with a broker mqtt (mosquitto), home assistant project (HASS), docker and a lot of esp8266

# Using Docker 

~$ sudo docker run -it --user 1000:1000 -p 1883:1883 -p 9001:9001 -v ~/.mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v ~/.mosquitto/data/:/mosquitto/data/ -v ~/.mosquitto/log/:/mosquitto/log/ eclipse-mosquitto
