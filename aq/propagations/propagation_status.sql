SELECT 
p.propagation_name,
p.source_queue_owner,
p.source_queue_name,
p.destination_queue_owner,
p.destination_queue_name,
p.destination_dblink,
p.queue_to_queue,
p.status,
p.error_date,
p.error_message 
FROM dba_propagation p;