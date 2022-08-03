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
    secret: Secret contianing the Gitops Admin password
    namespace: Namespace GitOps Operator
    url: URL where GitOps is running
    port: Port on which GitOps is running/exposed
    application: Application within GitOps to sync

author:
    - Francis Viviers (@cainza)
'''

EXAMPLES = r'''

To test this module:

python library/sync_gitops_application.py /tmp/args.json
cat /tmp/args.json 
{
    "ANSIBLE_MODULE_ARGS": {
        "secret": "openshift-gitops-cluster",
        "namespace": "openshift-gitops",
        "url": "openshift-gitops-server-openshift-gitops.apps-crc.testing",
        "port": "443",
        "application": "my-application"
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
import tempfile
import os

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
        argocd_password = b64decode(api_response['data']['admin.password']).decode()

        return argocd_password

def get_argocd_pod(namespace):

    kubernetes.config.load_kube_config()

    # Enter a context with an instance of the API kubernetes.client
    with kubernetes.client.ApiClient() as api_client:

        # Create API Instance
        api_instance = kubernetes.client.CoreV1Api(api_client)

        # Get API Respose, the return type 
        api_response_obj =  api_instance.list_namespaced_pod(namespace)

        # Change The result from V1Secret to Dict
        api_response = api_response_obj.to_dict()

        for pod in api_response['items']:

                if pod['metadata']['labels']['app.kubernetes.io/name'] == "openshift-gitops-server":
                    return (pod['metadata']['name'])
                    
                    break

        return False

def argocd_login(argocd_config, url, port, password):

    exit_code = os.system("argocd login %s:%s --username=admin --password=%s --insecure --config %s" % (url, port, password, argocd_config))

    if exit_code != 0:
        return False
    
    return True



def sync_gitops_application(namespace, secret, gitops_url, gitops_port, application):

    print ("Sync APP")

    # Get Gitops Password - Byte encoded by default
    gitops_password = get_argocd_admin_password_secret('openshift-gitops-cluster', 'openshift-gitops')

    # Create Temporary Directory for ArgoCD Credentials
    argocd_tempdir = tempfile.mkdtemp()
    argocd_config = "%s/config" % argocd_tempdir

    # Log into Gitops
    login = argocd_login(argocd_config, gitops_url, gitops_port, gitops_password)

    if not login:
        print ("Login Failed")
        return login

    sync_exit_code = os.system("argocd --config %s app sync %s" % (argocd_config, application) )

    if sync_exit_code != 0:
        return False

    return True

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(    
        namespace=dict(type='str', required=True), # str | 
        secret=dict(type='str', required=False, default="openshift-gitops-cluster"), # str | Gitops Admin password
        url=dict(type='str', required=False, default="openshift-gitops-server"), # str | Gitops URL
        port=dict(type='str', required=False, default="443"), # str | Gitops Port
        application=dict(type='str', required=True) # str | GitOps Application to sync
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
    sync_status = sync_gitops_application(module.params['namespace'], module.params['secret'],module.params['url'],module.params['port'], module.params['application'])

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['changed'] = sync_status

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if result['changed'] == False:
        module.fail_json(msg='GitOps Appplication could not be synced', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()