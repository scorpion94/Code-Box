| *Document is generated with OpenAI (ChatGpt)*
# 1. ORDS Standalone (Docker)

![Status](https://img.shields.io/badge/status-maintained-brightgreen)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Base](https://img.shields.io/badge/base-oraclelinux%208.10-lightgrey)
![Platform](https://img.shields.io/badge/platform-arm64v8-lightgrey)
![ORDS](https://img.shields.io/badge/ORDS-25.4-red)
![HTTP](https://img.shields.io/badge/http-8080-blue)
![HTTPS](https://img.shields.io/badge/https-8443-green)
![License](https://img.shields.io/badge/license-TBD-lightgrey)

A minimal Docker image that installs **Oracle REST Data Services (ORDS)** and runs it in **standalone mode (Jetty)**.

ORDS is configured against an **existing Oracle Database** (reachable over TCP). Connection settings are provided via environment variables (recommended via `--env-file`).

---

## 2. Table of Contents

- [3. Architecture](#3-architecture)
- [4. What’s Included](#4-whats-included)
- [5. Prerequisites](#5-prerequisites)
- [6. Configuration](#6-configuration)
- [7. Local HTTPS Setup (mkcert)](#7-local-https-setup-mkcert)
- [8. How-To](#8-how-to)
- [9. Notes & Troubleshooting](#9-notes--troubleshooting)

---

# 3. Architecture

The container runs **ORDS in standalone mode** using the embedded Jetty server.

- ORDS always *starts* with an HTTP port configured (`ORDS_HTTP_PORT`, default `8080`).
- If SSL certificates are found, the startup switches to **HTTPS** and disables **HTTP** by setting the HTTP port to `0`.

### Architecture Diagram

```
                +----------------------
                |      Web Browser     |
                +----------+-----------+
                           |
             HTTP :8080    |    HTTPS :8443
                           |
                           v
                 +---------------------+
                 |    ORDS Container   |
                 |  Standalone (Jetty) |
                 +----------+----------+
                            |
                            |  JDBC / TCP :1521
                            |
                            v
                 +---------------------+
                 |   Oracle Database   |
                 |   Listener :1521    |
                 +---------------------+
```

### Port Overview

| Component | Port | Description |
|----------|------|-------------|
| Browser → ORDS | 8080 | HTTP endpoint (disabled when SSL is active) |
| Browser → ORDS | 8443 | HTTPS endpoint |
| ORDS → Database | 1521 | Oracle listener (example) |

---

# 4. What's Included

- `Dockerfile` – builds the ORDS standalone image (Oracle Linux 8.10, Java 17, Python 3.9)
- `startup_ords.sh` – runtime entrypoint (connectivity check, one-time ORDS install/config, optional SSL switch)
- `setup_ords.sh` – performs `ords install` and sets ORDS standalone config values
- `ords_ssl_setup.sh` – switches standalone mode to HTTPS and disables HTTP (when certs exist)
- `check_database_connect.py` – validates DB connectivity using `python-oracledb` as `SYSDBA`

---

# 5. Prerequisites

- Docker
- A reachable Oracle Database listener (`DB_HOST:DB_PORT`)
- A password file on the host that contains the SYS password in the **first line**
- (Optional) `mkcert` for local trusted HTTPS certificates

---

# 6. Configuration

## Required environment variables

- `DB_HOST`
- `DB_PORT`
- `DB_SERVICENAME`
- `PWFILE` → **path inside the container** to the password file (example: `/u01/passwords/password.txt`)

## Optional environment variables (defaults)

- `ORDS_PATH` (`/u01/ords`)
- `ORDS_CONFIG` (`/u01/config_ords`)
- `ORDS_LOGPATH` (`/u01/logs_ords`)
- `ORDS_HTTP_PORT` (`8080`)
- `ORDS_HTTPS_PORT` (`8443`)
- `ORDS_CERT_PATH` (`/u01/certs`)
- `ORDS_CERT` (`ords.local.pem`)
- `ORDS_CERT_KEY` (`ords.local-key.pem`)

## Example `.env.example`

<details>
<summary>Show example env-file</summary>

```dotenv
# Oracle DB connection
DB_HOST=192.168.56.10
DB_PORT=1521
DB_SERVICENAME=ORCL

# Password file (inside container)
PWFILE=/u01/passwords/password.txt

# ORDS runtime
ORDS_HTTP_PORT=8080
ORDS_HTTPS_PORT=8443

# SSL (inside container)
ORDS_CERT_PATH=/u01/certs
ORDS_CERT=ords.local.pem
ORDS_CERT_KEY=ords.local-key.pem

# Optional: override paths
# ORDS_CONFIG=/u01/config_ords
# ORDS_LOGPATH=/u01/logs_ords
```

</details>

---

# 7. Local HTTPS Setup (mkcert)

## 7.1 Install mkcert

<details>
<summary>macOS</summary>

```bash
brew install mkcert
mkcert -install
```

</details>

## 7.2 Create a local cert

This example uses the hostname `ords.local`.

<details>
<summary>1) Add hostname to /etc/hosts</summary>

```bash
sudo sh -c 'echo "127.0.0.1 ords.local" >> /etc/hosts'
```

</details>

<details>
<summary>2) Generate cert + key</summary>

```bash
mkcert ords.local
```

This generates:

- `ords.local.pem`
- `ords.local-key.pem`

</details>

<details>
<summary>3) Put certs into a folder that you mount into the container</summary>

```bash
mkdir -p certs
mv ords.local*.pem certs/
```

</details>

---

# 8. How-To

## 8.1 Build

<details>
<summary>Build image</summary>

```bash
docker build -t ords_standalone:25.4 .
```

</details>

## 8.2 Run (your current way: env-file + volumes)

**Important:** In most shells, `~` does **not** expand inside quotes.

So prefer either:

- `-v "$HOME/certs:/u01/certs:ro"` (portable)
- or unquoted `-v ~/certs:/u01/certs:ro`

<details>
<summary>Run with HTTP+HTTPS ports, certs, password file, env-file</summary>

```bash
docker run --rm \
  -p 8443:8443 \
  -p 8080:8080 \
  -v "$HOME/certs:/u01/certs:ro" \
  -v "$HOME/password.txt:/u01/passwords/password.txt:ro" \
  --env-file .env.example \
  ords_standalone:25.4
```

</details>

### URLs

- HTTP (only if no certs are found):
  - `http://localhost:8080/ords`
- HTTPS (when certs are found):
  - `https://ords.local:8443/ords`

## 8.3 Optional: persist ORDS config across restarts

Because you use `--rm`, without an extra volume mount the ORDS config is recreated on every start.

<details>
<summary>Persist /u01/config_ords and /u01/logs_ords</summary>

```bash
docker run --rm \
  -p 8443:8443 \
  -p 8080:8080 \
  -v "$HOME/certs:/u01/certs:ro" \
  -v "$HOME/password.txt:/u01/passwords/password.txt:ro" \
  -v "ords_config:/u01/config_ords" \
  -v "ords_logs:/u01/logs_ords" \
  --env-file .env.example \
  ords_standalone:25.4
```

</details>

---

# 9. Notes & Troubleshooting

## 9.1 “Missing PWFILE”

Startup checks if `${PWFILE}` is readable inside the container. Common causes:

- you didn’t mount the file to the path you configured in `PWFILE`
- `PWFILE` has quotes in `.env.example` (e.g. `PWFILE="/u01/..."`) → remove the quotes

## 9.2 DB connectivity check fails

The container runs a quick Python connect test (`python-oracledb`) using:

- `DB_HOST`, `DB_PORT`, `DB_SERVICENAME`
- `SYS` + password from the first line of `PWFILE`

If that fails:

- verify listener reachability from your Docker host
- verify the service name and password

## 9.3 Inspect ORDS runtime configuration

<details>
<summary>Show ORDS config</summary>

```bash
ords --config /u01/config_ords config list
```

</details>
