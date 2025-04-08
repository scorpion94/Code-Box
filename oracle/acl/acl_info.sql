SET lines 200;
col acl format a50;
col host format a40;
col principal format a30;
col PRIVILEGE format a10;
col lower_port format 999999;
col upper_port format 999999;

select ap.acl,al.host,ap.principal,ap.privilege,al.lower_port,al.upper_port 
from dba_network_acl_privileges ap 
join dba_network_acls al on ap.acl = al.acl
where 1 = 1
--and al.acl like '%<acl-name>%'
;
