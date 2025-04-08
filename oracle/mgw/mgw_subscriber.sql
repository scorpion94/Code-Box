-- Add MGW Subscriber
begin
  dbms_mgwadm.add_subscriber(subscriber_id    => '<name>',
                             propagation_type => dbms_mgwadm.outbound_propagation,
                             queue_name       => '<queue_owner.queue_name>',
                             destination      => '<mgw_mq_link>');
end;
/

-- remove subscriber
begin
    dbms_mgwadm.remove_subscriber('<name>',force => dbms_mgwadm.FORCE);
end;
/

-- stop subscriber
begin
    dbms_mgwadm.unschedule_propagation('<name>');
end;
/

-- reset subscriber
BEGIN
  dbms_mgwadm.reset_job(job_name => '<name>');
END;
/
