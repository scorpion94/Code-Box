select to_timestamp_tz('2007-03-28 10:00:00 US/EASTERN','YYYY-MM-DD HH24:MI:SS TZR') from dual;
/*
TO_TIMESTAMP_TZ('2007-03-2810:00:00US/EASTERN','YYYY-MM-DDHH24:MI:SSTZR')
---------------------------------------------------------------------------
28-MAR-07 10.00.00.000000000 US/EASTERN
*/

select from_tz( to_timestamp('2007-03-28 10:00:00','YYYY-MM-DD HH24:MI:SS'), 'US/EASTERN') from dual;
/*
FROM_TZ(TO_TIMESTAMP('2007-03-2810:00:00','YYYY-MM-DDHH24:MI:SS'),'US/EASTE
---------------------------------------------------------------------------
28-MAR-07 10.00.00.000000000 US/EASTERN
*/

select timestamp '2007-03-28 10:00:00.00 US/EASTERN' from dual;
/*
TIMESTAMP'2007-03-2810:00:00.00US/EASTERN'
---------------------------------------------------------------------------
28-MAR-07 10.00.00.000000000 US/EASTERN
*/