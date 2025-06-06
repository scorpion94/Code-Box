--Select job_queue_processes
SELECT INSTANCE_NUMBER INST
      ,TO_CHAR(BEGIN_TIME, 'YYYY-MM-DD') DATUM
      ,MAX(PROCESSES)
  FROM (SELECT INSTANCE_NUMBER
              ,ROUND(MAXVAL / 100 * GV$PARAMETER.VALUE) PROCESSES
              ,BEGIN_TIME
          FROM DBA_HIST_SYSMETRIC_SUMMARY
          JOIN GV$PARAMETER
            ON DBA_HIST_SYSMETRIC_SUMMARY.INSTANCE_NUMBER = GV$PARAMETER.INST_ID
         WHERE GV$PARAMETER.NAME = 'job_queue_processes'
           AND METRIC_NAME = 'Process Limit %')
GROUP BY INSTANCE_NUMBER
         ,TO_CHAR(BEGIN_TIME, 'YYYY-MM-DD')
ORDER BY DATUM DESC;
