# Postgres commands

### List Databases
````sql
\l
select * from pg_database;
````

### Describe Table
````sql
\d pg_database -- Quick Table Describe
\d+ pg_database -- More details from table including performance
````

### Connect to Database
````sql
\c database_name
````

