#!/bin/bash
# Desc: Set hostname on Linux

hostname="vm-ol8-01"
sudo hostnamectl set-hostname "${hostname}"

# check with
hostnamectl