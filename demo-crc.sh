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
    crc config set memory 20480

    # Set Disk Size, Thin Provisioned
    crc config set disk-size 250

    # Set Pull secret
    #crc config set pull-secret-file ~/.crc/pull-secret.txt

    # Show config
    crc config view

    # Set up CRC if needed
    crc setup

}

verifyGitOpsOperator(){

    echo "Verify GitOps Operator is running"
    

    while [ $(oc get po -n openshift-operators | grep gitops-operator-controller-manager | grep "1/1" | wc -l) -ne 1 ]; do 
        echo "Waiting for Openshift GitOps Operator to be ready in openshift-gitops namespace";

        sleep 5
    done

    echo -e "Waiting for GitOps Deployments to be available"
    while [ $(oc get deployments -n openshift-gitops --no-headers | wc -l) -lt 7 ]; do
        echo -e "."
        sleep 5
    done
    
    echo "Verify Gitops is running"
    while [ $(oc get deployments -n openshift-gitops --no-headers | grep -v "1/1"  | wc -l) -ne 0 ]; do 
        echo "Waiting for Openshift GitOps containers to be ready in openshift-gitops namespace";

        oc get deployments -n openshift-gitops --no-headers | grep -v "1/1"

        sleep 5
    done

    # Completed GitOps install
    echo "GitOps install Completed"
}

argocdPod(){
    echo $(oc get po | grep ^openshift-gitops-server | awk '{ print $1 }')
}

argocdSyncServiceMesh(){

    # Ensure the ServiceMeshControlPlane CR exists
    while [ $(oc get CustomResourceDefinition | grep -i ServiceMeshControlPlanes | wc -l) -ne 1 ]; do         
        echo "Waiting for the Service Mesh Control Plane CR API to become available";

        sleep 5
    done

    # Switch to argocd project
    oc project openshift-gitops

    # Get the ArgoCD pod
    arcgocdPod=$(argocdPod)

    # Log into ArgoCD Server
    oc rsh -c argocd-server $arcgocdPod argocd login openshift-gitops-server:443 --username=admin --password=$(argocdPassword) --insecure --config /tmp/.config/argocd/config

    # Start the ArgoCD Sync
    oc rsh -c argocd-server $arcgocdPod argocd --config /tmp/.config/argocd/config app sync 1-istio-controlplane

    # Wait for the Service Mesh to become Ready
    while [ $(oc get ServiceMeshControlPlane -n istio-system --no-headers | grep ComponentsReady | wc -l) -ne 1 ]; do
        echo -e "\n\nWaiting for service mesh to become ready:\n"

        oc get ServiceMeshControlPlane -n istio-system --no-headers

        sleep 5
        
    done

    # Create Wildcard certificate for Istio
    createSSLCerts

}

argocdSyncKnative(){

    # Switch to argocd project
    oc project openshift-gitops

    # Log into ArgoCD Server
    oc rsh -c argocd-server $arcgocdPod argocd login openshift-gitops-server:443 --username=admin --password=$(argocdPassword) --insecure --config /tmp/.config/argocd/config

    # Start the ArgoCD Sync
    oc rsh -c argocd-server $arcgocdPod argocd --config /tmp/.config/argocd/config app sync 1-knative

    # Wait for the Service Mesh to become Ready
    while [ $(oc get KnativeServing/knative-serving -n knative-serving --no-headers | grep True | wc -l) -ne 1 ]; do
        echo -e "\n\nWaiting for Knative to become ready:\n"

        oc get KnativeServing/knative-serving -n knative-serving --no-headers

        sleep 5
        
    done

}

argocdSyncTekton(){

    # Switch to argocd project
    oc project openshift-gitops

    # Get the ArgoCD pod
    arcgocdPod=$(argocdPod)

    # Log into ArgoCD Server
    oc rsh -c argocd-server $arcgocdPod argocd login openshift-gitops-server:443 --username=admin --password=$(argocdPassword) --insecure --config /tmp/.config/argocd/config

    # Start the ArgoCD Sync
    oc rsh -c argocd-server $arcgocdPod argocd --config /tmp/.config/argocd/config app sync 2-demo-quarkus-superheroes-tekton
}

getArgoCDDefaultSyncStatus(){

    # Switch to argocd project
    oc project openshift-gitops

    # Get the ArgoCD pod
    arcgocdPod=$(argocdPod)

    # Log into ArgoCD Server
    oc rsh -c argocd-server $arcgocdPod argocd login openshift-gitops-server:443 --username=admin --password=$(argocdPassword) --insecure --config /tmp/.config/argocd/config

    while [ $(oc rsh -c argocd-server $arcgocdPod argocd app list --config /tmp/.config/argocd/config | grep default | egrep -v "^[0-9].*" | egrep -v "Synced.*Healthy" | wc -l) -ne 0 ]; do
        # Get App List and get status

        echo -e "Waiting for the following apps to sync:\n"
        echo $(oc rsh -c argocd-server $arcgocdPod argocd app list --config /tmp/.config/argocd/config | grep default | egrep -v "^[0-9].*" | egrep -v "Synced.*Healthy" | awk '{ print $1 }')
        #oc rsh -c argocd-server $arcgocdPod argocd app list --config /tmp/.config/argocd/config | grep default | egrep -v "^[0-9].*"

        sleep 5
    done

}

