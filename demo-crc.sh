#!/bin/bash

# Enable / Disable Telemetry to Red Hat
crc config set consent-telemetry no

# Enable / Disable Cluster Monitoring 
# Enable only if you have enough memory, needs ~4G extra
crc config set enable-cluster-monitoring false

# Set CRC CPU's
crc config set cpus 16

# Set CRC Memory
crc config set memory 24576

# Set Disk Size, Thin Provisioned
crc config set disk-size 250

# Set Pull secret
#crc config set pull-secret-file ~/.crc/pull-secret.txt

# Show config
crc config view

# Set up CRC if needed
crc setup

# Start CRC
crc start

# Attach secondary disk for persistant storage - Thin provisioned
# Create Disk
sudo -S qemu-img create -f raw ~/.crc/vdb 100G
# Attach Disk
sudo virsh attach-disk crc ~/.crc/vdb vdb --cache none

# Command to SSH to VM If needed
export alias crcssh='ssh -p 22 -i ~/.crc/machines/crc/id_ecdsa core@"$(crc ip)"'

# SSH Into CRC and Show uptime
crcssh uptime