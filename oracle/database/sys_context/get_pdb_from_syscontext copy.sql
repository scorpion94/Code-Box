-- get PDB_NAME + Con_id from sys_context
SELECT sys_context('USERENV','CON_NAME') DBID, sys_context('USERENV','CON_ID') CON_ID FROM dual;
