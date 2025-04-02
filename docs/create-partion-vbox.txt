############################################################################################################
# General Informations ######
https://www.thomas-krenn.com/de/wiki/LVM_Grundlagen
https://www.thomas-krenn.com/de/wiki/LVM_Grundkonfiguration
https://starbeamrainbowlabs.com/blog/article.php?article=posts/428-lvm-beginners.html
https://medium.com/@charles.vissol/create-a-new-partition-with-lvm-ca633d9a4f5b

############################################################################################################
[oracle@vbox ~]$ lsblk -fm
NAME             FSTYPE      FSVER            LABEL          UUID                                   FSAVAIL FSUSE% MOUNTPOINTS                       SIZE OWNER  GROUP    MODE
sda                                                                                                                                                   40G root   disk     brw-rw----
├─sda1           xfs                                         9585d78f-9c65-490c-a651-cbfe3785b904      1.6G    19% /boot                               2G root   disk     brw-rw----
└─sda2           LVM2_member LVM2 001                        fijQ10-F9oz-uWT8-EsNZ-fBOB-6eMW-jq1RBC                                                   38G root   disk     brw-rw----
  ├─ol_vbox-root xfs                                         2b43cd9e-9cb4-4731-8680-65018acef5d5      4.7G    53% /                                  10G root   disk     brw-rw----
  ├─ol_vbox-swap swap        1                               fbbb4a21-99cf-452f-8f47-35454dcdbbce                  [SWAP]                              8G root   disk     brw-rw----
  └─ol_vbox-home xfs                                         06ec5d4f-bc78-42d2-b355-f91b3af2a78e     19.8G     1% /home                              20G root   disk     brw-rw----
sdb                                                                                                                                                   20G root   disk     brw-rw----
└─sdb1           oracleasm                    DATA1                                                                                                   20G oracle oinstall brw-rw----
sdc                                                                                                                                                   20G root   disk     brw-rw----
└─sdc1           oracleasm                    DATA2                                                                                                   20G oracle oinstall brw-rw----
sdd                                                                                                                                                   20G root   disk     brw-rw----
└─sdd1           oracleasm                    FRA                                                                                                     20G oracle oinstall brw-rw----
sde                                                                                                                                                   40G root   disk     brw-rw----
sdf                                                                                                                                                   40G root   disk     brw-rw----
sr0              iso9660     Joliet Extension VBox_GAs_7.1.6 2025-01-21-13-18-27-98                       0   100% /run/media/oracle/VBox_GAs_7.1.6 57.4M root   cdrom    brw-rw----
[oracle@vbox ~]$ 

[root@vbox ~]# fdisk -lu /dev/sde
Disk /dev/sde: 40 GiB, 42949672960 bytes, 83886080 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

[root@vbox ~]# fdisk -lu /dev/sdf
Disk /dev/sdf: 40 GiB, 42949672960 bytes, 83886080 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

[root@vbox ~]# pvcreate /dev/sde
  Physical volume "/dev/sde" successfully created.
[root@vbox ~]# pvcreate /dev/sdf
  Physical volume "/dev/sdf" successfully created.
[root@vbox ~]# 

[root@vbox ~]# pvs
  PV         VG      Fmt  Attr PSize   PFree 
  /dev/sda2  ol_vbox lvm2 a--  <38.00g     0 
  /dev/sde           lvm2 ---   40.00g 40.00g
  /dev/sdf           lvm2 ---   40.00g 40.00g
[root@vbox ~]# 


[root@vbox ~]# vgcreate vg00 /dev/sde /dev/sdf
  Volume group "vg00" successfully created
[root@vbox ~]# 

[root@vbox ~]# vgdisplay
  --- Volume group ---
  VG Name               vg00
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               79.99 GiB
  PE Size               4.00 MiB
  Total PE              20478
  Alloc PE / Size       0 / 0   
  Free  PE / Size       20478 / 79.99 GiB
  VG UUID               6Waki9-penY-NcJp-0cMr-Asme-axqT-2cvQFO
   

