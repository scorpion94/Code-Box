select * from MGW_MQSERIES_LINKS;

select * from MGW_FOREIGN_QUEUES;

select * from mgw_schedules;

select * from mgw_jobs;

select * from sys.mgw_subscribers;

select * from dba_db_links;

select * from MGW_MQSERIES_LINKS;

SELECT  * FROM mgw_gateway;

/* overview about messages went through */
Select s.PROPAGATED_MSGS, s.FAILURES, s.* FROM mgw_subscribers s order by 1;



