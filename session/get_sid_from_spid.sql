select b.spid,a.sid, a.serial#,a.username, a.osuser 
from v$session a, v$process b 
where a.paddr= b.addr 
and b.spid='&spid' 
order by b.spid;
