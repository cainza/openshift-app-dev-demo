# Openshift Appdev All in One Demo!

The purpose of this repository is to provide you with a simple method to deploy and demo multiple components within the Red Hat Openshift Application development environment. Many of the components is integrated with each other tries to illustrate the full flow of components and how you might want to use them within a production environment.

Currently a shell script exists to prepare Openshift Local / Cloud Ready Containers. This will be expanded to work on Openshift Container Platform / Single Node Openshift.

## What can we Demo Today

 1. Openshift GitOps - by setting up the demo environment
 2. Openshift Pipelines - Build our serverless applications
 3. Openshift Pipelines with GitOps - Deploy our serverless application with the pipeline syncing the GitOps application
 4. Openshift Service Mesh - Serverless Application integrated into the service mesh
 5. Openshift Serverless (Knative Serving)

## What will come in future

 1. A/B Deployments ( Other deployment models )
 2. 3Scale API Management
 3. Openshift Serverless ( Knative Eventing )



NOTES:
---------------

 crc config set cpus 16
 crc config set memory 16384
 crc config set disk-size 80000


oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller 

https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html/service_mesh/service-mesh-2-x#ossm-tutorial-bookinfo-overview_ossm-create-mesh

export GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')

http://istio-ingressgateway-istio-system.apps-crc.testing/productpage


kiali-istio-system.apps-crc.testing


https://developers.redhat.com/blog/2020/10/01/building-modern-ci-cd-workflows-for-serverless-applications-with-red-hat-openshift-pipelines-and-argo-cd-part-1

https://developers.redhat.com/blog/2020/10/14/building-modern-ci-cd-workflows-for-serverless-applications-with-red-hat-openshift-pipelines-and-argo-cd-part-2



https://docs.openshift.com/container-platform/4.10/serverless/admin_guide/serverless-ossm-setup.html



####  ARGOCD
export HOME=/tmp/
argocd  login openshift-gitops-server-openshift-gitops.apps-crc.testing:443 --insecure --username=admin --password=2Xv9xiYdpSbcVDTNtZL4sHg6ulJWj8mU


oc get secret -n openshift-gitops openshift-gitops-cluster -o "jsonpath={.data.admin\.password}"