#!/bin/bash

INIT_MARKER="${ORDS_CONFIG}/.ords_initialized"
INIT_SSL_MARKER="${ORDS_CONFIG}/.ords_ssl_initialized"

# Check if mounted volumes are existing
if [ ! -r "${PWFILE}" ]
then
  echo "Missing PWFILE: ${PWFILE} -> ABORT!!"
  exit 1
fi

python3 "${ORDS_PATH}/check_database_connect.py"

rc=$?

if [ "${rc}" -gt 0 ]
then
  echo "Error during connect to database! -> exit 1"
  exit 1
fi

# One-time ORDS config (persisted via volume on ORDS_CONFIG)
if [ ! -f "${INIT_MARKER}" ]
then
  echo "=====FIRST START: SETUP ORDS====="
  "${ORDS_PATH}"/setup_ords.sh

  touch "${INIT_MARKER}"
fi

if [[ -f "${ORDS_CERT_PATH}/${ORDS_CERT}" && -f "${ORDS_CERT_PATH}/${ORDS_CERT_KEY}" && ! -e "${INIT_SSL_MARKER}" ]]
then
  echo "=====CONFIGURE ORDS SSL====="
  "${ORDS_PATH}"/ords_ssl_setup.sh
fi

echo "=====DISPLAY ORDS CONFIG====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config list
echo -e "\n"
echo "=====START ORDS====="
exec "${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" serve
