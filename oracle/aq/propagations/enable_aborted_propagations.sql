/*
 Enable arborted Propagations
*/
BEGIN 
  FOR rec IN (SELECT p.propagation_name FROM dba_propagation p WHERE p.status = 'ABORTED')
    LOOP
      dbms_propagation_adm.start_propagation(propagation_name => rec.propagation_name);
    END LOOP;
END;
/
