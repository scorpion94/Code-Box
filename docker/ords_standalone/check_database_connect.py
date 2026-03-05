import oracledb
import os


db_host = os.environ["DB_HOST"]
db_port = os.environ["DB_PORT"]
db_servicename = os.environ["DB_SERVICENAME"]
pwfile= os.environ["PWFILE"]

with open(pwfile, "r") as f:
    sys_pw = f.readline().strip()


dsn = db_host + ":" + db_port + "/" + db_servicename

try:
    conn = oracledb.connect(
        user="sys",
        password=sys_pw,
        dsn=dsn,
        mode=oracledb.SYSDBA
    )

    print("Connection successful")

    conn.close()

except oracledb.Error as e:
    print("Connection failed:", e)