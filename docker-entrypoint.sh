#!/bin/ash

set -e
conf_file=/mosquitto/config/mosquitto.conf

echo "persistence true"  >> conf_file
echo "persistence_location /mosquitto/data/" >> conf_file
echo "log_dest file /mosquitto/log/mosquitto.log" >> conf_file

if ( [ -z "${MOSQUITTO_USERNAME}" ] || [ -z "${MOSQUITTO_PASSWORD}" ] ); 
  then
    echo "MOSQUITTO_USERNAME or MOSQUITTO_PASSWORD not defined"
  else
    # create mosquitto passwordfile
    touch passwordfile
    mosquitto_passwd -b /mosquitto/pwd/passwordfile $MOSQUITTO_USERNAME $MOSQUITTO_PASSWORD
    sed -i 's/\#allow_anonymous\ true/allow_anonymous\ false/' $conf_file    
fi

exec "$@"
