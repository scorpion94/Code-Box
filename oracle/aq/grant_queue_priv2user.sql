begin
  BEGIN
    SYS.DBMS_AQADM.GRANT_QUEUE_PRIVILEGE(privilege  => 'ENQUEUE',
                                         queue_name => '<Queue_name>',
                                         grantee    => '<Queue_owner>');
  END;
