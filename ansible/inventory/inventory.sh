#!/bin/bash

sql_output="$(
  sqlplus -S /@ansible_db <<EOF
    set heading off;
    set feedback off;
    set echo off;
    set lines 0;
    SELECT db_unique_name
          || '|' || hostname_short
          || '|' || NVL(host_group, 'ungrouped')
      FROM iventory
    WHERE hostname_short IS NOT NULL
    ORDER BY host_group, hostname_short;
    EXIT
EOF
)"

# Gebe den Output jeweils als neue Zeile aus
# jq -R (raw) -s (slurp) => Fasse alle Zeilen als einzigen String zusammen  
printf '%s\n' "$sql_output" | jq -R -s '
  # Jede Zeile splitten, letzte (leere) Zeile verwerfen
  split("\n")[:-1]
  # Jede Zeile in Felder auftrennen
  | map(split("|"))
  # Objekt je Zeile: db_unique, host, group
  | map({
      db_unique: .[0],
      host:      .[1],
      group:     .[2]
    })
  as $hosts
  # all.hosts: alle Hostnamen (hostname_short)
  | {
      all: {
        hosts: ($hosts | map(.host))
      },
      # Gruppenobjekt: groupname -> { hosts: [ ... ] }
      groups: (
        $hosts
        | group_by(.group)
        | map({ (.[0].group): { hosts: map(.host) } })
        | add
      ),
      # _meta.hostvars: host -> { db_unique_name: ... }
      _meta: {
        hostvars: (
          $hosts
          | map({
              key: .host,
              value: { db_unique_name: .db_unique }
            })
          | from_entries
        )
      }
    }
  # all + groups + _meta auf Top-Level zusammenführen
  | .all + .groups + { _meta: ._meta }
'
