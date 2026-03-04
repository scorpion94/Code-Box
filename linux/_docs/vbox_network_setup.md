# VirtualBox VM Network Setup

![VirtualBox](https://img.shields.io/badge/VirtualBox-7.x-blue)
![Linux](https://img.shields.io/badge/Linux-Tested-success)
![Network](https://img.shields.io/badge/Network-NAT%20%2B%20HostOnly-orange)
![Status](https://img.shields.io/badge/Status-Stable-green)

Configure a **VirtualBox VM network setup** with:

-   NAT (Internet access)
-   Host-Only Network (host ↔ VM communication)

This setup is commonly used for:

-   database labs
-   multi-VM clusters
-   development environments
-   homelabs

------------------------------------------------------------------------

## 1. Architecture

The VM uses two network interfaces:

| Interface | Network Type | Purpose |
|---|---|---|
| enp0s8 | NAT | Internet access + SSH port forwarding |
| enp0s9 | Host-Only | Host ↔ VM communication |

### Network Layout

```
                     Internet
                         │
                         │
                      (NAT)
                         │
              ┌────────────────────┐
              │     VirtualBox     │
              │   NAT Engine       │
              └────────────────────┘
                         │
            Port Forwarding Rule
            Host:5555 → VM:22
                         │
                    enp0s8
                   10.0.2.15
                         │
                ┌────────────────┐
                │      VM        │
                │   Linux Host   │
                └────────────────┘
                         │
                    enp0s9
                         │
               Host-Only Network
               192.168.56.0 /24
                         │
                    Host OS
```

---

### SSH Access via NAT

Because of the NAT port forwarding rule you can access the VM via SSH:

```
ssh user@localhost -p 5555
```

---

### Port Forwarding Rule

The NAT rule can be configured with VBoxManage:

<details>
<summary>Command</summary>

```bash
VBoxManage modifyvm "<vm-name>" \
  --nat-pf1 "ssh-forward,tcp,,5555,,22"
```

</details>


Explanation:

| Parameter | Meaning |
|---|---|
| ssh-forward | rule name |
| tcp | protocol |
| 5555 | host port |
| 22 | VM port |

---

### Result

You now have **two ways to reach the VM**:

| Method | Command |
|---|---|
| NAT SSH | `ssh user@localhost -p 5555` |
| Host-Only SSH | `ssh user@192.168.56.21` |
------------------------------------------------------------------------

## Table of Contents

- [1. Architecture](#1-architecture)
- [2. Requirements](#2-requirements)
- [3. Verify Host-Only Network](#3-verify-host-only-network)
- [4. Attach Network Adapter](#4-attach-network-adapter)
  - [4.1 Start the Virtual Machine](#41-start-the-virtual-machine)
- [5. Verify Network Devices](#5-verify-network-devices)
- [6. Check IP Configuration](#6-check-ip-configuration)
- [7. Configure Static IP](#7-configure-static-ip)
- [8. Verify Configuration](#8-verify-configuration)
- [9. Troubleshooting](#9-troubleshooting)
  - [9.1 Interface still disconnected](#91-interface-still-disconnected)
  - [9.2 Check routing](#92-check-routing)
  - [9.3 Test connectivity](#93-test-connectivity)
- [10. Result](#10-result)
- [11. License](#11-license)

------------------------------------------------------------------------

## 2. Requirements

-   VirtualBox ≥ 7
-   Linux VM
-   NetworkManager (`nmcli`)
-   Host-Only Network configured

------------------------------------------------------------------------

## 3. Verify Host-Only Network

``` bash
VBoxManage list hostonlynets
```

Expected output:
    Name:            HostNetwork
    GUID:            331df2f8-cac1-4c80-93f6-367eaa31454d

    State:           Enabled
    NetworkMask:     255.255.255.0
    LowerIP:         192.168.56.1
    UpperIP:         192.168.56.199
    VBoxNetworkName: hostonly-HostNetwork

------------------------------------------------------------------------

## 4. Attach Network Adapter

Attach the Host-Only network to your VM.

``` bash
# Use Name from hostonlynets
VBoxManage modifyvm "<vm-name>" \
  --nic2 hostonlynet \
  --host-only-net2 "<Name>"
```

------------------------------------------------------------------------

### 4.1 Start the Virtual Machine

``` bash
VBoxManage startvm "<vm-name>" --type headless
```

------------------------------------------------------------------------

## 5. Verify Network Devices

``` bash
nmcli device status
```

Example:

    DEVICE  TYPE      STATE         CONNECTION
    enp0s8  ethernet  connected     enp0s8
    enp0s9  ethernet  disconnected  --

  Interface   Purpose
  ----------- -------------------
  enp0s8      NAT network
  enp0s9      Host-Only network

------------------------------------------------------------------------

## 6. Check IP Configuration

``` bash
ip a
ip r
```

Expected:

    default via 10.0.2.2 dev enp0s8
    10.0.2.0/24 dev enp0s8

------------------------------------------------------------------------

## 7. Configure Static IP

``` bash
nmcli connection add \
  type ethernet \
  ifname enp0s9 \
  con-name hostonly \
  ipv4.method manual \
  ipv4.addresses 192.168.56.21/24
```

------------------------------------------------------------------------

## 8. Verify Configuration

``` bash
nmcli device status
ip a
ip r
```

Expected:

    enp0s9 ethernet connected hostonly

    192.168.56.21/24 dev enp0s9

    192.168.56.0/24 dev enp0s9

------------------------------------------------------------------------

## 9. Troubleshooting

### 9.1 Interface still disconnected

``` bash
nmcli connection up hostonly
```

### 9.2 Check routing

``` bash
ip route
```

Expected:

    default via 10.0.2.2 dev enp0s8
    192.168.56.0/24 dev enp0s9

### 9.3 Test connectivity

From host:

``` bash
ping 192.168.56.21
```

SSH:

``` bash
ssh user@192.168.56.21
```

------------------------------------------------------------------------

## 10. Result

Your VM should now have:

  Interface   Purpose     Example IP
  ----------- ----------- ---------------
  enp0s8      NAT         10.0.2.15
  enp0s9      Host-Only   192.168.56.21

------------------------------------------------------------------------

## 11. License

MIT License
