#!/usr/bin/env bash

set -e

PORT_APP=8000
PORT_VITE=5173

# get interface
DEFAULT_INTERFACE=$(ip route | awk '/default/ {print $5; exit}')

# get IP
HOST_IP=$(ip -4 addr show "$DEFAULT_INTERFACE" | awk '/inet / {print $2}' | cut -d/ -f1)

# Fallback IP if fail
if [ -z "$HOST_IP" ]; then
  HOST_IP=$(hostname -I | awk '{print $1}')
fi

export APP_URL="http://${HOST_IP}:${PORT_APP}"
export VITE_HOST="${HOST_IP}"
export VITE_HMR_HOST="${HOST_IP}"

echo ""
echo "======================================"
echo " MCH Development Server"
echo "======================================"
echo " Network Interface : ${DEFAULT_INTERFACE}"
echo " Laravel URL       : http://${HOST_IP}:${PORT_APP}"
echo " Vite URL          : http://${HOST_IP}:${PORT_VITE}"
echo "======================================"
echo ""

npx concurrently -c "#93c5fd,#c4b5fd,#fb7185,#fdba74" \
  "php artisan serve --host=0.0.0.0 --port=${PORT_APP}" \
  "php artisan queue:listen --tries=1 --timeout=0" \
  "php artisan pail --timeout=0" \
  "npm run dev -- --host 0.0.0.0 --port ${PORT_VITE}" \
  --names=server,queue,logs,vite --kill-others
