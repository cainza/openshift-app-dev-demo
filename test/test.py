#!/usr/bin/env python

from __future__ import print_function
import time
import kubernetes.config
import kubernetes.client
from kubernetes.client.rest import ApiException
from pprint import pprint
import json

kubernetes.config.load_kube_config()

# Enter a context with an instance of the API kubernetes.client
with kubernetes.client.ApiClient() as api_client:

    # Create an instance of the API class
    #api_instance = kubernetes.client.CustomObjectsApi(api_client)
    #group = 'apps' # str | the custom resource's group
    #version = 'v1' # str | the custom resource's version
    #plural = 'deployments' # str | the custom resource's plural name. For TPRs this would be lowercase plural kind.
    #name = 'gitops-operator-controller-manager' # str | the custom object's name

    api_instance = kubernetes.client.CustomObjectsApi(api_client)
    group = 'operators.coreos.com' # str | the custom resource's group
    version = 'v1' # str | the custom resource's version
    plural = 'operators' # str | the custom resource's plural name. For TPRs this would be lowercase plural kind.
    name = 'openshift-gitops-operator.openshift-operators' # str | the custom object's name


    try:
        #api_response = api_instance.get_namespaced_custom_object(group, version, namespace, plural, name)
        #pprint(api_response)

        #k8s_json = json.dumps(api_response)

        #print (api_response)

        
        api_response = api_instance.get_cluster_custom_object(group, version, plural, name)

        pprint (api_response)


    except ApiException as e:
        print("Exception when calling CustomObjectsApi->get_namespaced_custom_object: %s\n" % e)


#    header_params = {}
#    header_params['Accept'] = self.api_client.select_header_accept(
#        ['application/json', 'application/yaml', 'application/vnd.kubernetes.protobuf'])  # noqa: E501


#    api_client.call_api(
#        '/apis/operators.coreos.com/v1alpha1/namespaces/{namespace}/installplans', 'GET',
#        {},
#        {},
#        header_params)

# kubectl get deployments -o json | less
# A subscription has its installplanref