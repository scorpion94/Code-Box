## performance
- [snapper.sql](performance/snapper.sql) - Tanel Poder Snapper (https://tanelpoder.com/snapper/)

### awr
- [awr_snapshot_overview.sql](performance/awr/awr_snapshot_overview.sql) - Get AWR Snapshot Overview
- [check_adivsor_package_is_enabled.sql](performance/awr/check_adivsor_package_is_enabled.sql) - Check some parameter to see if Diag + Tuning Pack is enabled on the server (includes URLs for more Infos)

** ONLY USE WHEN DIAG + TUNING IS LICENCED!!! **
### dba_hist
- [show_sqlbinds.sql](performance/dba_hist/show_sqlbinds.sql) - Show Binds from SQL-Statements
- [show_sqlplan.sql](performance/dba_hist/show_sqlplan.sql) - Get SQLPLAN for SQL-Statement
- [show_sqltext.sql](performance/dba_hist/show_sqltext.sql) - Get SQLTEXT for SQLID
- [sql_execution_detailed.sql](performance/dba_hist/sql_execution_detailed.sql) - Execution Details with Time for SQL-Statement from AWR-Snapshot
- [sqls_in_time.sql](performance/dba_hist/sqls_in_time.sql) - Get execution /elaspsed Time for SQl-Statement

### dbms_stats
- [create_dbms_task.sql](performance/dbms_stats/create_dbms_task.sql) - Create DBMS_Stats Task + URL for more Informations