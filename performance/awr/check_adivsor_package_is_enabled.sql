-- https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/CONTROL_MANAGEMENT_PACK_ACCESS.html
-- => if parameter is set to false its not enabled
show parameter CONTROL_MANAGEMENT_PACK_ACCESS;

-- => TYPICAL oder ALL (falls detailierte Berichte notwendig sein sollten)
show parameter statistics_level

-- https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/AWR_PDB_AUTOFLUSH_ENABLED.html
show parmaeter AWR_PDB_AUTOFLUSH_ENABLED