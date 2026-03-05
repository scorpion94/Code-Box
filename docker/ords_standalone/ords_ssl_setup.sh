#!/bin/bash
echo "Found certs - running ORDS with SSL"
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.https.port "${ORDS_HTTPS_PORT}"
# Set HTTP Port to 0 to deny http requests
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.http.port 0
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.https.cert "${ORDS_CERT_PATH}/${ORDS_CERT}"
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config set standalone.https.cert.key "${ORDS_CERT_PATH}/${ORDS_CERT_KEY}"
