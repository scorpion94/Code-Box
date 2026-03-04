#!/bin/bash

ORDS_CONFIG=${ORDS_CONFIG:-/u01/config_ords}
ORDS_PATH=${ORDS_PATH:-/u01/ords}
DB_HOST=${DB_HOST:-192.168.56.10}
DB_PORT=${DB_PORT:-1521}

if echo > /dev/tcp/"${DB_HOST}"/"${DB_PORT}" 2>/dev/null
then
  echo "Port open"
else
  echo "Port closed"
  exit 1
fi



echo "=====DISPLAY ORDS CONFIG====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config list
echo -e "\n"
echo "=====START ORDS====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" serve