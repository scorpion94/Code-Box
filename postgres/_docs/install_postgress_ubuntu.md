# How to install / configure Postgres on Ubuntu

1) Install necessary packages
````bash
sudo apt install -y  postgresql-16 \
  postgresql-contrib-16 \
  postgresql-common
````

2) Check if systemd service is running:
````bash
ubuntu@vm-pg-01:~$ sudo systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/usr/lib/systemd/system/postgresql.service; enabled; preset: enabled)
     Active: active (exited) since Fri 2026-02-27 06:28:53 UTC; 2min 47s ago
   Main PID: 5763 (code=exited, status=0/SUCCESS)
        CPU: 980us

Feb 27 06:28:53 vm-pg-01 systemd[1]: Starting postgresql.service - PostgreSQL RDBMS...
Feb 27 06:28:53 vm-pg-01 systemd[1]: Finished postgresql.service - PostgreSQL RDBMS.
ubuntu@vm-pg-01:~$ 
````

3) List Cluster
````bash
ubuntu@vm-pg-01:~$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
16  main    5432 online postgres /var/lib/postgresql/16/main /var/log/postgresql/postgresql-16-main.log
ubuntu@vm-pg-01:~$ 
````
4) Check if Login works:
````bash
ubuntu@vm-pg-01:~$ sudo -u postgres psql
psql (16.11 (Ubuntu 16.11-0ubuntu0.24.04.1))
Type "help" for help.

postgres=# \l
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(3 rows)

postgres=# 
````
