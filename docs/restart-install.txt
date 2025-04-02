# Source-Documentation:
# https://www.oracle.com/de/database/technologies/oracle19c-linux-downloads.html
# https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/installing-oracle-grid-infrastructure-for-a-standalone-server-with-a-new-database-installation.html
# https://docs.oracle.com/en/database/oracle/oracle-database/23/ladbi/gridsetup-command-options.html 
# https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/installing-the-cvuqdisk-rpm-for-linux.html 
# https://www.br8dba.com/cssd-wont-start-automatically/
# 
# Download following files:
# LINUX.X64_193000_grid_home.zip        # GI-Base Image
# p37257886_190000_Linux-x86-64.zip     # Latest PSU
# p6880880_190000_Linux-x86-64.zip       # Latest OPatch
# 
mkdir -p /grid/product/db_lnx_gi_19c
mkdir /home/oracle/patches

unzip /home/oracle/Downloads/LINUX.X64_193000_grid_home.zip -d /grid/product/db_lnx_gi_19c/
unzip /home/oracle/Downloads/p37257886_190000_Linux-x86-64.zip -d /home/oracle/patches/
cd /grid/product/db_lnx_gi_19c/
mv /grid/product/db_lnx_gi_19c/OPatch /grid/product/db_lnx_gi_19c/OPatch_old
unzip /home/oracle/Downloads/p6880880_190000_Linux-x86-64.zip -d /grid/product/db_lnx_gi_19c/

[root@vbox ~]# cd /grid/product/db_lnx_gi_19c/
[root@vbox db_lnx_gi_19c]# find . -iname "*cvuqdisk*"
./cv/remenv/cvuqdisk-1.0.10-1.rpm
./cv/rpm/cvuqdisk-1.0.10-1.rpm
[root@vbox db_lnx_gi_19c]# cd cv/rpm/
[root@vbox rpm]# pwd
/grid/product/db_lnx_gi_19c/cv/rpm
[root@vbox rpm]# rpm -ivh cvuqdisk-1.0.10-1.rpm 
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:cvuqdisk-1.0.10-1                ################################# [100%]

# Check swap size (mind 10GB)

# Check kernel.panic parameter
# Modify /etc/sysctl.conf and add parameter if needed 
[root@vbox ~]# swapon
NAME      TYPE      SIZE USED PRIO
/dev/dm-1 partition  18G   0B   -2
[root@vbox ~]#
#
# This step takes time!!!
# Logfolder: /grid/product/db_lnx_gi_19c/cfgtoollogs/opatchauto
[root@vbox rpm]# sysctl -a | grep kernel.panic
kernel.panic = 0
Modify /etc/sysctl.conf and add kernel.panic = 1
sysctl -p

# Add IP in /etc/hosts





[oracle@vbox db_lnx_gi_19c]$ ./gridSetup.sh -silent \
-waitforcompletion -ignorePrereqFailure -lenientInstallMode \
-applyPSU /home/oracle/patches/37257886/ \
INVENTORY_LOCATION=/oracle \
SELECTED_LANGUAGES=en \
oracle.install.option=HA_CONFIG \
ORACLE_BASE=/grid \
oracle.install.asm.OSDBA=oinstall \
oracle.install.asm.OSOPER=oinstall \
oracle.install.asm.OSASM=oinstall \
oracle.install.crs.config.ClusterConfiguration=STANDALONE \
oracle.install.crs.config.configureAsExtendedCluster=false \
oracle.install.crs.config.gpnp.configureGNS=false \
oracle.install.crs.config.autoConfigureClusterNodeVIP=false \
oracle.install.asm.diskGroup.redundancy=EXTERNAL \
oracle.install.asm.diskGroup.AUSize=4 \
oracle.install.asm.diskGroup.disks=/dev/sdb1,/dev/sdc1 \
oracle.install.asm.diskGroup.diskDiscoveryString=/dev/sd* \
oracle.install.crs.rootconfig.executeRootScript=false
Preparing the home to patch...
Applying the patch /home/oracle/patches/37257886/...
Successfully applied the patch.
The log can be found at: /tmp/GridSetupActions2025-02-17_02-01-19PM/installerPatchActions_2025-02-17_02-01-19PM.log
Launching Oracle Grid Infrastructure Setup Wizard...

