#!/bin/bash

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
  --password-stdin < "$PWFILE"

"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.doc.root "${ORDS_CONFIG}"/global/doc_root
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.http.port "${ORDS_HTTP_PORT}"
# Removed line since I switched to CDN from oracle
# "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.static.path "${APEX_PATH}"/apex/images
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.context.path /ords