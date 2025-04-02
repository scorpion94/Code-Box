select f.file_id,
       f.tablespace_name,
       f.file_name,
       round(f.bytes / 1024 / 1024 / 1024, 2) as GB_USED,
       f.maxbytes / 1024 / 1024 / 1024 as GB_MAX
  from dba_data_files f
 where f.tablespace_name like '&tablespace_name'
  order by f.tablespace_name;
