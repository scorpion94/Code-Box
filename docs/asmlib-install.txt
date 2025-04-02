Installing ASM

########################################################################################################
############################ NOTES #####################################################################

https://yum.oracle.com/mirror/ol9/x86_64/ --> Mirrors (might be useful)


# Install ASM Docu Oracle 
https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/installing-and-configuring-oracle-asmlib-software.html








##########################################################################################################

# Prerequirements:
yum install install gcc
yum install install oracle-database-preinstall-19c

# Create Groups:
# https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/creating-an-oracle-software-owner-user.html#GUID-C1E5CEA8-741A-4500-B03E-B4A6BC1E87BB

for rec in dba asmdba backupdba dgdba kmdba racdba; do groupadd ${rec}; done

/usr/sbin/useradd -u 1000 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba oracle
/usr/sbin/useradd -u 1001 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba grid

# Change Passwords for Oracle + Grid

[root@vbox ~]# passwd oracle
Changing password for user oracle.
New password: 
BAD PASSWORD: The password is shorter than 8 characters
Retype new password: 
passwd: all authentication tokens updated successfully.

[root@vbox ~]# passwd grid
Changing password for user grid.
New password: 
BAD PASSWORD: The password is shorter than 8 characters
Retype new password: 
passwd: all authentication tokens updated successfully.
[root@vbox ~]# 

# Delete temporary User, since its not needed anymore:
[root@vbox ~]# userdel -r tmp


##########################################################################################################
##########################################################################################################

Download RPM Asmlib:
https://www.oracle.com/linux/downloads/linux-asmlib-v9-downloads.html#

OL9 Modify Repo for Addons:
/etc/yum.repos.d//etc/yum.repos.d

[ol9_addons]
name=Oracle Linux 9 Addons ($basearch)
baseurl=https://yum$ociregion.$ocidomain/repo/OracleLinux/OL9/addons/$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=0 --> 1

[root@vbox yum.repos.d]# rpm -ivh /home/tmp/Downloads/oracleasmlib-3.0.0-13.el9.x86_64.rpm 
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:oracleasmlib-3.0.0-13.el9        ################################# [100%]
[root@vbox yum.repos.d]# dnf install oracleasm-support
Last metadata expiration check: 0:06:29 ago on Mon 17 Feb 2025 07:57:46 AM CET.
Dependencies resolved.
====================================================================================================================================================================================================================
 Package                                                  Architecture                                  Version                                             Repository                                         Size
====================================================================================================================================================================================================================
Installing:
 oracleasm-support                                        x86_64                                        3.0.0-7.el9                                         ol9_addons                                        161 k

Transaction Summary
====================================================================================================================================================================================================================
Install  1 Package

Total download size: 161 k
Installed size: 358 k
Is this ok [y/N]: y
Downloading Packages:
oracleasm-support-3.0.0-7.el9.x86_64.rpm                                                                                                                                             30 kB/s | 161 kB     00:05    
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                                30 kB/s | 161 kB     00:05     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                            1/1 
  Installing       : oracleasm-support-3.0.0-7.el9.x86_64                                                                                                                                                       1/1 
  Running scriptlet: oracleasm-support-3.0.0-7.el9.x86_64                                                                                                                                                       1/1 
Note: Forwarding request to 'systemctl enable oracleasm.service'.
Synchronizing state of oracleasm.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable oracleasm
Created symlink /etc/systemd/system/multi-user.target.wants/oracleasm.service → /usr/lib/systemd/system/oracleasm.service.

  Verifying        : oracleasm-support-3.0.0-7.el9.x86_64                                                                                                                                                       1/1 

Installed:
  oracleasm-support-3.0.0-7.el9.x86_64                                                                                                                                                                              

Complete!

##########################################################################################################
##########################################################################################################

# Configure ASM

root@vbox ~]# oracleasm configure -i
Configuring the Oracle ASM library driver.

This will configure the on-boot properties of the Oracle ASM library
driver.  The following questions will determine whether the driver is
loaded on boot and what permissions it will have.  The current values
will be shown in brackets ('[]').  Hitting <ENTER> without typing an
answer will keep that current value.  Ctrl-C will abort.

Default user to own the driver interface []: oracle
Default group to own the driver interface []: oinstall
Start Oracle ASM library driver on boot (y/n) [n]: y
Scan for Oracle ASM disks on boot (y/n) [y]: y
Maximum number of disks that may be used in ASM system [2048]: 10
Enable iofilter if kernel supports it (y/n) [y]: y
Writing Oracle ASM library driver configuration: done
[root@vbox ~]# 

[root@vbox ~]# oracleasm init
Mounting ASMlib driver filesystem: Not applicable with kernel 5.15.0
Setting up iofilter map for ASM disks: done

[root@vbox ~]# systemctl enable oracleasm
Synchronizing state of oracleasm.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable oracleasm

[root@vbox ~]# systemctl start oracleasm

[root@vbox ~]# systemctl status oracleasm
● oracleasm.service - Load oracleasm Modules
     Loaded: loaded (/usr/lib/systemd/system/oracleasm.service; enabled; preset: disabled)
     Active: active (exited) since Mon 2025-02-17 08:18:46 CET; 11s ago
    Process: 6155 ExecStartPre=/usr/bin/udevadm settle -t 120 (code=exited, status=0/SUCCESS)
    Process: 6156 ExecStart=/usr/sbin/oracleasm.init start_sysctl (code=exited, status=0/SUCCESS)
   Main PID: 6156 (code=exited, status=0/SUCCESS)
        CPU: 143ms

Feb 17 08:18:46 vbox systemd[1]: Starting Load oracleasm Modules...
Feb 17 08:18:46 vbox oracleasm.init[6156]: Initializing the Oracle ASMLib driver: OK
Feb 17 08:18:46 vbox oracleasm.init[6156]: Scanning the system for Oracle ASMLib disks: OK
Feb 17 08:18:46 vbox systemd[1]: Finished Load oracleasm Modules.
[root@vbox ~]# 







