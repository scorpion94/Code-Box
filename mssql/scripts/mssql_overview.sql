/*
    vd_mssql.sql
    SQL Server pendant to Oracle vd12.sql

    Purpose:
      - compact instance / database overview
      - patch/build information
      - database status
      - recovery / backup-relevant settings
      - files
      - Query Store status
      - HA / replication flags where visible

    Run from SSMS.
    Recommended database context: master

    Permission notes:
      - Most catalog views are readable with public metadata visibility
      - Some DMV columns may require VIEW SERVER STATE
*/

USE master;
GO

SET NOCOUNT ON;

PRINT '============================================================';
PRINT ' vd_mssql.sql - SQL Server Database Overview';
PRINT ' Generated at: ' + CONVERT(varchar(30), SYSDATETIME(), 121);
PRINT ' Current DB:   ' + DB_NAME();
PRINT ' Login:        ' + SUSER_SNAME();
PRINT '============================================================';


/* ============================================================
   1. Instance / Server information
   Oracle-ish: v$instance + v$database basic header
   ============================================================ */

PRINT '';
PRINT '--- INSTANCE INFORMATION ---';

SELECT
    @@SERVERNAME                                      AS configured_server_name,
    SERVERPROPERTY('ServerName')                     AS server_name,
    SERVERPROPERTY('MachineName')                    AS machine_name,
    SERVERPROPERTY('InstanceName')                   AS instance_name,
    SERVERPROPERTY('IsClustered')                    AS is_clustered,
    SERVERPROPERTY('ComputerNamePhysicalNetBIOS')    AS active_node_name,
    SERVERPROPERTY('Edition')                        AS edition,
    SERVERPROPERTY('EngineEdition')                  AS engine_edition,
    SERVERPROPERTY('ProductVersion')                 AS product_version,
    SERVERPROPERTY('ProductLevel')                   AS product_level,
    SERVERPROPERTY('ProductUpdateLevel')             AS product_update_level,
    SERVERPROPERTY('ProductUpdateReference')         AS kb_reference,
    SERVERPROPERTY('Collation')                      AS server_collation,
    SERVERPROPERTY('IsHadrEnabled')                  AS is_hadr_enabled,
    SERVERPROPERTY('FilestreamConfiguredLevel')      AS filestream_configured_level,
    SERVERPROPERTY('FilestreamEffectiveLevel')       AS filestream_effective_level;


/* ============================================================
   2. OS / SQL Server resource information
   Oracle-ish: host / CPU / memory quick facts
   ============================================================ */

PRINT '';
PRINT '--- OS / SQL SERVER RESOURCE INFORMATION ---';

SELECT
    sqlserver_start_time,
    cpu_count,
    hyperthread_ratio,
    scheduler_count,
    physical_memory_kb / 1024 AS physical_memory_mb,
    committed_kb / 1024       AS sql_committed_memory_mb,
    committed_target_kb / 1024 AS sql_committed_target_mb,
    virtual_machine_type_desc,
    sql_memory_model_desc
FROM sys.dm_os_sys_info;


/* ============================================================
   3. Important server configuration
   Oracle-ish: parameter overview, only selected DBA-relevant options
   ============================================================ */

PRINT '';
PRINT '--- SELECTED SERVER CONFIGURATION ---';

SELECT
    name,
    value,
    value_in_use,
    description
FROM sys.configurations
WHERE name IN
(
    'max server memory (MB)',
    'min server memory (MB)',
    'max degree of parallelism',
    'cost threshold for parallelism',
    'backup compression default',
    'optimize for ad hoc workloads',
    'remote admin connections',
    'xp_cmdshell',
    'clr enabled',
    'show advanced options'
)
ORDER BY name;


/* ============================================================
   4. Database overview
   Oracle-ish: v$database
   SQL Server equivalent: sys.databases
   ============================================================ */

PRINT '';
PRINT '--- DATABASE OVERVIEW ---';

SELECT
    d.database_id,
    d.name,
    d.create_date,
    d.compatibility_level,
    d.collation_name,
    d.user_access_desc,
    d.state_desc,
    d.is_read_only,
    d.is_auto_close_on,
    d.is_auto_shrink_on,
    d.recovery_model_desc,
    d.log_reuse_wait_desc,
    d.page_verify_option_desc,
    d.is_encrypted,
    d.is_query_store_on,
    d.snapshot_isolation_state_desc,
    d.is_read_committed_snapshot_on,
    d.containment_desc,
    d.source_database_id,
    d.is_distributor,
    d.is_published,
    d.is_subscribed,
    d.replica_id,
    d.group_database_id
FROM sys.databases d
ORDER BY
    CASE WHEN d.database_id <= 4 THEN 0 ELSE 1 END,
    d.database_id;


/* ============================================================
   5. Database options, more readable
   Oracle-ish: additional DB properties
   ============================================================ */

