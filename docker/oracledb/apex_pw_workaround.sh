#!/bin/bash

if [[ -z "${APEX_WEB_USER}" || -z "${APEX_PW}" || -z "${APEX_WEB_USER_MAIL}" ]]
then
    echo "Missing Variable for APEX_WEB_USER, APEX_PW, APEX_WEB_USER_MAIL -> skip changepw"
    exit 1
fi


sqlplus -S / as sysdba <<EOF
  alter session set container=${PDB_NAME};
  -- set off verify to suppress password and stuff
  set verify off;
  DEFINE USERNAME='$APEX_WEB_USER'
  DEFINE EMAIL='$APEX_WEB_USER_MAIL'
  DEFINE PASSWORD='$APEX_PW'

  @@core/scripts/set_appun.sql
  alter session set current_schema = &APPUN;

  begin
    dbms_output.put_line('APEX_USER: &USERNAME');

    wwv_flow_instance_admin.create_or_update_admin_user (
      p_username => '&USERNAME',
      p_email    => '&EMAIL',
      p_password => '&PASSWORD' );
    commit;
  end;
  /
EOF