#!/bin/bash

ORDS_CONFIG=${ORDS_CONFIG:-/u01/config_ords}
ORDS_PATH=${ORDS_PATH:-/u01/ords}
ORDS_PORT=${ORDS_PORT:-8080}

DB_HOST=${DB_HOST:-database}
DB_PORT=${DB_PORT:-1521}

INIT_MARKER="${ORDS_CONFIG}/.ords_initialized"

# Wait for DB listener
echo "Waiting for DB ${DB_HOST}:${DB_PORT} ..."
for i in $(seq 1 180)
do
  if echo > /dev/tcp/"${DB_HOST}"/"${DB_PORT}" 2>/dev/null
  then
    echo "Port open"
    break
  fi

  echo "Port closed - retry ${i}/180"
  sleep 2
done

if ! echo > /dev/tcp/"${DB_HOST}"/"${DB_PORT}" 2>/dev/null
then
  echo "DB not reachable after retries - exit 1"
  exit 1
fi

# One-time ORDS config (persisted via volume on ORDS_CONFIG)
if [ ! -f "${INIT_MARKER}" ]
then
  echo "=====FIRST START: SETUP ORDS====="
  "${ORDS_PATH}"/setup_ords.sh

  # Optional: remove password file from container layer after successful install
  rm -f "${ORDS_PATH}"/password.txt 2>/dev/null || true

  touch "${INIT_MARKER}"
fi

echo "=====DISPLAY ORDS CONFIG====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config list
echo -e "\n"
echo "=====START ORDS====="
exec "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" serve