PRINT '';
PRINT '--- DATABASE OPTIONS SUMMARY ---';

SELECT
    d.name AS database_name,
    DATABASEPROPERTYEX(d.name, 'Status')             AS status,
    DATABASEPROPERTYEX(d.name, 'Updateability')      AS updateability,
    DATABASEPROPERTYEX(d.name, 'UserAccess')         AS user_access,
    DATABASEPROPERTYEX(d.name, 'Recovery')           AS recovery,
    DATABASEPROPERTYEX(d.name, 'Version')            AS internal_version,
    DATABASEPROPERTYEX(d.name, 'Collation')          AS collation,
    DATABASEPROPERTYEX(d.name, 'IsAutoCreateStatistics') AS is_auto_create_statistics,
    DATABASEPROPERTYEX(d.name, 'IsAutoUpdateStatistics') AS is_auto_update_statistics,
    DATABASEPROPERTYEX(d.name, 'IsFulltextEnabled')  AS is_fulltext_enabled
FROM sys.databases d
ORDER BY d.database_id;


/* ============================================================
   6. Files / Redo-ish storage overview
   Oracle-ish: datafiles / tempfiles / redo members
   SQL Server equivalent: database files + log files
   ============================================================ */

PRINT '';
PRINT '--- DATABASE FILES ---';

SELECT
    DB_NAME(mf.database_id) AS database_name,
    mf.file_id,
    mf.type_desc,
    mf.name AS logical_file_name,
    mf.physical_name,
    CAST(mf.size * 8.0 / 1024 AS decimal(18,2)) AS size_mb,
    CASE
        WHEN mf.max_size = -1 THEN 'UNLIMITED'
        WHEN mf.max_size = 0 THEN 'NO_GROWTH'
        ELSE CAST(CAST(mf.max_size * 8.0 / 1024 AS decimal(18,2)) AS varchar(30))
    END AS max_size_mb,
    CASE
        WHEN mf.is_percent_growth = 1 THEN CAST(mf.growth AS varchar(20)) + ' %'
        ELSE CAST(CAST(mf.growth * 8.0 / 1024 AS decimal(18,2)) AS varchar(30)) + ' MB'
    END AS growth,
    mf.state_desc
FROM sys.master_files mf
ORDER BY
    DB_NAME(mf.database_id),
    mf.type,
    mf.file_id;


/* ============================================================
   7. Database size summary
   ============================================================ */

PRINT '';
PRINT '--- DATABASE SIZE SUMMARY ---';

SELECT
    DB_NAME(database_id) AS database_name,
    CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8.0 / 1024 AS decimal(18,2)) AS data_size_mb,
    CAST(SUM(CASE WHEN type_desc = 'LOG'  THEN size END) * 8.0 / 1024 AS decimal(18,2)) AS log_size_mb,
    CAST(SUM(size) * 8.0 / 1024 AS decimal(18,2)) AS total_size_mb
FROM sys.master_files
GROUP BY database_id
ORDER BY total_size_mb DESC;


/* ============================================================
   8. Log reuse / recovery related
   Oracle-ish: archivelog / redo pressure hint
   ============================================================ */

PRINT '';
PRINT '--- LOG REUSE / RECOVERY STATUS ---';

SELECT
    name AS database_name,
    recovery_model_desc,
    log_reuse_wait_desc,
    is_auto_create_stats_on,
    is_auto_update_stats_on,
    is_read_committed_snapshot_on,
    snapshot_isolation_state_desc,
    page_verify_option_desc
FROM sys.databases
ORDER BY
    CASE WHEN log_reuse_wait_desc = 'NOTHING' THEN 1 ELSE 0 END,
    name;


/* ============================================================
   9. Last backup information
   Oracle-ish: backup/recovery posture
   ============================================================ */

PRINT '';
PRINT '--- LAST BACKUP INFORMATION ---';

SELECT
    d.name AS database_name,
    MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS last_full_backup,
    MAX(CASE WHEN b.type = 'I' THEN b.backup_finish_date END) AS last_diff_backup,
    MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS last_log_backup,
    d.recovery_model_desc
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b
    ON b.database_name = d.name
GROUP BY
    d.name,
    d.recovery_model_desc
ORDER BY
    d.name;


/* ============================================================
   10. Query Store status
   Oracle-ish: not vd12 original, but important SQL Server DB feature
   Similar role: persistent query runtime metadata per DB
   ============================================================ */

PRINT '';
PRINT '--- QUERY STORE STATUS PER DATABASE ---';

IF OBJECT_ID('tempdb..#query_store_status') IS NOT NULL
    DROP TABLE #query_store_status;

CREATE TABLE #query_store_status
(
    database_name sysname NOT NULL,
    actual_state_desc nvarchar(60) NULL,
    desired_state_desc nvarchar(60) NULL,
    readonly_reason bigint NULL,
    current_storage_size_mb bigint NULL,
    max_storage_size_mb bigint NULL,
    query_capture_mode_desc nvarchar(60) NULL,
    size_based_cleanup_mode_desc nvarchar(60) NULL
);

