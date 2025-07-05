#!/bin/bash
set -eu
source ~/db.env
sqlplus / as sysdba << EOF
    WHENEVER SQLERROR EXIT 1;
    show pdbs;
    select name from v\$database;
    select * from kunde;
EOF