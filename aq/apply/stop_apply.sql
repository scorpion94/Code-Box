declare
    apply_name varchar2(200);
BEGIN 
  dbms_apply_adm.stop_apply(apply_name => '&apply_name',force => TRUE);
END;
/
