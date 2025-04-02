DECLARE
v_jms_message SYS.AQ$_JMS_TEXT_MESSAGE;

enq_opt DBMS_AQ.ENQUEUE_OPTIONS_T;
msg_prop DBMS_AQ.MESSAGE_PROPERTIES_T;
recipients DBMS_AQ.AQ$_recipient_list_t;
msg_handle RAW(16);
BEGIN
enq_opt.delivery_mode := DBMS_AQ.buffered;
enq_opt.visibility := DBMS_AQ.IMMEDIATE;
recipients(1) := SYS.AQ$_AGENT('TEST', 'AQ_TEST', null);
msg_prop.recipient_list := recipients;
v_jms_message := SYS.AQ$_JMS_TEXT_MESSAGE.CONSTRUCT();
v_jms_message.set_text('Test');

DBMS_AQ.Enqueue( QUEUE_NAME => 'TEST.AQ_TEST'
, ENQUEUE_OPTIONS => enq_opt
, MESSAGE_PROPERTIES => msg_prop
, PAYLOAD => v_jms_message
, MSGID => msg_handle);
END;
/
