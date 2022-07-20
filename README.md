
# Openshift Appdev All in One Demo!

  

The purpose of this repository is to provide you with a simple method to deploy and demo multiple components within the Red Hat Openshift Application development environment. Many of the components is integrated with each other tries to illustrate the full flow of components and how you might want to use them within a production environment.

  

Currently a shell script exists to prepare Openshift Local / Cloud Ready Containers. This will be expanded to work on Openshift Container Platform / Single Node Openshift.

  

## What can we Demo Today

  

1. Openshift GitOps - by setting up the demo environment
2. Openshift Pipelines - Build our serverless applications
3. Openshift Pipelines with GitOps - Deploy our serverless application with the pipeline syncing the GitOps application
4. Openshift Serverless (Knative Serving)
5. Openshift Service Mesh

  

## What will come in future

  

1. A/B Deployments ( Other deployment models )
2. 3Scale API Management
3. Openshift Serverless (Knative Eventing)
4. Openshift Serverless (Functions)
5. Openshift Serverless with Integration (CamelK)

  
# Configuration & Requirements

This demo requires a minimum of 32GB RAM to run.

A Minimum CPU requirement of 4 Cores with Hyperthreading enabled (8vCPU). 8 cores with hyperthreading (16vCPU) is recommended.

  

The demo-crc will set the required settings and can be configured within the script.

  

Defaults are:

|       |Value         |Description                  |
|-------|--------------|-----------------------------|
|CPUs   |`16`          |Sets the CPUs to 16          |
|Memory |`16384`       |Sets the Memory to 16GB      |
|Disk   |`100000`      |Sets the Disk to 100GB       |


This can also be manually set in Openshift Local/Cloud Ready Containers by running:

 - crc config set cpus 16
 - crc config set memory 16384
 - crc config set disk-size 100000
  

## 1. Openshift GitOps/ArgoCD

  The initial script will deploy the GitOps operator and when ready deploys the cluster configs application. This Deployment will deploy multiple other Applications to GitOps, some of which would start syncing immediately, others that require a manual sync.

  The applications that automatically sync is mainly for cluster operators that are dependencies for other Applications to be deployed. As an example the Service Mesh Operator requires ElasticSearch and Kiali Operators to be deployed before the service mesh can be created.

## 2. Openshift Pipelines/Tekton

  At this we use the quarkus superheroes github repository that can be found here: https://github.com/quarkusio/quarkus-super-heroes.git

  The quarkus super heroes API features multiple microservices low resource requirements, thanks to Quarkus. Due to the microservices having interservices dependencies using REST they form an ideal candidate for Service Mesh coming later.

## 3. Openshift Pipelines triggers GitOps

  https://developers.redhat.com/blog/2020/10/01/building-modern-ci-cd-workflows-for-serverless-applications-with-red-hat-openshift-pipelines-and-argo-cd-part-1

https://developers.redhat.com/blog/2020/10/14/building-modern-ci-cd-workflows-for-serverless-applications-with-red-hat-openshift-pipelines-and-argo-cd-part-2

## 4. Openshift Serverless

  https://docs.openshift.com/container-platform/4.10/serverless/admin_guide/serverless-ossm-setup.html

## 5. Openshift Service Mesh
 

