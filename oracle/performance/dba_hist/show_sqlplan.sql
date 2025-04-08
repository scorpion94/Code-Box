-- Show SQL-Plan from dba_hist 
-- Important order by ID is needed for a correct display!!
-- Plan shown from Hard_parse not during execution
SELECT * FROM dba_hist_sql_plan WHERE sql_id = 'cd8a56cc0dm6m' AND plan_hash_value = '246766426' ORDER BY ID;
