| *Document is generated with OpenAI (ChatGpt)*

![Status](https://img.shields.io/badge/status-maintained-brightgreen)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Base](https://img.shields.io/badge/base-oraclelinux%208.10-lightgrey)
![Platform](https://img.shields.io/badge/platform-arm64v8-lightgrey)
![Oracle](https://img.shields.io/badge/database-Oracle%20Free-red)
![APEX](https://img.shields.io/badge/APEX-24.2-blue)
![License](https://img.shields.io/badge/license-TBD-lightgrey)

# Oracle Database + APEX Docker Image

This repository provides a **Docker image for Oracle Database Free
including Oracle APEX**.

The container automatically installs and configures **Oracle APEX**
during startup and keeps database data persistent using **Docker
volumes**.

------------------------------------------------------------------------

# Table of Contents

1.  [General Information](#1-general-information)
2.  [Architecture](#2-architecture)
3.  [Image Details](#3-image-details)
4.  [Build the Image](#4-build-the-image)
5.  [Run the Container](#5-run-the-container)
6.  [Environment Variables](#6-environment-variables)
7.  [Persistence](#7-persistence)

------------------------------------------------------------------------

# 1. General Information

Important behaviour of the container:

-   All scripts that should run automatically during container startup
    **must be placed in**

```
    /opt/oracle/scripts/startup
```
-   Oracle creates the database **during container startup
    (`docker run`)**
-   The environment variable **`ORACLE_PWD`** is used to set the
    password for:

```
    SYS
    SYSTEM
    PDBADMIN
```
------------------------------------------------------------------------

# 2. Architecture

                     +------------------------+
                     |      Docker Host       |
                     +------------------------+
                               |
                               | 1521
                               v
                    +-------------------------+
                    |   Oracle DB Container   |
                    |                         |
                    |  Oracle Database Free   |
                    |          +              |
                    |          | APEX         |
                    |          +              |
                    |                         |
                    |  /opt/oracle/oradata   |
                    |  /opt/oracle/apex_242  |
                    +-------------------------+
                               |
                               v
                        Docker Volumes
                      ------------------
                      oracledb-data
                      oracledb-apex

Ports:

  Port   Purpose
  ------ ---------------
  1521   Oracle SQLNet

------------------------------------------------------------------------

# 3. Image Details

Base image used:

Oracle Database Free container image

https://container-registry.oracle.com/ords/f?p=113:4:105830967166034:::4:P4_REPOSITORY,AI_REPOSITORY,AI_REPOSITORY_NAME,P4_REPOSITORY_NAME,P4_EULA_ID,P4_BUSINESS_AREA_ID:1863,1863,Oracle%20Database%20Free,Oracle%20Database%20Free,1,0

### APEX Static Resources

The variable `APEX_IMAGE_PATH` uses the **Oracle CDN** for static
resources.

Reference:

https://blogs.oracle.com/apex/announcing-oracle-apex-static-resources-on-content-delivery-network

------------------------------------------------------------------------

# 4. Build the Image
<details>
<summary>Docker build command</summary>

``` bash
docker build -t oracledb .
```
</details>


------------------------------------------------------------------------

# 5. Run the Container

## Volumes

Two Docker volumes are used:

  -----------------------------------------------------------------------
  Volume                              Purpose
  ----------------------------------- -----------------------------------
  `oracledb-data`                     Stores Oracle database files
                                      (datafiles, redo logs etc.)

  `oracledb-apex`                     Stores APEX installation and static
                                      resources
  -----------------------------------------------------------------------

This ensures that **data survives container recreation**.

------------------------------------------------------------------------

## APEX Installation Flag

After a successful APEX installation a flag file is created:

    ${APEX_PATH}/.apex_installed

This prevents the APEX installation from running again.

------------------------------------------------------------------------

## Start Container

``` bash
docker run -d \
-p 1521:1521 \
-v oracledb-data:/opt/oracle/oradata \
-v oracledb-apex:/opt/oracle/apex_242 \
-e ORACLE_PWD=MySecretPassword \
--env-file .env.oradb \
oracledb
```
------------------------------------------------------------------------

# 6. Environment Variables

The container expects the following variable `ORACLE_PWD`.

Example:

    ORACLE_PWD=MySecretPassword

This password is used for:

-   SYS
-   SYSTEM
-   PDBADMIN

------------------------------------------------------------------------

# 7. Persistence

The following data will persist across container restarts:

-   Oracle Database files
-   APEX installation
-   APEX static resources

This allows the container to be safely recreated without data loss.