[root@vbox ~]# pvdisplay 
  --- Physical volume ---
  PV Name               /dev/sde
  VG Name               vg00
  PV Size               40.00 GiB / not usable 4.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              10239
  Free PE               10239
  Allocated PE          0
  PV UUID               pOlnDm-v3LN-5XFY-rD1Z-OecG-qlfA-xsOUGW
   
  --- Physical volume ---
  PV Name               /dev/sdf
  VG Name               vg00
  PV Size               40.00 GiB / not usable 4.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              10239
  Free PE               10239
  Allocated PE          0
  PV UUID               KH0FH4-BTlW-plOg-y72r-6v4Q-rDdR-V2pDED

[root@vbox ~]# lvcreate -n oracle -l50%VG vg00
  Logical volume "oracle" created.

[root@vbox ~]# lvcreate -n grid -l100%VG vg00
  Reducing 100%VG to remaining free space <40.00 GiB in VG.
  Logical volume "grid" created.

[root@vbox ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vg00/oracle
  LV Name                oracle
  VG Name                vg00
  LV UUID                KYCTIJ-uO00-hSUd-TYQa-PgF6-cQyZ-HGPfgF
  LV Write Access        read/write
  LV Creation host, time vbox, 2025-02-17 09:14:39 +0100
  LV Status              available
  # open                 0
  LV Size                <40.00 GiB
  Current LE             10239
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           252:3
   
  --- Logical volume ---
  LV Path                /dev/vg00/grid
  LV Name                grid
  VG Name                vg00
  LV UUID                E8rgDI-4Ij3-n0G4-1J1i-ru5E-ZTq0-TBgWlw
  LV Write Access        read/write
  LV Creation host, time vbox, 2025-02-17 09:15:03 +0100
  LV Status              available
  # open                 0
  LV Size                <40.00 GiB
  Current LE             10239
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           252:4

[root@vbox ~]# lsblk -fm
NAME             FSTYPE      FSVER            LABEL          UUID                                   FSAVAIL FSUSE% MOUNTPOINTS                       SIZE OWNER  GROUP    MODE
sda                                                                                                                                                   40G root   disk     brw-rw----
├─sda1           xfs                                         9585d78f-9c65-490c-a651-cbfe3785b904      1.6G    19% /boot                               2G root   disk     brw-rw----
└─sda2           LVM2_member LVM2 001                        fijQ10-F9oz-uWT8-EsNZ-fBOB-6eMW-jq1RBC                                                   38G root   disk     brw-rw----
  ├─ol_vbox-root xfs                                         2b43cd9e-9cb4-4731-8680-65018acef5d5      4.7G    53% /                                  10G root   disk     brw-rw----
  ├─ol_vbox-swap swap        1                               fbbb4a21-99cf-452f-8f47-35454dcdbbce                  [SWAP]                              8G root   disk     brw-rw----
  └─ol_vbox-home xfs                                         06ec5d4f-bc78-42d2-b355-f91b3af2a78e     19.8G     1% /home                              20G root   disk     brw-rw----
sdb                                                                                                                                                   20G root   disk     brw-rw----
└─sdb1           oracleasm                    DATA1                                                                                                   20G oracle oinstall brw-rw----
sdc                                                                                                                                                   20G root   disk     brw-rw----
└─sdc1           oracleasm                    DATA2                                                                                                   20G oracle oinstall brw-rw----
sdd                                                                                                                                                   20G root   disk     brw-rw----
└─sdd1           oracleasm                    FRA                                                                                                     20G oracle oinstall brw-rw----
sde              LVM2_member LVM2 001                        pOlnDm-v3LN-5XFY-rD1Z-OecG-qlfA-xsOUGW                                                   40G root   disk     brw-rw----
└─vg00-oracle                                                                                                                                         40G root   disk     brw-rw----
sdf              LVM2_member LVM2 001                        KH0FH4-BTlW-plOg-y72r-6v4Q-rDdR-V2pDED                                                   40G root   disk     brw-rw----
└─vg00-grid                                                                                                                                           40G root   disk     brw-rw----
sr0              iso9660     Joliet Extension VBox_GAs_7.1.6 2025-01-21-13-18-27-98                       0   100% /run/media/oracle/VBox_GAs_7.1.6 57.4M root   cdrom    brw-rw----



[root@vbox ~]# mkfs.xfs /dev/vg00/oracle 
meta-data=/dev/vg00/oracle       isize=512    agcount=4, agsize=2621184 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=10484736, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@vbox ~]# mkfs.xfs /dev/vg00/grid 
meta-data=/dev/vg00/grid         isize=512    agcount=4, agsize=2621184 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=10484736, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@vbox ~]# 

