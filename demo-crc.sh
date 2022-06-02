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

verifyGitOpsOperator(){

    echo "Verify GitOps Operator is running"
    

    while [ $(oc get po -n openshift-operators | grep gitops-operator-controller-manager | grep "1/1" | wc -l) -ne 1 ]; do 
        echo "Waiting for Openshift GitOps Operator to be ready in openshift-gitops namespace";

        sleep 2
    done

    echo -e "Waiting for GitOps Deployments to be available"
    while [ $(oc get deployments -n openshift-gitops --no-headers | wc -l) -lt 7 ]; do
        echo -e "."
        sleep 2
    done
    
    echo "Verify Gitops is running"
    while [ $(oc get deployments -n openshift-gitops --no-headers | grep -v "1/1"  | wc -l) -ne 0 ]; do 
        echo "Waiting for Openshift GitOps containers to be ready in openshift-gitops namespace";

        oc get deployments -n openshift-gitops --no-headers

        sleep 2
    done

    # Completed GitOps install
    echo "GitOps install Completed"
}

deployGitOpsOperator(){
    
    # Create Operator Subscription
    oc create -f openshift-gitops-operator.yaml

    # Verify that GitOps is running
    verifyGitOpsOperator

    # Set Up ArgoCD Permissions
    setupArgoCDPermissions

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

setupArgoCDPermissions(){
    # Give ARGOCD cluster admin to CRC for demo purposes
    oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
}

crcStart(){
    
    # Start CRC
    crc start

    # Log into CRC
    crcLogin
}

crcStop(){
    crc stop
}

crcClean(){
    crc stop
    crc delete
    rm ~/.crc/vdb
    rm ~/.crc/crc.log*
    rm ~/.crc/crc.json
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
    createCRCPersistantStorage

    # Check Uptime
    ssh -p 22 -i ~/.crc/machines/crc/id_ecdsa core@"$(crc ip)" uptime

    # Log Into CRC
    crcLogin

    # Install Gitops Operator
    deployGitOpsOperator

}

crcDebug(){

    # Echo Remove this debug stage. This is for testing new features at this point
    deployGitOpsOperator

}

crcCreds(){
    crc console --credentials

    echo "ArgoCD Admin user password: $(oc get secret/openshift-gitops-cluster -n openshift-gitops -o yaml | grep "admin.password" | head -n1 | awk '{ print $2 }' | base64 --decode)"
}

# Startup
case "${1}" in
    setup)      setupCRC ;;
    start)      crcStart ;;
    stop)       crcStop ;;
    login)      crcLogin ;;
    clean)      crcClean ;;
    creds)      crcCreds ;;
    debug)      crcDebug ;;
    "")         startupOptions ;;
    *)          startupOptions ;;
esac


# ODF LVM Doesn't work yet
# ARGOCD ODF LVM Storage Group Doesn't work yet
# Maybe use built in PVC's? 
# i.e. pv0030

"""

Unable to deploy revision: permission denied: applications, sync, default/1-istio-controlplane, sub: CiQ4ZTY0YjZkZi02NjhlLTRhZjEtOTg0MS1kNjdmM2JlNDg5M2ISCW9wZW5zaGlmdA, iat: 2022-06-02T09:18:15Z

time="2022-06-02T09:21:01Z" level=info msg="received unary call /application.ApplicationService/Sync" grpc.method=Sync grpc.request.claims="{\"at_hash\":\"8lfi8R3aDY8rU_a5lgKItA\",\"aud\":\"argo-cd\",\"c_hash\":\"K48ukeRAErhelzCGTyLmBg\",\"email\":\"kubeadmin\",\"email_verified\":false,\"exp\":1654247895,\"groups\":[\"system:authenticated\",\"system:authenticated:oauth\"],\"iat\":1654161495,\"iss\":\"https://openshift-gitops-server-openshift-gitops.apps-crc.testing/api/dex\",\"name\":\"kubeadmin\",\"preferred_username\":\"kubeadmin\",\"sub\":\"CiQ4ZTY0YjZkZi02NjhlLTRhZjEtOTg0MS1kNjdmM2JlNDg5M2ISCW9wZW5zaGlmdA\"}" grpc.request.content="name:\"1-istio-controlplane\" revision:\"development\" dryRun:false prune:false strategy:<hook:<syncStrategyApply:<force:false > > > retryStrategy:<limit:2 backoff:<duration:\"5s\" factor:2 maxDuration:\"3m0s\" > > syncOptions:<items:\"CreateNamespace=true\" > " grpc.service=application.ApplicationService grpc.start_time="2022-06-02T09:21:01Z" span.kind=server system=grpc
time="2022-06-02T09:21:01Z" level=warning msg="finished unary call with code PermissionDenied" error="rpc error: code = PermissionDenied desc = permission denied: applications, sync, default/1-istio-controlplane, sub: CiQ4ZTY0YjZkZi02NjhlLTRhZjEtOTg0MS1kNjdmM2JlNDg5M2ISCW9wZW5zaGlmdA, iat: 2022-06-02T09:18:15Z" grpc.code=PermissionDenied grpc.method=Sync grpc.service=application.ApplicationService grpc.start_time="2022-06-02T09:21:01Z" grpc.time_ms=4.7 span.kind=server system=grpc

""""