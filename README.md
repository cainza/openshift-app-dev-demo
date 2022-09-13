
# Openshift Appdev All in One Demo!

  

The purpose of this repository is to provide you with a simple method to deploy and demo multiple components within the Red Hat Openshift Application development environment. Many of the components is integrated with each other tries to illustrate the full flow of components and how you might want to use them within a production environment.

  

Currently a shell script exists to prepare Openshift Local / Cloud Ready Containers. This will be expanded to work on Openshift Container Platform / Single Node Openshift.

  

## What can we Demo Today

1. Openshift GitOps - by setting up the demo environment
2. Openshift Pipelines - Build our serverless applications
3. Openshift Pipelines with GitOps - Deploy our serverless application with the pipeline syncing the GitOps application
4. Openshift Serverless (Knative Serving)
5. Openshift Service Mesh
6. ODF LVM - This serves as our backing store for ODF Multi Cloud Gateway (Noobaah) etc.


  

## What will come in future

  

1. A/B Deployments ( Other deployment models )
2. 3Scale API Management
3. Openshift Serverless (Knative Eventing)
4. Openshift Serverless (Functions)
5. Openshift Serverless with Integration (Camel-K)

  
# Configuration & Requirements

This demo requires a minimum of 32GB RAM to run.

A Minimum CPU requirement of 4 Cores with Hyperthreading enabled (8vCPU). 8 cores with hyperthreading (16vCPU) is recommended.

  

The demo-crc will set the required settings and can be configured within the script.

  

Defaults are:

|       |Value         |Description                  |
|-------|--------------|-----------------------------|
|CPUs   |`12`          |Sets the CPUs to 12          |
|Memory |`32768`       |Sets the Memory to 32GB      |
|Disk   |`100000`      |Sets the Disk to 100GB       |


This can also be manually set in Openshift Local/Cloud Ready Containers by running:

 - crc config set cpus 12
 - crc config set memory 32768
 - crc config set disk-size 100000


## Ansible Playbooks

  The setup of the demo environment is done via ansible playbooks.

  I have written custom libraries that monitor the state of things such as syncing ArgoCD/GitOps applications, syncing custom resources, monitoring operator installs etc. This ensures certain steps in the ansible roles only run when the dependencies they have are ready to be consumed. As an example the Service Mesh Operator requires ElasticSearch and Kiali Operators to be deployed before the service mesh can be created.

## Openshift GitOps/ArgoCD

  The initial script will deploy the GitOps operator and when ready deploys the cluster configs application. 

  Other GitOps application will be deployed via the ansible playbook.They will vary from installing operators to deploying Quarkus applications to deploying things just as AMQ Streams ( Kafka ).

  The applications that automatically sync is mainly for cluster operators that are dependencies for other Applications to be deployed. 

## Openshift Pipelines/Tekton

  At this we use the quarkus superheroes github repository that can be found here: https://github.com/quarkusio/quarkus-super-heroes.git

  The quarkus super heroes API features multiple microservices low resource requirements, thanks to Quarkus. Due to the microservices having interservices dependencies using REST they form an ideal candidate for Service Mesh coming later.

  There is also a stage within the pipeline that triggers the sync of the quarkus demo application knative deployment. This bothnot only shows how GitOps can sync resources but also how these resources could be synced after a successfull pipeline run.

## 4. Openshift Serverless

  We use quarkus native built applications. We use this for the startup times required for Openshfit Serverless. Since we are using a mesh of microservices the minimum count has been set to 1 container. The reason for this is that it takes a few seconds for everything downstream to start up.

  On the event statistics endpoint we will set the minimum to 0 so that we can show it starting up as needed. This same microservices will also run an instance per request to show how it scales depending on requests.

  Note: You have to access both the rest-fights and the ui-superheroes external links directly once when using self service mesh signed certificates (The default for this demo). HTTPs is a requirement for using Serverless on Service mesh. If don't access the rest-fights service the and accept the self signed certificate then the UI will not work correctly as it calls that service.

  https://docs.openshift.com/container-platform/4.10/serverless/admin_guide/serverless-ossm-setup.html

## 5. Openshift Service Mesh

  Openshift Service mesh was set up so that we can monitor the state of our quarkus microservices. Two of the rest services are exposed externally while the rest are internal to the cluster.
 
- [README Single Node Openshift](README-SNO.md)
- [README Openshift Local](README-CRC.md)

### Notes

# TODO
# 1) User namespace monitoring
# 2) KEDA

