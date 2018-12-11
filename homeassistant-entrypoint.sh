#!/bin/ash
set -e

echo "Starting Home Assistant configuration..."
python /usr/src/app/homeassistant-entrypoint.py --config /config

cat /config/configuration.yaml

python -m homeassistant --config /config
exec "$@"
