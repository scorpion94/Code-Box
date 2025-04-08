DECLARE
  deq_options  DBMS_AQ.DEQUEUE_OPTIONS_T;
  enq_options  DBMS_AQ.ENQUEUE_OPTIONS_T;
  message_prop DBMS_AQ.MESSAGE_PROPERTIES_T;
  -- Use correct message-type
  -- message      SYS.MGW_BASIC_MSG_T
  -- message      SYS.Anydata;
  message      SYS.AQ$_JMS_TEXT_MESSAGE;
  msg_id       RAW(16) ;--:= '<msgid>';
  NO_MESSAGES EXCEPTION;
  PRAGMA EXCEPTION_INIT (NO_MESSAGES, -25228);
BEGIN
  deq_options.wait := DBMS_AQ.NO_WAIT;
  deq_options.navigation := DBMS_AQ.FIRST_MESSAGE;
  deq_options.msgid := msg_id;
  LOOP
    DBMS_AQ.DEQUEUE(QUEUE_NAME => '<Queue_owner>.<queue_name>'
                   ,DEQUEUE_OPTIONS => deq_options
                   ,MESSAGE_PROPERTIES => message_prop
                   ,PAYLOAD => message
                   ,MSGID => msg_id);
    msg_id := NULL;
    DBMS_AQ.ENQUEUE(queue_name => '<Queue_owner>.<queue_name>'
                  , enqueue_options=> enq_options
                  , message_properties => message_prop
                  , payload => message
                  , msgid => msg_id);
    COMMIT;
  END LOOP;
EXCEPTION
  WHEN NO_MESSAGES THEN
    NULL;
END;
/