oracle@vbox db_lnx_gi_19c]$ bash 0.sh 
Launching Oracle Grid Infrastructure Setup Wizard...

[WARNING] [INS-30011] The SYS password entered does not conform to the Oracle recommended standards.
   CAUSE: Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
   ACTION: Provide a password that conforms to the Oracle recommended standards.
[FATAL] [INS-30001] The ASMSNMP password is empty.
   CAUSE: The ASMSNMP password should not be empty.
   ACTION: Provide a non-empty password.
Moved the install session logs to:
 /oracle/logs/GridSetupActions2025-02-17_02-35-09PM
[oracle@vbox db_lnx_gi_19c]$ vi 0.sh 
[oracle@vbox db_lnx_gi_19c]$ bash 0.sh 
Launching Oracle Grid Infrastructure Setup Wizard...

[WARNING] [INS-30011] The SYS password entered does not conform to the Oracle recommended standards.
   CAUSE: Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
   ACTION: Provide a password that conforms to the Oracle recommended standards.
[WARNING] [INS-30011] The ASMSNMP password entered does not conform to the Oracle recommended standards.
   CAUSE: Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
   ACTION: Provide a password that conforms to the Oracle recommended standards.
[WARNING] [INS-41813] OSDBA for ASM, OSOPER for ASM, and OSASM are the same OS group.
   CAUSE: The group you selected for granting the OSDBA for ASM group for database access, and the OSOPER for ASM group for startup and shutdown of Oracle ASM, is the same group as the OSASM group, whose members have SYSASM privileges on Oracle ASM.
   ACTION: Choose different groups as the OSASM, OSDBA for ASM, and OSOPER for ASM groups.
[WARNING] [INS-41875] Oracle ASM Administrator (OSASM) Group specified is same as the users primary group.
   CAUSE: Operating system group oinstall specified for OSASM Group is same as the users primary group.
   ACTION: It is not recommended to have OSASM group same as primary group of user as it becomes the inventory group. Select any of the group other than the primary group to avoid misconfiguration.
[WARNING] [INS-32047] The location (/oracle) specified for the central inventory is not empty.
   ACTION: It is recommended to provide an empty location for the inventory.
The response file for this session can be found at:
 /grid/product/db_lnx_gi_19c/install/response/grid_2025-02-17_02-41-41PM.rsp

You can find the log of this install session at:
 /tmp/GridSetupActions2025-02-17_02-41-41PM/gridSetupActions2025-02-17_02-41-41PM.log


As a root user, execute the following script(s):
	1. /oracle/orainstRoot.sh
	2. /grid/product/db_lnx_gi_19c/root.sh

Execute /grid/product/db_lnx_gi_19c/root.sh on the following nodes: 
[vbox]



Successfully Setup Software.
As install user, execute the following command to complete the configuration.
	/grid/product/db_lnx_gi_19c/gridSetup.sh -executeConfigTools -responseFile /grid/product/db_lnx_gi_19c/install/response/grid_2025-02-17_02-41-41PM.rsp [-silent]
Note: The required passwords need to be included in the response file.


Moved the install session logs to:
 /oracle/logs/GridSetupActions2025-02-17_02-41-41PM
[oracle@vbox db_lnx_gi_19c]$ 


[root@vbox ~]# /oracle/orainstRoot.sh
Changing permissions of /oracle.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /oracle to oinstall.
The execution of the script is complete.
[root@vbox ~]# /grid/product/db_lnx_gi_19c/root.sh
Check /grid/product/db_lnx_gi_19c/install/root_vbox_2025-02-17_15-06-48-691681300.log for the output of root script



[root@vbox ~]# 
[root@vbox ~]# 
[root@vbox ~]# 
[root@vbox ~]# /grid/product/db_lnx_gi_19c/root.sh
Check /grid/product/db_lnx_gi_19c/install/root_vbox_2025-02-17_15-38-55-202543966.log for the output of root script






https://www.br8dba.com/cssd-wont-start-automatically/