[root@vbox ~]# mkdir /oracle /grid
[root@vbox ~]# mount /dev/vg00/oracle /oracle
[root@vbox ~]# mount /dev/vg00/grid /grid/
[root@vbox ~]# df -h 
Filesystem                Size  Used Avail Use% Mounted on
devtmpfs                  4.0M     0  4.0M   0% /dev
tmpfs                     5.5G     0  5.5G   0% /dev/shm
tmpfs                     2.2G  9.3M  2.2G   1% /run
/dev/mapper/ol_vbox-root   10G  5.3G  4.7G  53% /
/dev/sda1                 2.0G  384M  1.6G  20% /boot
/dev/mapper/ol_vbox-home   20G  183M   20G   1% /home
tmpfs                     1.1G  104K  1.1G   1% /run/user/54321
/dev/sr0                   58M   58M     0 100% /run/media/oracle/VBox_GAs_7.1.6
/dev/mapper/vg00-oracle    40G  318M   40G   1% /oracle
/dev/mapper/vg00-grid      40G  318M   40G   1% /grid
[root@vbox ~]# 

[root@vbox ~]# mount -l | grep -iE '/oracle|/grid' | grep -v media
/dev/mapper/vg00-oracle on /oracle type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)
/dev/mapper/vg00-grid on /grid type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)
[root@vbox ~]# 



[root@vbox ~]# vi /etc/fstab 
#
# /etc/fstab
# Created by anaconda on Fri Feb 14 13:39:47 2025
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/ol_vbox-root /                       xfs     defaults        0 0
UUID=9585d78f-9c65-490c-a651-cbfe3785b904 /boot                   xfs     defaults        0 0
/dev/mapper/ol_vbox-home /home                   xfs     defaults        0 0
/dev/mapper/ol_vbox-swap none                    swap    defaults        0 0
/dev/mapper/vg00-oracle /oracle                   xfs     defaults        0 0 # <-- new line
/dev/mapper/vg00-grid /grid                   xfs     defaults        0 0     # <-- new line

[root@vbox ~]# umount /oracle /grid 
[root@vbox ~]# mount -av
/                        : ignored
/boot                    : already mounted
/home                    : already mounted
none                     : ignored
mount: /oracle does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
/oracle                  : successfully mounted
mount: /grid does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/grid                    : successfully mounted

[root@vbox ~]# restorecon /oracle/
[root@vbox ~]# restorecon /grid/
[root@vbox ~]# umount /grid 
[root@vbox ~]# mount -av
/                        : ignored
/boot                    : already mounted
/home                    : already mounted
none                     : ignored
/oracle                  : already mounted
/grid                    : successfully mounted
[root@vbox ~]# 

[root@vbox ~]# df -h 
Filesystem                Size  Used Avail Use% Mounted on
devtmpfs                  4.0M     0  4.0M   0% /dev
tmpfs                     5.5G     0  5.5G   0% /dev/shm
tmpfs                     2.2G  9.3M  2.2G   1% /run
/dev/mapper/ol_vbox-root   10G  5.3G  4.7G  53% /
/dev/mapper/ol_vbox-home   20G  183M   20G   1% /home
/dev/sda1                 2.0G  384M  1.6G  20% /boot
/dev/mapper/vg00-oracle    40G  318M   40G   1% /oracle
tmpfs                     1.1G  104K  1.1G   1% /run/user/54321
/dev/sr0                   58M   58M     0 100% /run/media/oracle/VBox_GAs_7.1.6
/dev/mapper/vg00-grid      40G  318M   40G   1% /grid
[root@vbox ~]# 

