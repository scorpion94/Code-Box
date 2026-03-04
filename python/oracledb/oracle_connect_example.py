import oracledb

pw = input("Enter Password: ")

conn = oracledb.connect(
    user="system",
    password=pw,
    dsn="192.168.56.10:1521/ORCL"
)

cursor = conn.cursor()
cursor.execute("select sysdate from dual")
print(cursor.fetchone())

cursor.close()
conn.close()