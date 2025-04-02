SELECT snap.SNAP_ID,
       to_char(snap.BEGIN_INTERVAL_TIME,'DD.MM.YYYY HH24:MI') begin_interval_time,
       to_char(snap.END_INTERVAL_TIME,'DD.MM.YYYY HH24:MI') end_interval_time,
       sqls.SQL_ID,
       sqls.PLAN_HASH_VALUE,
       ROUND(sqls.ELAPSED_TIME_DELTA/1000,0) elapsed_time_delta,
       sqls.EXECUTIONS_DELTA,
       ROUND(sqls.ELAPSED_TIME_DELTA / CASE WHEN sqls.EXECUTIONS_DELTA = 0
                                            THEN 1
                                            ELSE sqls.EXECUTIONS_DELTA
                                       END / 1000, 0) execution_time_in_ms
  FROM DBA_HIST_SNAPSHOT SNAP
  JOIN DBA_HIST_SQLSTAT SQLS
    ON SNAP.SNAP_ID = SQLS.SNAP_ID
   AND SNAP.CON_ID = SQLS.CON_ID
   WHERE snap.CON_ID = sys_context('USERENV','CON_ID')
   AND sqls.SQL_ID = 'd9q2q82g1tuzx'
   AND to_char(snap.BEGIN_INTERVAL_TIME,'YYYYMMDD') = '20240325'
   ORDER BY snap.BEGIN_INTERVAL_TIME DESC;