deployGitOpsOperator(){
    
    # Create Operator Subscription
    oc create -f openshift-gitops-operator.yaml

    # Verify that GitOps is running
    verifyGitOpsOperator

    # Set Up ArgoCD Permissions - To be removed in future
    #setupArgoCDPermissions

    # Create Initial Cluster GitOps Application
    oc create -f cluster.yaml -n openshift-gitops

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

# Moved this to a argocd definition
#setupArgoCDPermissions(){
#    # Give ARGOCD cluster admin to CRC for demo purposes
#    oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
#}

crcStart(){

    # Ensure configs are correct
    setCRCConfigs
    
    # Start CRC
    crc start

    # Wait 30 seconds
    echo "Waiting 30 seconds for cluster to become stable"
    sleep 30

    # Log into CRC
    crcLogin

    # Show login Creds
    crcCreds
}

crcStop(){
    crc stop
}

crcClean(){
    crc stop
    crc delete
    #rm ~/.crc/vdb
    rm ~/.crc/crc.log*
    rm ~/.crc/crc.json
}

startupOptions(){
    echo "No startup options specified. Valid options:"
    echo "============================================"
    echo "* Set Up demo CRC (Some Manual): $0 setup"
    echo "* Set Up demo CRC (All Automated): $0 setup-all"
    echo "* Start CRC: $0 start"
    echo "* Stop CRC: $0 stop"
    echo "* Log into CRC with kubeadmin: $0 stop"
    echo "* Clean up CRC Environment: $0 clean"
    echo -e "\n"
    exit 1
}

createSSLCerts(){

    tempDirectory=$(mktemp -d)

    echo "Temp Dir: $tempDirectory"

    openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 \
        -subj '/O=CRC./CN=Testing' \
        -keyout $tempDirectory/root.key \
        -out $tempDirectory/root.crt

    openssl req -nodes -newkey rsa:2048 \
        -subj "/CN=*.apps-crc.testing/O=Example Inc." \
        -keyout $tempDirectory/wildcard.key \
        -out $tempDirectory/wildcard.csr

    openssl x509 -req -days 3650 -set_serial 0 \
        -CA $tempDirectory/root.crt \
        -CAkey $tempDirectory/root.key \
        -in $tempDirectory/wildcard.csr \
        -out $tempDirectory/wildcard.crt

    oc create -n istio-system secret tls wildcard-certs --key=$tempDirectory/wildcard.key --cert=$tempDirectory/wildcard.crt
}

setupServerlessTekton(){

    if [ $(oc get project quarkus-superheroes-serverless --no-headers | wc -l) -eq 0 ]; then
        echo "Creating quarkus-superheroes-serverless project"
        oc new-project quarkus-superheroes-serverless

        echo "Create argocd Secret"
        oc create secret generic argocd-env-secret -n quarkus-superheroes-serverless --from-literal=ARGOCD_USERNAME=admin --from-literal=ARGOCD_PASSWORD=$(argocdPassword)
    fi

}

setupCRCAll(){

    # Setup Initial
    setupCRC

    # Setup Tekton integration for OCP Serverless to openshift-gitops
    setupServerlessTekton

    # Wait for ArgoCD To install all the operators
    getArgoCDDefaultSyncStatus

    # Start syncing Service Mesh
    argocdSyncServiceMesh
    
    # Start syncing Tekton
    argocdSyncTekton
    
    # Start syncing Knative
    argocdSyncKnative

    # Show login Creds
    crcCreds

}

setupCRC(){

    # Check if Setup has happened before
    if [ $(crc status 2>&1 | grep "^Machine does not exist" | wc -l) -ne 1 ]; then
        echo "CRC already setup, please clean environment first before setting up"
        exit 1
    fi

    # Set CRC Configs
    setCRCConfigs

    # Start CRC
    crc start

    # Create & Attach Storage
    #createCRCPersistantStorage

    # Check Uptime
    ssh -p 22 -i ~/.crc/machines/crc/id_ecdsa core@"$(crc ip)" uptime

    # Log Into CRC
    crcLogin

    # Install Gitops Operator
    deployGitOpsOperator

    # Show login Creds
    crcCreds

}

crcDebug(){

    # Echo Remove this debug stage. This is for testing new features at this point
    deployGitOpsOperator

}

argocdPassword(){
    echo "$(oc get secret/openshift-gitops-cluster -n openshift-gitops -o yaml | grep "admin.password" | head -n1 | awk '{ print $2 }' | base64 --decode)"
}

argocdCreds(){

    echo "ArgoCD Login URL: https://$(oc get route -n openshift-gitops | grep openshift-gitops-server | awk '{ print $2 }')"
    echo "ArgoCD Admin user password: $(argocdPassword)"
}

crcCreds(){

    echo "CRC Console URL: $(oc get route -n openshift-console | grep ^console | awk '{ print $2 }')"

    crc console --credentials

    argocdCreds

}

# Startup
case "${1}" in
    setup)      setupCRC ;;
    setup-all)      setupCRCAll ;;
    start)      crcStart ;;
    stop)       crcStop ;;
    login)      crcLogin ;;
    clean)      crcClean ;;
    creds)      crcCreds ;;
    debug)      crcDebug ;;
    "")         startupOptions ;;
    *)          startupOptions ;;
esac


# oc get apimanager/3scale -o json | jq .status.deployments.starting
# Bug in tenant crd - creates multiple in 3scale

# registry.redhat.io/3scale-amp2/toolbox-rhel8:3scale2.12