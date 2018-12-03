#!/bin/ash

set -e

echo "persistence true"  >> /mosquitto/config/mosquitto.conf
echo "persistence_location /mosquitto/data/" >> /mosquitto/config/mosquitto.conf
echo "log_dest file /mosquitto/log/mosquitto.log" >> /mosquitto/config/mosquitto.conf

if ( [ -z "${MOSQUITTO_USERNAME}" ] || [ -z "${MOSQUITTO_PASSWORD}" ] ); 
  then
    echo "MOSQUITTO_USERNAME or MOSQUITTO_PASSWORD not defined"
  else
    echo "allow_anonymous false" >> /mosquitto/config/mosquitto.conf
    echo "password_file /mosquitto/pwd/passwordfile" >> /mosquitto/config/mosquitto.conf    
fi

# create mosquitto passwordfile
touch passwordfile
mosquitto_passwd -b /mosquitto/pwd/passwordfile $MOSQUITTO_USERNAME $MOSQUITTO_PASSWORD

exec "$@"
