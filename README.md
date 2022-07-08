OPENSHIFT-APP-DEV-DEMO

--- 
What we want to achieve:

1. Demo Openshift GitOps by setting up the demo environment with it
2. Demo Openshift Pipelines
3. Demo Openshift Pipelines integrating to GitOps
4. Demo Openshift Service Mesh
5. Demo Openshift A/B application deployments
6. Demo Openshift Serverless (Knative)



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