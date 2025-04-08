./gridSetup.sh -silent \
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
oracle.install.asm.diskGroup.disksWithFailureGroupNames=/dev/sdb1,,/dev/sdc1 \
oracle.install.asm.diskGroup.disks=/dev/sdb1,/dev/sdc1 \
oracle.install.asm.diskGroup.diskDiscoveryString=/dev/sd* \
oracle.install.crs.rootconfig.executeRootScript=false
