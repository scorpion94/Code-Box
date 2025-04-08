
--get Queues from Queue_table
select * from dba_queues q where q.QUEUE_TABLE = '&table_name'; 
--get Message Type  (95% of all cases JMS_TEXT)
select * from dba_queue_tables t where t.QUEUE_TABLE = '&table_name';
