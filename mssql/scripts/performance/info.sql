SELECT
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    SERVERPROPERTY('InstanceName') AS instance_name,
    DB_NAME() as Database_Name,
    SERVERPROPERTY('Edition') AS edition,
    SERVERPROPERTY('ProductVersion') AS product_version,
    SERVERPROPERTY('ProductLevel') AS product_level,
    SERVERPROPERTY('ProductUpdateLevel') AS product_update_level,
    SERVERPROPERTY('ProductUpdateReference') AS kb_reference,
    sqlserver_start_time
FROM sys.dm_os_sys_info;