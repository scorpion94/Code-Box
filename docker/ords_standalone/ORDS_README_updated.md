
| *Document is written with OpenAI*
# 1. ORDS Standalone (Docker)

![Status](https://img.shields.io/badge/status-maintained-brightgreen)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Base](https://img.shields.io/badge/base-oraclelinux%208.10-lightgrey)
![Platform](https://img.shields.io/badge/platform-arm64v8-lightgrey)
![ORDS](https://img.shields.io/badge/ORDS-25.4-red)
![HTTP](https://img.shields.io/badge/http-8080-blue)
![HTTPS](https://img.shields.io/badge/https-8443-green)
![License](https://img.shields.io/badge/license-TBD-lightgrey)

A minimal Docker image that installs **Oracle REST Data Services (ORDS)** and runs it in **standalone mode**.

ORDS is configured against an **existing Oracle Database** (reachable over TCP). Connection settings are provided via environment variables.

---

## 2. Table of Contents

- Architecture
- What's Included
- Prerequisites
- Configuration
- Local HTTPS Setup (mkcert)
- How-To
- Notes & Troubleshooting

---

# 3. Architecture

The container runs **Oracle REST Data Services (ORDS)** in standalone mode using the embedded Jetty web server.

Depending on whether SSL certificates are present, ORDS runs either in **HTTP** or **HTTPS** mode.

### Architecture Diagram

```
                +----------------------
                |      Web Browser     
                +----------+-----------
                           |
             HTTP :8080    |    HTTPS :8443
                           |
                           v
                 +---------------------
                 |    ORDS Container   
                 |  Standalone (Jetty) 
                 +----------+----------
                            |
                            |  JDBC / TCP :1521
                            |
                            v
                 +---------------------
                 |   Oracle Database   
                 |   Listener :1521    
                 +---------------------
```

### Port Overview

| Component | Port | Description |
|----------|------|-------------|
Browser → ORDS | 8080 | HTTP endpoint |
Browser → ORDS | 8443 | HTTPS endpoint |
ORDS → Database | 1521 | Oracle listener |

---

# 4. What's Included

- `Dockerfile` – builds the ORDS standalone image
- `setup_ords.sh` – configures ORDS (build phase)
- `startup_ords.sh` – runtime startup script
- `password.txt` – must be provided locally
- optional `certs/` directory for SSL certificates

---

# 5. Prerequisites

- Docker
- reachable Oracle Database
- network connectivity to DB host
- mkcert

---

# 6. Configuration

### Required environment variables

- `DB_HOST`
- `DB_PORT`
- `DB_SERVICENAME`

### Optional environment variables

- `ORDS_PATH` (default `/u01/ords`)
- `ORDS_CONFIG` (default `/u01/config_ords`)
- `ORDS_LOGPATH` (default `/u01/logs_ords`)
- `ORDS_HTTP_PORT` (default `8080`)
- `ORDS_HTTPS_PORT` (default `8443`)
- `ORDS_CERT` (default `ords.local.pem`)
- `ORDS_CERT_KEY` (default `ords.local-key.pem`)

If certificates exist in `/certs`, ORDS automatically switches to HTTPS mode and disables HTTP.

---

# 7. Local HTTPS Setup with mkcert

### Install mkcert

macOS:

```
brew install mkcert
mkcert -install
```

### Generate certificate

Add hostname locally:

```
sudo nano /etc/hosts
```

Add:

```
127.0.0.1 ords.local
```

```
mkcert ords.local
```

Files created:

```
ords.local.pem
ords.local-key.pem
```

Move them into a certs folder:

```
mkdir certs
mv ords.local*.pem certs/
```


---

# 8. How-To

## Build

```
docker build -t ords_standalone:25.4 .
```

## Run (HTTP)

```
docker run --rm  -p 8080:8080  -e DB_HOST=192.168.56.10  -e DB_PORT=1521  -e DB_SERVICENAME=ORCL  ords_standalone:25.4
```

## Run (HTTPS)

```
docker run --rm  -p 8443:8443  -v $(pwd)/certs:/certs:ro  -e DB_HOST=192.168.56.10  -e DB_PORT=1521  -e DB_SERVICENAME=ORCL  ords_standalone:25.4
```

Access:

HTTP

```
http://localhost:8080/ords
```

HTTPS

```
https://ords.local:8443/ords
```

---

# 9. Notes & Troubleshooting

Both setup and startup scripts perform a TCP reachability test against the database.

If the container exits early:

- verify database listener
- verify firewall / routing
- verify environment variables

To inspect runtime configuration:

```
ords --config /u01/config_ords config list
```
