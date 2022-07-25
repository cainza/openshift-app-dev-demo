#!/usr/bin/env python

import kubernetes.config
import kubernetes.client
from kubernetes.client.rest import ApiException
from pprint import pprint
import json

kubernetes.config.load_kube_config()

# Enter a context with an instance of the API kubernetes.client
with kubernetes.client.ApiClient() as api_client:

    api_instance = kubernetes.client.CustomObjectsApi(api_client)
    group = 'operators.coreos.com' # str | the custom resource's group
    version = 'v1' # str | the custom resource's version
    plural = 'operators' # str | the custom resource's plural name. For TPRs this would be lowercase plural kind.
    name = 'openshift-gitops-operator.openshift-operators' # str | the custom object's name

    try:

        # needs to loop through installplan until installed

        api_response = api_instance.get_cluster_custom_object(group, version, plural, name)

        operator_installed = False

        # Itterate through operator status details
        for k8s_response in api_response['status']['components']['refs']:
            
            # Find the install plan
            if k8s_response['kind'] == "InstallPlan":
                
                install_plan_name = k8s_response['name']

                for condition in k8s_response['conditions']:

                    if condition['type'] == 'Installed':
                        operator_installed = True
        
        # Check if install plan was found otherwise throw exceptions
        if operator_installed == False:
            raise NameError("No install plan was found for Operator")

    except ApiException as e:
        print("Exception when calling CustomObjectsApi->get_cluster_custom_object: %s\n" % e)

    except NameError as e:
        print ("%s" % e)

    print (operator_installed)