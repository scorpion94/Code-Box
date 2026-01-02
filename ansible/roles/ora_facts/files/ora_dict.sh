#!/bin/bash

db_array=()
db_list=($(cat ${oratab} | grep -v '^\s*#' | sed '/^$/d' | grep -iv DUMMY | awk -F: '{print $1}'))

get_pdb_name () {
 local db_name=$1

 . oraenv <<< "${db_name}" >/dev/null 2>&1
 pdb_list=$(sqlplus -s / as sysdba <<EOF
   set echo off;
   set heading off;
   set feedback off;
   set pages 0;
   SELECT LISTAGG(name, ':') WITHIN GROUP (ORDER BY name) "pdb" FROM v\$pdbs; 
EOF
)
}

get_version () {
 local db_name=$1

 . oraenv <<< "${db_name}" >/dev/null 2>&1
 db_version=$(sqlplus -s / as sysdba <<EOF
   set echo off;
   set heading off;
   set feedback off;
   set pages 0;
   select VERSION_FULL from v\$instance;
EOF
)
}

get_oracle_home () {
 local db_name=$1
 db_home=$(grep ${db_name} ${oratab}| awk -F: '{print $2}') 
}



# echo "DB:DB-VERISON:DB_HOME:PDB:PDB:PDB"
for db in "${db_list[@]}"
do
 get_pdb_name ${db}
 get_version ${db}
 get_oracle_home ${db}
 echo "${db}:${db_home}:${db_version}:${pdb_list}"
 pdb_list=""
 db_version=""
 db_home=""
done