DECLARE @db sysname;
DECLARE @sql nvarchar(max);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE';

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @db;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'
        BEGIN TRY
            INSERT INTO #query_store_status
            (
                database_name,
                actual_state_desc,
                desired_state_desc,
                readonly_reason,
                current_storage_size_mb,
                max_storage_size_mb,
                query_capture_mode_desc,
                size_based_cleanup_mode_desc
            )
            SELECT
                N''' + REPLACE(@db, '''', '''''') + N''',
                actual_state_desc,
                desired_state_desc,
                readonly_reason,
                current_storage_size_mb,
                max_storage_size_mb,
                query_capture_mode_desc,
                size_based_cleanup_mode_desc
            FROM ' + QUOTENAME(@db) + N'.sys.database_query_store_options;
        END TRY
        BEGIN CATCH
            INSERT INTO #query_store_status(database_name, actual_state_desc)
            VALUES (N''' + REPLACE(@db, '''', '''''') + N''', N''NOT_READABLE_OR_NOT_SUPPORTED'');
        END CATCH;
    ';

    EXEC sys.sp_executesql @sql;

    FETCH NEXT FROM db_cursor INTO @db;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

SELECT *
FROM #query_store_status
ORDER BY database_name;


/* ============================================================
   11. Always On Availability Group overview
   Oracle-ish: database_role / Data Guard-ish mapping
   ============================================================ */

PRINT '';
PRINT '--- ALWAYS ON AVAILABILITY GROUPS ---';

IF SERVERPROPERTY('IsHadrEnabled') = 1
BEGIN
    SELECT
        ag.name AS availability_group_name,
        ar.replica_server_name,
        ar.availability_mode_desc,
        ar.failover_mode_desc,
        ar.seeding_mode_desc,
        ars.role_desc,
        ars.operational_state_desc,
        ars.connected_state_desc,
        ars.synchronization_health_desc
    FROM sys.availability_groups ag
    JOIN sys.availability_replicas ar
        ON ag.group_id = ar.group_id
    LEFT JOIN sys.dm_hadr_availability_replica_states ars
        ON ar.replica_id = ars.replica_id
    ORDER BY ag.name, ar.replica_server_name;

    PRINT '';
    PRINT '--- AVAILABILITY DATABASES ---';

    SELECT
        DB_NAME(drs.database_id) AS database_name,
        drs.database_state_desc,
        drs.synchronization_state_desc,
        drs.synchronization_health_desc,
        drs.is_suspended,
        drs.suspend_reason_desc,
        drs.log_send_queue_size,
        drs.redo_queue_size
    FROM sys.dm_hadr_database_replica_states drs
    ORDER BY DB_NAME(drs.database_id);
END
ELSE
BEGIN
    SELECT 'HADR / Always On Availability Groups not enabled on this instance.' AS info;
END;


/* ============================================================
   12. Replication flags
   Oracle-ish: supplemental system feature overview
   ============================================================ */

PRINT '';
PRINT '--- REPLICATION FLAGS ---';

SELECT
    name AS database_name,
    is_published,
    is_subscribed,
    is_merge_published,
    is_distributor
FROM sys.databases
WHERE
    is_published = 1
    OR is_subscribed = 1
    OR is_merge_published = 1
    OR is_distributor = 1
ORDER BY name;


/* ============================================================
   13. SQL Agent jobs quick overview
   Operationally useful, not Oracle vd12 equivalent
   ============================================================ */

PRINT '';
PRINT '--- SQL SERVER AGENT JOBS SUMMARY ---';

IF OBJECT_ID('msdb.dbo.sysjobs') IS NOT NULL
BEGIN
    SELECT
        j.name AS job_name,
        j.enabled,
        SUSER_SNAME(j.owner_sid) AS owner_name,
        j.date_created,
        j.date_modified
    FROM msdb.dbo.sysjobs j
    ORDER BY j.enabled DESC, j.name;
END;


/* ============================================================
   14. Login / sysadmin quick check
   ============================================================ */

PRINT '';
PRINT '--- SYSADMIN LOGINS ---';

SELECT
    sp.name,
    sp.type_desc,
    sp.is_disabled,
    sp.create_date,
    sp.modify_date
FROM sys.server_principals sp
JOIN sys.server_role_members srm
    ON sp.principal_id = srm.member_principal_id
JOIN sys.server_principals rolep
    ON srm.role_principal_id = rolep.principal_id
WHERE rolep.name = 'sysadmin'
ORDER BY sp.name;


/* ============================================================
   15. End
   ============================================================ */

PRINT '';
PRINT '============================================================';
PRINT ' vd_mssql.sql finished';
PRINT '============================================================';