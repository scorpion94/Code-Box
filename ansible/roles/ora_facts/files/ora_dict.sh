#!/bin/bash


if [[ -z "${oratab}" || ! -e "${oratab}" ]]
then
  echo "Variable oratab is not definied or does not exists"
  exit 1
fi

# shellcheck disable=SC2207
# Currently not sure if mapfile would be a good idea since it might need to run on Solaris as well
db_list=($(cat "${oratab}" | grep -v '^\s*#' | sed '/^$/d' | grep -iv DUMMY | awk -F: '{print $1}'))

check_db_is_running () {
  local db_name=$1

  if pgrep -f "ora_pmon_${db_name}" > /dev/null 2>&1
  then
    db_running_state=true
  fi
}

get_pdb_name () {
 local db_name=$1

 source /usr/local/bin/oraenv <<< "${db_name}" >/dev/null 2>&1
 pdb_list=$(sqlplus -s / as sysdba <<EOF
   WHENEVER SQLERROR EXIT 1;
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

 source /usr/local/bin/oraenv <<< "${db_name}" >/dev/null 2>&1
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
 db_home=$(grep -w "${db_name}" "${oratab}" | awk -F: '{print $2}') 
}


# Example output
# echo "DB:DB_HOME:DB-VERISON:PDB:PDB:PDB"
# {"CORCL":{"home":"/u01/product/db_lnx_1919","version":"19.19.0.0.0","pdbs":["ORCL","PDB$SEED"]}}

for db in "${db_list[@]}"
do
  get_oracle_home "${db}"
  check_db_is_running "${db}"
  if [[ "${db_running_state}" == "true" ]]
  then
    get_pdb_name "${db}"
    get_version "${db}"
  fi
  
  # Note jq -cM 
  # -c -> compact output instead of pretty
  # -M monochrome -> To avoid ansicode like \u001b[0m\
  # Otherwise its not parsable later in ansible because the result looks like this:
  # "stdout": "\u001b[1;39m{\r\n \u001b[0m\u001b[34;1m\"db_name\"\u001b[0m\u001b[1;39m: 
  #   \u001b[0m\u001b[0;32m\"CORCL\"\u001b[0m\u001b[1;39m,\r\n \u001b[0m\u001b[34;1m\"db_home\"\u001b[0m\u001b[1;39m:
  echo "${db}:${db_home}:${db_version}:${pdb_list}" \
    | jq -R -cM 'split(":") | 
      {
        (.[0]): {
            home: .[1],
            version: (if .[2] == "" then null else .[2] end), # Get second item, if item is empty return null
            pdbs: (.[3:]| map(if . == "" then empty else . end)) # Get 3rd ++ item, if none then return empty list
        }
      }'

  # null variables for next loop
  db_running_state=""
  pdb_list=""
  db_version=""
  db_home=""
done
