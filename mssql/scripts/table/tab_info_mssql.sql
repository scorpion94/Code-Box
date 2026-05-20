/*
    tab_info_mssql.sql
    Zweck:
      SQL-Server-Variante von Oracle tab_info.sql.

    Parameter:
      @schema_like : Schema-Filter, z.B. N'dbo' oder N'%'
      @table_like  : Tabellenname-Filter, z.B. N'Customer%' oder N'%'

    Ausführen:
      USE [DeineDatenbank];
      GO
      :r tab_info_mssql.sql

    Hinweis:
      Oracle "frag_pct" aus DBA_TABLES.BLOCKS/AVG_ROW_LEN existiert in SQL Server nicht 1:1.
      Dieses Skript zeigt deshalb:
        - space_unused_pct = Anteil reservierter, aber nicht verwendeter Pages
        - avg_fragmentation_in_percent aus sys.dm_db_index_physical_stats für Heap/Clustered Index
*/

SET NOCOUNT ON;

DECLARE @schema_like sysname = N'%';
DECLARE @table_like  sysname = N'%';

;WITH target_tables AS
(
    SELECT
        t.object_id,
        s.name AS schema_name,
        t.name AS table_name,
        t.create_date,
        t.modify_date
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON s.schema_id = t.schema_id
    WHERE
        t.is_ms_shipped = 0
        AND s.name LIKE @schema_like
        AND t.name LIKE @table_like
),
base_index AS
(
    SELECT
        i.object_id,
        i.index_id,
        i.name AS base_index_name,
        i.type_desc AS base_index_type,
        ds.name AS data_space_name
    FROM sys.indexes AS i
    LEFT JOIN sys.data_spaces AS ds
        ON ds.data_space_id = i.data_space_id
    WHERE i.index_id IN (0, 1) -- 0 = HEAP, 1 = CLUSTERED
),
partition_space AS
(
    SELECT
        ps.object_id,
        ps.index_id,
        ps.partition_number,
        SUM(ps.row_count) AS row_count,
        SUM(ps.reserved_page_count) AS reserved_pages,
        SUM(ps.used_page_count) AS used_pages,
        SUM(ps.in_row_data_page_count) AS in_row_data_pages,
        SUM(ps.lob_used_page_count) AS lob_used_pages,
        SUM(ps.row_overflow_used_page_count) AS row_overflow_used_pages
    FROM sys.dm_db_partition_stats AS ps
    WHERE ps.index_id IN (0, 1)
    GROUP BY
        ps.object_id,
        ps.index_id,
        ps.partition_number
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
    GROUP BY st.object_id
),
phys AS
(
    SELECT
        ips.object_id,
        ips.index_id,
        ips.partition_number,
        MAX(ips.avg_fragmentation_in_percent) AS avg_fragmentation_in_percent,
        SUM(ips.page_count) AS physical_page_count
    FROM sys.dm_db_index_physical_stats
    (
        DB_ID(),
        NULL,
        NULL,
        NULL,
        'LIMITED'
    ) AS ips
    WHERE ips.index_id IN (0, 1)
    GROUP BY
        ips.object_id,
        ips.index_id,
        ips.partition_number
)
SELECT
    DB_NAME() AS database_name,
    tt.schema_name,
    tt.table_name,
    bi.base_index_type,
    bi.base_index_name,
    bi.data_space_name,
    ps.partition_number,
    ps.row_count,
    ps.reserved_pages,
    ps.used_pages,
    CAST(ps.reserved_pages * 8.0 / 1024 AS decimal(19,2)) AS reserved_mb,
    CAST(ps.used_pages     * 8.0 / 1024 AS decimal(19,2)) AS used_mb,
    CAST(ps.in_row_data_pages * 8.0 / 1024 AS decimal(19,2)) AS in_row_data_mb,
    CAST(ps.lob_used_pages * 8.0 / 1024 AS decimal(19,2)) AS lob_used_mb,
    CAST(ps.row_overflow_used_pages * 8.0 / 1024 AS decimal(19,2)) AS row_overflow_used_mb,
    CAST
    (
        CASE
            WHEN ps.reserved_pages = 0 THEN NULL
            ELSE 100.0 - ((ps.used_pages * 100.0) / ps.reserved_pages)
        END
        AS decimal(9,2)
    ) AS space_unused_pct,
    CAST(phys.avg_fragmentation_in_percent AS decimal(9,2)) AS avg_fragmentation_pct,
    CAST
    (
        CASE
            WHEN ps.row_count = 0 THEN NULL
            ELSE (ps.used_pages * 8192.0) / ps.row_count
        END
        AS decimal(19,2)
    ) AS approx_used_bytes_per_row,
    sl.last_stats_update,
    sl.max_rows_sampled,
    sl.stats_modification_counter,
    tt.create_date,
    tt.modify_date
FROM target_tables AS tt
LEFT JOIN base_index AS bi
    ON bi.object_id = tt.object_id
LEFT JOIN partition_space AS ps
    ON ps.object_id = bi.object_id
   AND ps.index_id = bi.index_id
LEFT JOIN stats_last AS sl
    ON sl.object_id = tt.object_id
LEFT JOIN phys
    ON phys.object_id = ps.object_id
   AND phys.index_id = ps.index_id
   AND phys.partition_number = ps.partition_number
ORDER BY
    tt.schema_name,
    tt.table_name,
    ps.partition_number;
