-- https://oracle-base.com/articles/12c/optimizer-statistics-advisor-12cr2

ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';
SET LINESIZE 150
COLUMN task_name FORMAT A25
COLUMN execution_name FORMAT A20
COLUMN execution_end FORMAT A20
COLUMN execution_type FORMAT A20

SELECT task_name,
       execution_name,
       execution_start,
       execution_end,
       execution_type,
       status
FROM   dba_advisor_executions
WHERE  task_name = 'AUTO_STATS_ADVISOR_TASK'
AND    execution_end >= SYSDATE-2
ORDER BY 3;

-- https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_STATS.html#GUID-926DA751-6261-40B0-89C7-CA3DE5C5434A 

SET LINESIZE 200
SET LONG 1000000
SET PAGESIZE 0
SET LONGCHUNKSIZE 100000

SELECT DBMS_STATS.report_advisor_task('AUTO_STATS_ADVISOR_TASK') AS REPORT FROM   dual;