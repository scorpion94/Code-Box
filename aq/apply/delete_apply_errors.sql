BEGIN
  FOR rec IN (
SELECT *
  FROM DBA_APPLY_ERROR t order by t.source_commit_scn)
  LOOP
    BEGIN
  DBMS_APPLY_ADM.EXECUTE_ERROR(
    local_transaction_id => rec.local_transaction_id,
    execute_as_user      => FALSE,
    user_procedure       => NULL);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
  END LOOP;
end;
