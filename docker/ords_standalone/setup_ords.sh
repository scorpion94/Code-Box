#!/bin/bash
ORDS_PATH=${ORDS_PATH:-/u01/ords}
ORDS_CONFIG=${ORDS_CONFIG:-/u01/config_ords}
ORDS_PORT=${ORDS_PORT:-8080}
ORDS_LOGPATH=${ORDS_LOGPATH:-/u01/logs_ords}
DB_HOST=${DB_HOST:-192.168.56.10}
DB_PORT=${DB_PORT:-1521}
DB_SERVICENAME=${DB_SERVICENAME:-ORCL}
APEX_PATH=${APEX_PATH:-/u01/apex_242/}

if echo > /dev/tcp/"${DB_HOST}"/"${DB_PORT}" 2>/dev/null
then
  echo "Port open"
else
  echo "Port closed"
  exit 1
fi

"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" install \
  --admin-user SYS \
  --db-hostname "${DB_HOST}" \
  --db-port "${DB_PORT}" \
  --db-servicename "${DB_SERVICENAME}" \
  --proxy-user \
  --db-user ORDS_PUBLIC_USER \
  --feature-db-api true \
  --feature-rest-enabled-sql true \
  --feature-sdw true \
  --gateway-mode proxied \
  --gateway-user APEX_PUBLIC_USER \
  --log-folder "${ORDS_LOGPATH}" \
  --password-stdin < "${ORDS_PATH}"/password.txt

"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.doc.root "${ORDS_CONFIG}"/global/doc_root
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.http.port "${ORDS_PORT}"
# Removed line since I switched to CDN from oracle
# "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.static.path "${APEX_PATH}"/apex/images
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.context.path /ords