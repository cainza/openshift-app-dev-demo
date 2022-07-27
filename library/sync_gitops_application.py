#!/usr/bin/python

# Copyright: (c) 2022, Francis Viviers <fviviers@redhat.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from tempfile import NamedTemporaryFile
import subprocess

DOCUMENTATION = r'''
---
module: verify_operator_installplan

short_description: Module that installs gitops Operator and Waits for it to become ready.

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: Monifor Operator Install Success

options:
    name: Name of the operator , required=True
    namespace: Namespace of the Operator, required=True
    group: API Group of the Operator, required=False
    version: API Version of the Operator, required=False
    plural: Object Name of the Operator , required=False
    timeout: Timeout to wait for the Operator to Finish Installing, required=False

author:
    - Francis Viviers (@cainza)
'''

EXAMPLES = r'''

To test this module:

python library/monitor_operator_install.py /tmp/args.json
cat /tmp/args.json 
{
    "ANSIBLE_MODULE_ARGS": {
        "name": "openshift-gitops-operator",
        "namespace": "openshift-operators"
    }
}

'''

RETURN = r'''

{"changed": true, "invocation": {"module_args": {"name": "openshift-gitops-operator", "namespace": "openshift-operators", "group": "operators.coreos.com", "version": "v1", "plural": "operators", "timeout": 600}}}

'''

from ansible.module_utils.basic import AnsibleModule

# Import Kubernetes Requirements
import kubernetes.config
import kubernetes.client
from kubernetes.client.rest import ApiException
from pprint import pprint
import time
from base64 import b64decode

def get_argocd_admin_password_secret(name, namespace):

    kubernetes.config.load_kube_config()

    # Enter a context with an instance of the API kubernetes.client
    with kubernetes.client.ApiClient() as api_client:

        # Create API Instance
        api_instance = kubernetes.client.CoreV1Api(api_client)    

        # Get API Respose, the return type is V1Secret
        api_response_obj =  api_instance.read_namespaced_secret(name, namespace)

        # Change The result from V1Secret to Dict
        api_response = api_response_obj.to_dict()

        # Decode the password, format is base64
        argocd_password = b64decode(api_response['data']['admin.password'])

        return argocd_password

def get_argocd_pod(namespace):

    #ist_namespaced_pod

    kubernetes.config.load_kube_config()

    # Enter a context with an instance of the API kubernetes.client
    with kubernetes.client.ApiClient() as api_client:

        # Create API Instance
        api_instance = kubernetes.client.CoreV1Api(api_client)

        # Get API Respose, the return type 
        api_response_obj =  api_instance.list_namespaced_pod(namespace)

        # Change The result from V1Secret to Dict
        api_response = api_response_obj.to_dict()

        #pprint (api_response['items'])

        for pod in api_response['items']:

                if pod['metadata']['labels']['app.kubernetes.io/name'] == "openshift-gitops-server":
                    return (pod['metadata']['name'])
                    
                    break

        return False

def sync_monitor_application(namespace, secret):

    print ("Sync APP")
    print ("Gitops Secret (openshift-gitops-cluster): %s" % secret)
    print ("Gitops namespace (openshift-gitops): %s" % namespace)

    gitops_password = get_argocd_admin_password_secret('openshift-gitops-cluster', 'openshift-gitops')

    print ("GitOps Password: %s" % gitops_password)

    gitops_pod = get_argocd_pod(namespace)
    
    print ("GitOps POD: %s" % gitops_pod)

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(    
        gitops_namespace=dict(type='str', required=True), # str | 
        secret_name=dict(type='str', required=False, default="openshift-gitops-cluster") # str | Gitops Admin password
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Generate the subscription
    #gitops_password = get_argocd_admin_password_secret('openshift-gitops-cluster', 'openshift-gitops')
    # gitops_password = get_argocd_admin_password_secret(module.params['secret_name'], module.params['gitops_namespace'])
    subscription = sync_monitor_application(module.params['gitops_namespace'], module.params['secret_name'])

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    #result['channel'] = module.params['channel']
    #result['message'] = 'goodbye'
    result['changed'] = subscription

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if result['changed'] == False:
        module.fail_json(msg='Operator install not found or valid', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()