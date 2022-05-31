#!/bin/bash

setCRCConfigs (){
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
}

createCRCPersistantStorage(){
    # Attach secondary disk for persistant storage - Thin provisioned
    # Create Disk
    qemu-img create -f raw ~/.crc/vdb 100G
    # Attach Disk
    sudo virsh attach-disk crc ~/.crc/vdb vdb --cache none
}

crcLogin(){
    # Loging to CRC
    echo "Logging in..."
    $(crc console --credentials | awk -F"'" '$0=$2' | grep kubeadmin)
}

setupArgoCDPermissions(){
    # Give ARGOCD cluster admin to CRC for demo purposes
    oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
}

crcStart(){
    crc start
}

crcStop(){
    crc stop
}

crcClean(){
    crc stop
    crc delete
    #rm ~/.crc/vdb
    #rm ~/.crc/crc.log*
    #rm ~/.crc/machines/crc/* 
}

startupOptions(){
    echo "No startup options specified. Valid options:"
    echo "============================================"
    echo "* Set Up demo CRC: $0 setup"
    echo "* Start CRC: $0 start"
    echo "* Stop CRC: $0 stop"
    echo "* Log into CRC with kubeadmin: $0 stop"
    echo "* Clean up CRC Environment: $0 clean"
    echo -e "\n"
    exit 1
}

setupCRC(){

    # Set CRC Configs
    setCRCConfigs

    # Create & Attach Storage
    createCRCPersistantStorage

    # Start CRC
    crc start

    # Command to SSH to VM If needed
    alias crcssh='ssh -p 22 -i ~/.crc/machines/crc/id_ecdsa core@"$(crc ip)"'

    # SSH Into CRC and Show uptime
    crcssh uptime

    # Log Into CRC
    crcLogin

}

# Startup
case "${1}" in
    setup)      setupCRC ;;
    start)      crcStop ;;
    stop)       crcStop ;;
    login)      crcLogin ;;
    clean)      crcClean ;;
    "")         startupOptions ;;
    *)          startupOptions ;;
esac