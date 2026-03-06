#!/bin/bash

if [ ! -d "${APEX_PATH}"/apex ]
then
  echo "Apex ${APEX_VERISON} is not downloaded -> exit 1"
  exit 1
fi

if [ -z "${APEX_TABLESPACE}" ]
then
  echo "Tablespace for Apex is not definied -> exit 1"
  exit 1
fi

check_tbs_exists () {
  v_tbs_count=$(sqlplus -S / as sysdba <<EOF
    set echo off;
    set heading off;
    set feedback off;
    set pages 0;
    select count(*) from dba_tablespaces where tablespace_name = '${APEX_TABLESPACE}';
    exit;
EOF
  )

  # Remove Blanks from Variable
  v_tbs_count=$(echo "${v_tbs_count}" | tr -d '[:space:]')

  if [ "${v_tbs_count}" -eq 0 ]
  then
    echo "Tablespace ${APEX_TABLESPACE} does not exists! -> exit 1"
    exit 1
  fi
}


install_apex () {
  echo "====INSTALLING APEX NOW!===="
  cd "${APEX_PATH}/apex" || { echo "Path does not exist"; exit 1; }
  sqlplus -S / as sysdba <<EOF
    WHENEVER SQLERROR EXIT 1;
    alter session set container=${PDB_NAME};
    set serverout on;
    select SYS_CONTEXT('USERENV','CON_NAME') from dual;
    exec dbms_output.put_line('====STARTING APEX INSTALLATION====');
    @apexins.sql ${APEX_TABLESPACE} ${APEX_TABLESPACE} TEMP ${APEX_IMAGE_PATH}
EOF

  echo "Set Marker for sucessful Apex-Installation"
  touch "${APEX_PATH}"/.apex_installed
}



check_tbs_exists
if [ ! -e "${APEX_PATH}"/.apex_installed ]
then
  install_apex
else
  echo "====APEX ALREADY INSTALLED===="
fi
