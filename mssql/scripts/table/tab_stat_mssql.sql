/*
    tab_stat_mssql.sql
    Zweck:
      SQL-Server-Variante von Oracle tab_stat.sql.

    Parameter:
      @schema_name : Schema, z.B. N'dbo'
      @table_name  : Tabelle, z.B. N'Orders'

    Ausführen:
      USE [DeineDatenbank];
      GO
      :r tab_stat_mssql.sql

    Hinweise:
      - SQL Server speichert Optimizer-Statistiken anders als Oracle.
      - NUM_DISTINCT, DENSITY und Histogram-Buckets pro Spalte sind nicht sauber set-basiert
        über sys.dm_db_stats_properties verfügbar. Für Histogram/Density nutze zusätzlich:
          DBCC SHOW_STATISTICS ('schema.table', 'statistics_name') WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM;
      - Dieses Skript liefert mehrere Resultsets wie das Oracle-Original.
*/

SET NOCOUNT ON;

DECLARE @schema_name sysname = N'dbo';
DECLARE @table_name  sysname = N'YourTableName';

DECLARE @object_id int = OBJECT_ID(QUOTENAME(@schema_name) + N'.' + QUOTENAME(@table_name), N'U');

IF @object_id IS NULL
BEGIN
    THROW 50000, 'Tabelle wurde nicht gefunden. Bitte @schema_name und @table_name prüfen und im richtigen Datenbankkontext ausführen.', 1;
END;

PRINT '***********';
PRINT 'Table Level';
PRINT '***********';

;WITH table_space AS
(
    SELECT
        ps.object_id,
        SUM(CASE WHEN ps.index_id IN (0,1) THEN ps.row_count ELSE 0 END) AS row_count,
        SUM(CASE WHEN ps.index_id IN (0,1) THEN ps.reserved_page_count ELSE 0 END) AS reserved_pages,
        SUM(CASE WHEN ps.index_id IN (0,1) THEN ps.used_page_count ELSE 0 END) AS used_pages,
        SUM(CASE WHEN ps.index_id IN (0,1) THEN ps.in_row_data_page_count ELSE 0 END) AS in_row_data_pages,
        SUM(CASE WHEN ps.index_id IN (0,1) THEN ps.lob_used_page_count ELSE 0 END) AS lob_used_pages,
        SUM(CASE WHEN ps.index_id IN (0,1) THEN ps.row_overflow_used_page_count ELSE 0 END) AS row_overflow_used_pages
    FROM sys.dm_db_partition_stats AS ps
    WHERE ps.object_id = @object_id
    GROUP BY ps.object_id
),
stats_last AS
(
    SELECT
        st.object_id,
        MAX(sp.last_updated) AS last_stats_update,
        MAX(sp.rows_sampled) AS max_rows_sampled,
        SUM(CONVERT(bigint, sp.modification_counter)) AS stats_modification_counter
    FROM sys.stats AS st
    OUTER APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
    WHERE st.object_id = @object_id
    GROUP BY st.object_id
)
SELECT
    DB_NAME() AS database_name,
    SCHEMA_NAME(t.schema_id) AS schema_name,
    t.name AS table_name,
    ts.row_count,
    ts.reserved_pages,
    ts.used_pages,
    CAST(ts.reserved_pages * 8.0 / 1024 AS decimal(19,2)) AS reserved_mb,
    CAST(ts.used_pages * 8.0 / 1024 AS decimal(19,2)) AS used_mb,
    CAST(ts.in_row_data_pages * 8.0 / 1024 AS decimal(19,2)) AS in_row_data_mb,
    CAST(ts.lob_used_pages * 8.0 / 1024 AS decimal(19,2)) AS lob_used_mb,
    CAST(ts.row_overflow_used_pages * 8.0 / 1024 AS decimal(19,2)) AS row_overflow_used_mb,
    sl.last_stats_update,
    sl.max_rows_sampled,
    sl.stats_modification_counter,
    t.create_date,
    t.modify_date,
    t.temporal_type_desc,
    t.is_memory_optimized,
    t.lock_escalation_desc
FROM sys.tables AS t
LEFT JOIN table_space AS ts
    ON ts.object_id = t.object_id
LEFT JOIN stats_last AS sl
    ON sl.object_id = t.object_id
WHERE t.object_id = @object_id;

PRINT '';
PRINT '************';
PRINT 'Column Level';
PRINT '************';

