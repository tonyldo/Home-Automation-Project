# home-automation-mqtt-hass
Personal project with a broker mqtt (mosquitto), home assistant project (HASS), docker and a lot of esp8266

# Configuring the server (Ubuntu 16.10+) 

$ sudo apt-get install git docker mosquitto-clients python3 

$ sudo groupadd docker

$ sudo usermod -aG docker $USER

# Cloning this respository and execute the install script.

$ git clone https://github.com/tonyldo/home-automation-mqtt-hass.git

$ cd /path/to/dir/home-automation-mqtt-hass

$ chmod +x install.sh

$ ./install.sh

#Testing
