# Add new VDI in VBOx

[root@vbox ~]# pvcreate /dev/sdg
  Physical volume "/dev/sdg" successfully created.

[root@vbox ~]# vgextend ol_vbox /dev/sdg 
  Volume group "ol_vbox" successfully extended

[root@vbox ~]# pvdisplay
 --- Volume group ---
  VG Name               ol_vbox
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               3
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               57.99 GiB
  PE Size               4.00 MiB
  Total PE              14846
  Alloc PE / Size       12287 / <48.00 GiB
  Free  PE / Size       2559 / <10.00 GiB
  VG UUID               UHEQhK-JkBQ-UMzg-9n51-StNb-dYxN-3G0eWb

 --- Volume group ---
  VG Name               ol_vbox
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               3
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               57.99 GiB
  PE Size               4.00 MiB
  Total PE              14846
  Alloc PE / Size       12287 / <48.00 GiB
  Free  PE / Size       2559 / <10.00 GiB
  VG UUID               UHEQhK-JkBQ-UMzg-9n51-StNb-dYxN-3G0eWb

[root@vbox ~]# lvextend -L +10G /dev/ol_vbox/swap 
  Size of logical volume ol_vbox/swap changed from 8.00 GiB (2048 extents) to 18.00 GiB (4608 extents).
  Logical volume ol_vbox/swap successfully resized.
