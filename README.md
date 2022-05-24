OPENSHIFT-APP-DEV-DEMO


oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller 

https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html/service_mesh/service-mesh-2-x#ossm-tutorial-bookinfo-overview_ossm-create-mesh

export GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')

http://istio-ingressgateway-istio-system.apps-crc.testing/productpage


kiali-istio-system.apps-crc.testing