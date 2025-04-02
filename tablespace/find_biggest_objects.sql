SELECT OWNER, 
       SEGMENT_NAME, 
       SEGMENT_TYPE,
       GB
FROM (
       SELECT OWNER, 
              SEGMENT_NAME, 
              SEGMENT_TYPE,
              BYTES / 1024 / 1024 / 1024 "GB"
        FROM DBA_SEGMENTS
          WHERE TABLESPACE_NAME = '&tablespace_name'
        ORDER BY BYTES DESC
      )
      WHERE ROWNUM < 11;
