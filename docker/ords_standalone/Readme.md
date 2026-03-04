| *This file is generated with OpenAI*
# 1. ORDS Standalone (Docker)

![Status](https://img.shields.io/badge/status-maintained-brightgreen)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Base](https://img.shields.io/badge/base-oraclelinux%208.10-lightgrey)
![Platform](https://img.shields.io/badge/platform-arm64v8-lightgrey)
![ORDS](https://img.shields.io/badge/ORDS-25.4-red)
![HTTP](https://img.shields.io/badge/http-8080-blue)
![License](https://img.shields.io/badge/license-TBD-lightgrey)

A minimal Docker image that installs **Oracle REST Data Services (ORDS)** and runs it in **standalone mode**.

ORDS is configured against an **existing Oracle Database** (reachable over TCP). Connection settings are provided via environment variables.

---

## 2. Table of Contents

- [1. ORDS Standalone (Docker)](#1-ords-standalone-docker)
- [2. Table of Contents](#2-table-of-contents)
- [3. What&#39;s Included](#3-whats-included)
- [4. Prerequisites](#4-prerequisites)
- [5. Configuration](#5-configuration)
  - [5.1 Required environment variables](#51-required-environment-variables)
  - [5.2 Optional environment variables](#52-optional-environment-variables)
  - [5.3 The `password.txt` file (required)](#53-the-passwordtxt-file-required)
- [6. How-To](#6-how-to)
  - [6.1 Build](#61-build)
  - [6.2 Run](#62-run)
  - [6.3 Test](#63-test)
- [7. Notes & Troubleshooting](#7-notes--troubleshooting)

---

## 3. What's Included

- `Dockerfile` – builds the ORDS standalone image (Oracle Linux 8.10, arm64)
- `setup_ords.sh` – configures ORDS (non-interactive)
- `startup_ords.sh` – starts ORDS (`ords serve`)
- `password.txt` – **must be provided by you** (should be in `.gitignore`)

---

## 4. Prerequisites

- Docker (or compatible container runtime)
- A reachable Oracle Database endpoint (host/IP + port + service name)
- Network access from the container to the database host

---

## 5. Configuration

### 5.1 Required environment variables

You **must** pass these variables when running the container:

- `DB_HOST` – database host/IP
- `DB_PORT` – database listener port (e.g. `1521`)
- `DB_SERVICENAME` – database service name (e.g. `ORCL`)

### 5.2 Optional environment variables

The scripts also support the following (defaults shown):

- `ORDS_PATH` (default: `/u01/ords`)
- `ORDS_CONFIG` (default: `/u01/config_ords`)
- `ORDS_LOGPATH` (default: `/u01/logs_ords`)
- `ORDS_PORT` (default: `8080`) *(used during setup for `standalone.http.port`)*
- `APEX_PATH` (default: `/u01/apex_242/`) *(currently not used for static images; CDN intended)*
- `ORDS_CONFIG` and `ORDS_PATH` are also used at runtime by `startup_ords.sh`.

### 5.3 The `password.txt` file (required)

`password.txt` is **not** meant to be stored in Git.

- In your GitHub repo it should be listed in `.gitignore`

**You must create your own `password.txt` locally before building the image.**

---

## 6. How-To

### 6.1 Build

<details>
<summary>Show build command</summary>

```bash
# Build the image in the current directory
docker build -t ords:25.4 .
```
</details>

---

### 6.2 Run

<details>
<summary>Show docker run command</summary>

```bash
docker run --rm -p 8080:8080 -e DB_HOST="192.168.56.10" -e DB_PORT="1521" -e DB_SERVICENAME="ORCL" ords:25.4
```
</details>

---

### 6.3 Test

Once the container is running:

- `http://localhost:8080/ords`

<details>
<summary>Show test via curl</summary>

```bash
curl -i http://localhost:8080/ords/
```
</details>

---

## 7. Notes & Troubleshooting

- Both setup and startup scripts perform a TCP reachability check to the database (`/dev/tcp/DB_HOST/DB_PORT`).
- If the container exits with “Port closed”, verify:
  - the DB listener is running and reachable
  - routing/firewall rules allow access
  - `DB_HOST`, `DB_PORT`, `DB_SERVICENAME` are correct

---
