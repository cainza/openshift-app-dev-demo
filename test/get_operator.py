#!/usr/bin/env python

import kubernetes.config
import kubernetes.client
from kubernetes.client.rest import ApiException
from pprint import pprint
import json
import time

kubernetes.config.load_kube_config()

# Enter a context with an instance of the API kubernetes.client
with kubernetes.client.ApiClient() as api_client:

    api_instance = kubernetes.client.CustomObjectsApi(api_client)
    group = 'operators.coreos.com' # str | the custom resource's group
    version = 'v1' # str | the custom resource's version
    plural = 'operators' # str | the custom resource's plural name. For TPRs this would be lowercase plural kind.
    name = 'openshift-gitops-operator.openshift-operators' # str | the custom object's name
    timeout = 5

    try:

        # needs to loop through installplan until installed

        test = '{"apiVersion":"operators.coreos.com\/v1","kind":"Operator","metadata":{"creationTimestamp":"2022-07-22T09:59:22Z","generation":1,"managedFields":[{"apiVersion":"operators.coreos.com\/v1","fieldsType":"FieldsV1","fieldsV1":{"f:spec":{}},"manager":"olm","operation":"Update","time":"2022-07-22T09:59:22Z"},{"apiVersion":"operators.coreos.com\/v1","fieldsType":"FieldsV1","fieldsV1":{"f:status":{".":{},"f:components":{".":{},"f:labelSelector":{".":{},"f:matchExpressions":{}},"f:refs":{}}}},"manager":"olm","operation":"Update","subresource":"status","time":"2022-07-22T09:59:22Z"}],"name":"openshift-gitops-operator.openshift-operators","resourceVersion":"319856","uid":"df5b17a3-6b2f-4d21-ba1a-53e5d8a29409"},"spec":{},"status":{"components":{"labelSelector":{"matchExpressions":[{"key":"operators.coreos.com\/openshift-gitops-operator.openshift-operators","operator":"Exists"}]},"refs":[{"apiVersion":"apiextensions.k8s.io\/v1","conditions":[{"lastTransitionTime":"2022-07-22T10:00:16Z","message":"no conflicts found","reason":"NoConflicts","status":"True","type":"NamesAccepted"},{"lastTransitionTime":"2022-07-22T10:00:16Z","message":"the initial names have been accepted","reason":"InitialNamesAccepted","status":"True","type":"Established"}],"kind":"CustomResourceDefinition","name":"applicationsets.argoproj.io"},{"apiVersion":"apiextensions.k8s.io\/v1","conditions":[{"lastTransitionTime":"2022-07-22T10:00:15Z","message":"no conflicts found","reason":"NoConflicts","status":"True","type":"NamesAccepted"},{"lastTransitionTime":"2022-07-22T10:00:15Z","message":"the initial names have been accepted","reason":"InitialNamesAccepted","status":"True","type":"Established"}],"kind":"CustomResourceDefinition","name":"gitopsservices.pipelines.openshift.io"},{"apiVersion":"apiextensions.k8s.io\/v1","conditions":[{"lastTransitionTime":"2022-07-22T10:00:16Z","message":"no conflicts found","reason":"NoConflicts","status":"True","type":"NamesAccepted"},{"lastTransitionTime":"2022-07-22T10:00:16Z","message":"the initial names have been accepted","reason":"InitialNamesAccepted","status":"True","type":"Established"}],"kind":"CustomResourceDefinition","name":"appprojects.argoproj.io"},{"apiVersion":"apiextensions.k8s.io\/v1","conditions":[{"lastTransitionTime":"2022-07-22T10:00:16Z","message":"no conflicts found","reason":"NoConflicts","status":"True","type":"NamesAccepted"},{"lastTransitionTime":"2022-07-22T10:00:16Z","message":"the initial names have been accepted","reason":"InitialNamesAccepted","status":"True","type":"Established"}],"kind":"CustomResourceDefinition","name":"argocds.argoproj.io"},{"apiVersion":"apiextensions.k8s.io\/v1","conditions":[{"lastTransitionTime":"2022-07-22T10:00:15Z","message":"no conflicts found","reason":"NoConflicts","status":"True","type":"NamesAccepted"},{"lastTransitionTime":"2022-07-22T10:00:15Z","message":"the initial names have been accepted","reason":"InitialNamesAccepted","status":"True","type":"Established"}],"kind":"CustomResourceDefinition","name":"applications.argoproj.io"},{"apiVersion":"operators.coreos.com\/v1alpha1","conditions":[{"lastTransitionTime":"2022-07-25T10:42:32Z","message":"all available catalogsources are healthy","reason":"AllCatalogSourcesHealthy","status":"False","type":"CatalogSourcesUnhealthy"},{"lastTransitionTime":"2022-07-25T10:42:31Z","message":"unpack job not yet started.","reason":"Installing","status":"True","type":"InstallPlanPending"}],"kind":"Subscription","name":"openshift-gitops-operator","namespace":"openshift-operators"},{"apiVersion":"operators.coreos.com\/v1alpha1","kind":"InstallPlan","name":"install-mt8jj","namespace":"openshift-operators"}]}}}'

        operator_installed = False

        # Run until operator has become available
        start_time = time.time() #  Start time
        while True:
            current_time = time.time()
            elapsed_time = current_time - start_time

            api_response = api_instance.get_cluster_custom_object(group, version, plural, name)

            for k8s_response in api_response['status']['components']['refs']:

                if k8s_response['kind'] == "InstallPlan" and 'conditions' in k8s_response:

                    # Find the install plan                        
                    install_plan_name = k8s_response['name']
                    print ("test")
                    print (k8s_response)
                                    
                    for condition in k8s_response['conditions']:
                        if condition['type'] == 'Installed':
                            operator_installed = True
                            break

                elif k8s_response['kind'] == "Subscription" and 'conditions' in k8s_response:

                    for condition in k8s_response['conditions']:
                        if condition['reason'] == 'Installing' or condition['type'] == 'InstallPlanPending':
                            print ("Operator install still in progress")

            if elapsed_time >= timeout:
                print("Finished iterating in: " + str(int(elapsed_time))  + " seconds")
                #raise "Timeout waiting for Operator to become ready"
                break
            
            # Wait between attempts
            time.sleep(5)

        # Itterate through operator status details
        #for k8s_response in api_response['status']['components']['refs']:
        #    
        #    # Find the install plan
        #    if k8s_response['kind'] == "InstallPlan":
        #        
        #        install_plan_name = k8s_response['name']
        #
        #        for condition in k8s_response['conditions']:

        #            if condition['type'] == 'Installed':
        #                operator_installed = True
        
        # Check if install plan was found otherwise throw exceptions
        if operator_installed == False:
            raise NameError("No install plan was found for Operator")

    except ApiException as e:
        print("Exception when calling CustomObjectsApi->get_cluster_custom_object: %s\n" % e)

    except NameError as e:
        print ("%s" % e)

    print (operator_installed)