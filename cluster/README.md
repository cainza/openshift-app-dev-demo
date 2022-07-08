ARGOCD Configure Cluster


CREATE Demo Operators GitOps ( ArgoCD ) Application

Application Name    : demo-operators
Project: default
Sync Policy: Manual

Repository URL: https://github.com/cainza/openshift-app-dev-demo.git
Revision: main
Path: cluster/openshift-operators

Cluster URL: https://kubernetes.default.svc
Namespace: 