SELECT
    c.column_id,
    c.name AS column_name,
    CASE
        WHEN ty.name IN (N'varchar', N'char', N'varbinary', N'binary')
            THEN CONCAT(ty.name, '(', CASE WHEN c.max_length = -1 THEN 'max' ELSE CONVERT(varchar(10), c.max_length) END, ')')
        WHEN ty.name IN (N'nvarchar', N'nchar')
            THEN CONCAT(ty.name, '(', CASE WHEN c.max_length = -1 THEN 'max' ELSE CONVERT(varchar(10), c.max_length / 2) END, ')')
        WHEN ty.name IN (N'decimal', N'numeric')
            THEN CONCAT(ty.name, '(', c.precision, ',', c.scale, ')')
        WHEN ty.name IN (N'datetime2', N'datetimeoffset', N'time')
            THEN CONCAT(ty.name, '(', c.scale, ')')
        ELSE ty.name
    END AS data_type,
    c.max_length,
    c.precision,
    c.scale,
    c.is_nullable,
    c.is_identity,
    c.is_computed,
    cc.definition AS computed_definition,
    dc.definition AS default_definition,
    c.collation_name
FROM sys.columns AS c
JOIN sys.types AS ty
    ON ty.user_type_id = c.user_type_id
LEFT JOIN sys.computed_columns AS cc
    ON cc.object_id = c.object_id
   AND cc.column_id = c.column_id
LEFT JOIN sys.default_constraints AS dc
    ON dc.parent_object_id = c.object_id
   AND dc.parent_column_id = c.column_id
WHERE c.object_id = @object_id
ORDER BY c.column_id;

PRINT '';
PRINT '************';
PRINT 'Stats Level';
PRINT '************';

SELECT
    st.stats_id,
    st.name AS statistics_name,
    st.auto_created,
    st.user_created,
    st.no_recompute,
    st.has_filter,
    st.filter_definition,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.steps AS histogram_steps,
    sp.unfiltered_rows,
    sp.modification_counter,
    STRING_AGG(c.name, N', ') WITHIN GROUP (ORDER BY sc.stats_column_id) AS statistics_columns
FROM sys.stats AS st
LEFT JOIN sys.dm_db_stats_properties(@object_id, st.stats_id) AS sp
    ON 1 = 1
LEFT JOIN sys.stats_columns AS sc
    ON sc.object_id = st.object_id
   AND sc.stats_id = st.stats_id
LEFT JOIN sys.columns AS c
    ON c.object_id = sc.object_id
   AND c.column_id = sc.column_id
WHERE st.object_id = @object_id
GROUP BY
    st.stats_id,
    st.name,
    st.auto_created,
    st.user_created,
    st.no_recompute,
    st.has_filter,
    st.filter_definition,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.steps,
    sp.unfiltered_rows,
    sp.modification_counter
ORDER BY st.stats_id;

PRINT '';
PRINT '***********';
PRINT 'Index Level';
PRINT '***********';

;WITH idx_space AS
(
    SELECT
        ps.object_id,
        ps.index_id,
        SUM(ps.row_count) AS row_count,
        SUM(ps.reserved_page_count) AS reserved_pages,
        SUM(ps.used_page_count) AS used_pages
    FROM sys.dm_db_partition_stats AS ps
    WHERE ps.object_id = @object_id
    GROUP BY ps.object_id, ps.index_id
),
phys AS
(
    SELECT
        ips.object_id,
        ips.index_id,
        MAX(ips.index_depth) AS index_depth,
        SUM(ips.page_count) AS page_count,
        CAST(AVG(ips.avg_fragmentation_in_percent) AS decimal(9,2)) AS avg_fragmentation_pct,
        CAST(AVG(ips.avg_page_space_used_in_percent) AS decimal(9,2)) AS avg_page_space_used_pct,
        CAST(AVG(ips.record_count) AS decimal(19,2)) AS avg_record_count
    FROM sys.dm_db_index_physical_stats(DB_ID(), @object_id, NULL, NULL, 'SAMPLED') AS ips
    GROUP BY ips.object_id, ips.index_id
)
SELECT
    i.index_id,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint,
    i.fill_factor,
    i.is_disabled,
    i.has_filter,
    i.filter_definition,
    ds.name AS data_space_name,
    ispc.row_count,
    ispc.reserved_pages,
    ispc.used_pages,
    CAST(ispc.reserved_pages * 8.0 / 1024 AS decimal(19,2)) AS reserved_mb,
    CAST(ispc.used_pages * 8.0 / 1024 AS decimal(19,2)) AS used_mb,
    p.index_depth,
    p.page_count AS physical_page_count,
    p.avg_fragmentation_pct,
    p.avg_page_space_used_pct,
    STATS_DATE(i.object_id, i.index_id) AS stats_date
