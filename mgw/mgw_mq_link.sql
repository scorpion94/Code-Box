declare
   v_mgw_properties sys.mgw_properties;
   v_mgw_mq_properties sys.mgw_mqseries_properties;
begin
    v_mgw_mq_properties                    := sys.mgw_mqseries_properties.construct(); 
    v_mgw_mq_properties.max_connections    := 1;
    v_mgw_mq_properties.interface_type     := DBMS_MGWADM.MQSERIES_BASE_JAVA_INTERFACE;
    v_mgw_mq_properties.username           := '****';
    v_mgw_mq_properties.password           := '****';
    v_mgw_mq_properties.hostname           := '';
    v_mgw_mq_properties.port               := <port>;
    v_mgw_mq_properties.channel            := '';
    v_mgw_mq_properties.queue_manager      := ''; 
    v_mgw_mq_properties.outbound_log_queue := '';
    v_mgw_mq_properties.inbound_log_queue  := '';
       
    dbms_mgwadm.create_msgsystem_link(
       linkname => 'MQLINK_SWIFT', 
       properties => v_mgw_mq_properties, 
       options => v_mgw_properties);
 end;
 /
