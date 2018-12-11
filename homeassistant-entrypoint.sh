#!/bin/ash
set -e
echo "Starting Home Assistant configuration..."

ls

python /usr/src/app/homeassistant-entrypoint.py --config /config

echo "Verificando arquivo de configuração"

ls /config

python -m homeassistant --config /config
exec "$@"