FROM sys.indexes AS i
LEFT JOIN sys.data_spaces AS ds
    ON ds.data_space_id = i.data_space_id
LEFT JOIN idx_space AS ispc
    ON ispc.object_id = i.object_id
   AND ispc.index_id = i.index_id
LEFT JOIN phys AS p
    ON p.object_id = i.object_id
   AND p.index_id = i.index_id
WHERE i.object_id = @object_id
ORDER BY i.index_id;

PRINT '';
PRINT '*************';
PRINT 'Index Columns';
PRINT '*************';

SELECT
    i.name AS index_name,
    i.type_desc,
    ic.key_ordinal,
    ic.index_column_id,
    c.name AS column_name,
    ic.is_descending_key,
    ic.is_included_column,
    ic.partition_ordinal
FROM sys.indexes AS i
JOIN sys.index_columns AS ic
    ON ic.object_id = i.object_id
   AND ic.index_id = i.index_id
JOIN sys.columns AS c
    ON c.object_id = ic.object_id
   AND c.column_id = ic.column_id
WHERE i.object_id = @object_id
ORDER BY
    i.index_id,
    ic.key_ordinal,
    ic.index_column_id;

PRINT '';
PRINT '***************';
PRINT 'Partition Level';
PRINT '***************';

SELECT
    p.partition_number,
    i.index_id,
    i.name AS index_name,
    i.type_desc AS index_type,
    p.rows AS partition_rows_sys_partitions,
    ps.row_count AS partition_rows_dm_db_partition_stats,
    ps.reserved_page_count,
    ps.used_page_count,
    CAST(ps.reserved_page_count * 8.0 / 1024 AS decimal(19,2)) AS reserved_mb,
    CAST(ps.used_page_count * 8.0 / 1024 AS decimal(19,2)) AS used_mb,
    ps.in_row_data_page_count,
    ps.lob_used_page_count,
    ps.row_overflow_used_page_count,
    pr.value AS boundary_value
FROM sys.partitions AS p
JOIN sys.indexes AS i
    ON i.object_id = p.object_id
   AND i.index_id = p.index_id
LEFT JOIN sys.dm_db_partition_stats AS ps
    ON ps.object_id = p.object_id
   AND ps.index_id = p.index_id
   AND ps.partition_number = p.partition_number
LEFT JOIN sys.partition_schemes AS psch
    ON psch.data_space_id = i.data_space_id
LEFT JOIN sys.partition_functions AS pf
    ON pf.function_id = psch.function_id
LEFT JOIN sys.partition_range_values AS pr
    ON pr.function_id = pf.function_id
   AND pr.boundary_id = p.partition_number
WHERE p.object_id = @object_id
ORDER BY
    i.index_id,
    p.partition_number;

PRINT '';
PRINT '*****************************';
PRINT 'Incremental Stats Partitions';
PRINT '*****************************';

SELECT
    st.stats_id,
    st.name AS statistics_name,
    isp.partition_number,
    isp.last_updated,
    isp.rows,
    isp.rows_sampled,
    isp.steps AS histogram_steps,
    isp.unfiltered_rows,
    isp.modification_counter
FROM sys.stats AS st
CROSS APPLY sys.dm_db_incremental_stats_properties(st.object_id, st.stats_id) AS isp
WHERE st.object_id = @object_id
ORDER BY
    st.stats_id,
    isp.partition_number;

PRINT '';
PRINT '********************************';
PRINT 'DBCC SHOW_STATISTICS Helper SQL';
PRINT '********************************';

SELECT
    CONCAT(
        'DBCC SHOW_STATISTICS (''',
        QUOTENAME(@schema_name), '.', QUOTENAME(@table_name),
        ''', ''',
        REPLACE(st.name, '''', ''''''),
        ''') WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM;'
    ) AS dbcc_show_statistics_command
FROM sys.stats AS st
WHERE st.object_id = @object_id
ORDER BY st.stats_id;
