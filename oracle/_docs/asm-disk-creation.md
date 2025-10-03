# ASM-Disk-Creation
# https://dbapostmortem.com/create-asm-disk-on-linux/

# Create VDI-Disks in Virtual Box after reboot they should be visible via lsblk

[root@vbox ~]# lsblk
NAME             MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                8:0    0   40G  0 disk 
├─sda1             8:1    0    2G  0 part /boot
└─sda2             8:2    0   38G  0 part 
  ├─ol_vbox-root 252:0    0   10G  0 lvm  /
  ├─ol_vbox-swap 252:1    0    8G  0 lvm  [SWAP]
  └─ol_vbox-home 252:2    0   20G  0 lvm  /home
sdb                8:16   0   20G  0 disk  # <-- Disk 1
sdc                8:32   0   20G  0 disk  # <-- Disk 2
sdd                8:48   0   20G  0 disk  # <-- Disk 3
sr0               11:0    1 57.4M  0 rom  /run/media/tmp/VBox_GAs_7.1.6
[root@vbox ~]# 

[root@vbox ~]# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.37.4).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x4a0267fb.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-41943039, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-41943039, default 41943039): 

Created a new partition 1 of type 'Linux' and of size 20 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

[root@vbox ~]# 


[root@vbox ~]# lsblk
NAME             MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                8:0    0   40G  0 disk 
├─sda1             8:1    0    2G  0 part /boot
└─sda2             8:2    0   38G  0 part 
  ├─ol_vbox-root 252:0    0   10G  0 lvm  /
  ├─ol_vbox-swap 252:1    0    8G  0 lvm  [SWAP]
  └─ol_vbox-home 252:2    0   20G  0 lvm  /home
sdb                8:16   0   20G  0 disk 
└─sdb1             8:17   0   20G  0 part 
sdc                8:32   0   20G  0 disk 
└─sdc1             8:33   0   20G  0 part 
sdd                8:48   0   20G  0 disk 
└─sdd1             8:49   0   20G  0 part 
sr0               11:0    1 57.4M  0 rom  /run/media/tmp/VBox_GAs_7.1.6
[root@vbox ~]# 

[root@vbox ~]# oracleasm createdisk DATA1 /dev/sdb1
Writing disk header: done
Instantiating disk: done
[root@vbox ~]# oracleasm createdisk DATA2 /dev/sdc1
Writing disk header: done
Instantiating disk: done
[root@vbox ~]# oracleasm createdisk FRA /dev/sdd1
Writing disk header: done
Instantiating disk: done
[root@vbox ~]# oracleasm scandisks
Reloading disk partitions: done
Cleaning any stale ASM disks...
Setting up iofilter map for ASM disks: done
Scanning system for ASM disks...
[root@vbox ~]# oracleasm listdisks
DATA1
DATA2
FRA
[root@vbox ~]# 


[root@vbox ~]# lsblk -fm
NAME             FSTYPE      FSVER            LABEL          UUID                                   FSAVAIL FSUSE% MOUNTPOINTS                    SIZE OWNER  GROUP    MODE
sda                                                                                                                                                40G root   disk     brw-rw----
├─sda1           xfs                                         9585d78f-9c65-490c-a651-cbfe3785b904      1.6G    19% /boot                            2G root   disk     brw-rw----
└─sda2           LVM2_member LVM2 001                        fijQ10-F9oz-uWT8-EsNZ-fBOB-6eMW-jq1RBC                                                38G root   disk     brw-rw----
  ├─ol_vbox-root xfs                                         2b43cd9e-9cb4-4731-8680-65018acef5d5      4.7G    53% /                               10G root   disk     brw-rw----
  ├─ol_vbox-swap swap        1                               fbbb4a21-99cf-452f-8f47-35454dcdbbce                  [SWAP]                           8G root   disk     brw-rw----
  └─ol_vbox-home xfs                                         06ec5d4f-bc78-42d2-b355-f91b3af2a78e     19.8G     1% /home                           20G root   disk     brw-rw----
sdb                                                                                                                                                20G root   disk     brw-rw----
└─sdb1           oracleasm                    DATA1                                                                                                20G oracle oinstall brw-rw----
sdc                                                                                                                                                20G root   disk     brw-rw----
└─sdc1           oracleasm                    DATA2                                                                                                20G oracle oinstall brw-rw----
sdd                                                                                                                                                20G root   disk     brw-rw----
└─sdd1           oracleasm                    FRA                                                                                                  20G oracle oinstall brw-rw----
sr0              iso9660     Joliet Extension VBox_GAs_7.1.6 2025-01-21-13-18-27-98                       0   100% /run/media/tmp/VBox_GAs_7.1.6 57.4M root   cdrom    brw-rw----
[root@vbox ~]# 
