set lines 150;
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
col size_gb for 9999999.999
select  oldest_backup_time,
        newest_backup_time,
        num_backupsets,
        round(output_bytes / 1024 / 1024 / 1024, 3) as size_gb
from v$backup_set_summary;