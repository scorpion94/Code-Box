select t.tablespace_name,
       t.file_name,
       round(t.bytes / 1024 / 1024 / 1024, 2) as GB_USED,
       t.maxbytes / 1024 / 1024 / 1024 as GB_MAX
  from dba_temp_files t;
