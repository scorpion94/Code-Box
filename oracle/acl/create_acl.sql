--ACL assinged to more then one User 
begin
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('<ACL_NAME>.xml','<Description>','<Owner>',TRUE,'connect');
    DBMS_NETWORK_ACL_ADMIN.add_privilege('<ACL_NAME>.xml','<Owner>',TRUE,'resolve');
    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('<ACL_NAME>.xml','<url / servername>',<port>);
    -- DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('<ACL_NAME>.xml','<url / servername>'); -- if no port should be provided
    commit;
end;
/