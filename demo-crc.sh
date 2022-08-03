#!/bin/bash

crcStart(){
    # Start and Setup
    ansible-playbook -i hosts/hosts playbooks/host-setup.yml
    ansible-playbook -i hosts/hosts playbooks/crc-setup.yml
}

crcStop(){
    crc stop
}

crcClean(){
     ansible-playbook -i hosts/hosts playbooks/crc-clean.yml
}

startupOptions(){
    echo "No startup options specified. Valid options:"
    echo "============================================"
    echo "* Start CRC: $0 start"
    echo "* Stop CRC: $0 stop"
    echo "* Clean up CRC Environment: $0 clean"
    echo -e "\n"
    exit 1
}


crcCreds(){
    # Get CRC Credsss
    ansible localhost -m include_role -a name=crc-credentials

    # Get GitOps / ArgoCD Creds
    ansible localhost -m include_role -a name=argocd-get-login
}

# Include ansible libraries we wrote
#export ANSIBLE_LIBRARY=./library

# Startup
case "${1}" in
    start)      crcStart ;;
    stop)       crcStop ;;
    clean)      crcClean ;;
    creds)      crcCreds ;;
    "")         startupOptions ;;
    *)          startupOptions ;;
esac