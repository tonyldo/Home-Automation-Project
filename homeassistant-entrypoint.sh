#!/bin/ash
set -e

echo "Starting Home Assistant configuration..."

if ( [ -z "${FRESHINSTALL}" ] ); then
   echo "Not deleting previous configuration..."
else
   echo "Deleting previous configuration..."
   find /config -mindepth 1 -depth -exec rm -rf {} ';'

   echo "Creating new configurations files..."      
   cp /usr/src/app/homeassistant/scripts/ensure_config.py /usr/src/app/

   echo "if __name__ == '__main__':"  >> ensure_config.py
   echo "    run(None)" >> ensure_config.py

   python /usr/src/app/ensure_config.py --config /config --script ensure_config

   if ( [ -z "${RECOVERYCONFIGFILES}" ] ); then
      echo "Not previous configuration..."
   else
      echo "Recovery backup config files..."
      for i in $(find /RecoveryConfigFiles -name '*.yaml' ! -name 'secrets.yaml'); do 
          echo "Find backuped Configuration file:" "$i"
          cp "$i" /config
          f=${i##*/}
          echo "$f"
          if grep -q ${i##*/} /config/configuration.yaml; then
             echo "${i##*/}" "already on configuration file..."
          else
             echo " "  >> /config/configuration.yaml
             echo "${f%.yaml}:" "!include" "${i##*/}"  >> /config/configuration.yaml
          fi
      done
      if ( [ -f /RecoveryConfigFiles/secrets.yaml ] ); then
         cp /RecoveryConfigFiles/secrets.yaml /config
      fi
   fi

   if ( [ -z "${MQTTINSTALL}" ] ); then
      echo "No mqtt instalation..."
   elif ( [ -f /config/mqtt.yaml ] ); then
      echo "Editing homeassistant mqtt integration, setting secrets..."
      sed -i 's/mosquitto_user/'"$MOSQUITTO_USERNAME"'/g' /config/secrets.yaml
      sed -i 's/mosquitto_pass/'"${MOSQUITTO_PASSWORD}"'/g' /config/secrets.yaml
   else
      echo "Editing homeassistant mqtt integration..."
      echo " "  >> /config/configuration.yaml
      echo "mqtt: "  >> /config/configuration.yaml
      echo "  broker: localhost"  >> /config/configuration.yaml
      echo "  username: $MOSQUITTO_USERNAME"  >> /config/configuration.yaml
      echo "  password: $MOSQUITTO_PASSWORD"  >> /config/configuration.yaml
   fi
fi

python -m homeassistant --config /config
exec "$@
