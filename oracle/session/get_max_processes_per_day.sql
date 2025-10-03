-- Maximum per day:
SELECT instance_number inst, TO_CHAR( begin_time, 'YYYY-MM-DD') DATUM , MAX(processes) FROM
(SELECT instance_number, ROUND(maxval/100 * gv$parameter.VALUE) processes, begin_time
FROM dba_hist_sysmetric_summary
join gv$parameter
ON dba_hist_sysmetric_summary.instance_number = gv$parameter.inst_id
WHERE gv$parameter.name = 'processes'
AND metric_name = 'Process Limit %')
GROUP BY instance_number,TO_CHAR( begin_time, 'YYYY-MM-DD')
ORDER BY DATUM DESC;
