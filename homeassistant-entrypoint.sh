#!/bin/ash
set -e

echo "Starting Home Assistant configuration..."

if ( [ -z "${FRESHINSTALL}" ] ); then
   echo "Not deleting previous configuration..."
else
   echo "Deleting previous configuration..."
   rm -rf /config/* 
fi

cp /usr/src/app/homeassistant/scripts/ensure_config.py /usr/src/app/

echo "if __name__ == '__main__':"  >> ensure_config.py
echo "    run(None)" >> ensure_config.py

python /usr/src/app/ensure_config.py --config /config --script ensure_config

cat /config/configuration.yaml

python -m homeassistant --config /config
exec "$@"

