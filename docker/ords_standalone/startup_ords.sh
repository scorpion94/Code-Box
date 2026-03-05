#!/bin/bash

ORDS_CONFIG=${ORDS_CONFIG:-/u01/config_ords}
ORDS_PATH=${ORDS_PATH:-/u01/ords}
ORDS_HTTP_PORT=${ORDS_HTTP_PORT:-8080}
ORDS_HTTPS_PORT=${ORDS_HTTPS_PORT:-8443}

ORDS_CERT_PATH="/certs"
ORDS_CERT=${ORDS_CERT:-ords.local.pem}
ORDS_CERT_KEY=${ORDS_CERT_KEY:-ords.local-key.pem}

DB_HOST=${DB_HOST:-192.168.56.10}
DB_PORT=${DB_PORT:-1521}

if echo > /dev/tcp/"${DB_HOST}"/"${DB_PORT}" 2>/dev/null
then
  echo "Port open"
else
  echo "Port closed"
  exit 1
fi


if [[ -f "${ORDS_CERT_PATH}/${ORDS_CERT}" && -f "${ORDS_CERT_PATH}/${ORDS_CERT_KEY}" ]]
then
  echo "Found certs - running ORDS with SSL"
  "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.https.port "${ORDS_HTTPS_PORT}"
  # Set HTTP Port to 0 to deny http requests
  "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.http.port 0

  "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.https.cert "${ORDS_CERT_PATH}/${ORDS_CERT}"
  "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.https.cert.key "${ORDS_CERT_PATH}/${ORDS_CERT_KEY}"

else
  "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.http.port "${ORDS_HTTP_PORT}"
fi



echo "=====DISPLAY ORDS CONFIG====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config list
echo -e "\n"
echo "=====START ORDS====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" serve