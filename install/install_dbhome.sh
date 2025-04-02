#!/bin/bash
export ORACLE_HOME=/u01/app/oracle/product/1926_ee
export ORACLE_HOSTNAME=$(hostname -s)
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_BASE=
export PATCH_LOCATION=

if [ ! -d ${ORACLE_HOME} ]
then
    echo  "${ORACLE_HOME} does not exists!"
    exit 1
fi

cd ${ORACLE_HOME}

./runInstaller -ignorePrereq -waitforcompletion -silent \
    -applyRU /home/oracle/patches/37260974 \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp \
    oracle.install.option=INSTALL_DB_SWONLY \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
    UNIX_GROUP_NAME=oinstall \
    INVENTORY_LOCATION=${ORA_INVENTORY} \
    SELECTED_LANGUAGES=en,en_GB \
    ORACLE_HOME=${ORACLE_HOME} \
    ORACLE_BASE=${ORACLE_BASE} \
    oracle.install.db.InstallEdition=EE \
    oracle.install.db.OSDBA_GROUP=dba \
    oracle.install.db.OSBACKUPDBA_GROUP=dba \
    oracle.install.db.OSDGDBA_GROUP=dba \
    oracle.install.db.OSKMDBA_GROUP=dba \
    oracle.install.db.OSRACDBA_GROUP=dba \
    oracle.install.db.rootconfig.executeRootScript=false \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
    DECLINE_SECURITY_UPDATES=true
