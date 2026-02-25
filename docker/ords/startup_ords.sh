#!/bin/bash

ORDS_CONFIG=${ORDS_CONFIG:-/u01/config_ords}
ORDS_PATH=${ORDS_PATH:-/u01/ords}

echo "=====DISPLAY ORDS CONFIG====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" config list
echo -e "\n"
echo "=====START ORDS====="
"${ORDS_PATH}"/bin/ords --config "${ORDS_CONFIG}" serve