# home-automation-mqtt-haas
Personal project with a broker mqtt (mosquitto), home assistant project and a lot of esp8266

Using Docker 
sudo docker run -it -p 1883:1883 -p 9001:9001 -v /home/tonyldo/Public/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v /home/tonyldo/Public/mosquitto/data/:/mosquitto/data/ -v /home/tonyldo/Public/mosquitto/log/:/mosquitto/log/ eclipse-mosquitto
