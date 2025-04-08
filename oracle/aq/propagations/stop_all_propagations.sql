/*
  Stop all Propagations
*/
BEGIN 
  FOR rec IN (SELECT p.propagation_name FROM dba_propagation p where p.status NOT IN ('ABORTED','DISABLED'))
    LOOP
      dbms_propagation_adm.stop_propagation(propagation_name => rec.propagation_name,force => TRUE);
    END LOOP;
END;
/
