[root@localhost ~]# udevadm info --query=property --name=/dev/sdb | grep -w ID_SERIAL
ID_SERIAL=VBOX_HARDDISK_VB83c2501f-b865f831
[root@localhost ~]# udevadm info --query=property --name=/dev/sdc | grep -w ID_SERIAL
ID_SERIAL=VBOX_HARDDISK_VB3d24ad93-08dd086d
[root@localhost ~]# 

[root@localhost ~]# cat /etc/udev/rules.d/99-asm-disks.rules 
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB83c2501f-b865f831", OWNER="oracle", GROUP="oracle", MODE="0660", SYMLINK+="asm-data01"
ENV{ID_SERIAL}=="VBOX_HARDDISK_VB3d24ad93-08dd086d", OWNER="oracle", GROUP="oracle", MODE="0660", SYMLINK+="asm-fra01"
[root@localhost ~]# 


[root@localhost ~]# udevadm trigger
[root@localhost ~]# udevadm control --reload-rules
[root@localhost ~]# 

[root@localhost ~]# ls -l /dev/asm-*
lrwxrwxrwx. 1 root root 3 Jan 17 16:10 /dev/asm-data01 -> sdb
lrwxrwxrwx. 1 root root 3 Jan 17 16:10 /dev/asm-fra01 -> sdc
[root@localhost ~]# ls -l /dev/sdb /dev/sdc
brw-rw----. 1 oracle oracle 8, 16 Jan 17 16:10 /dev/sdb
brw-rw----. 1 oracle oracle 8, 32 Jan 17 16:10 /dev/sdc
[root@localhost ~]# 