# Instructions for Single Node Openshift (SNO)

## Firewalls
If you are running this on RHEL or Fedora using KVM please open the firewall using the following commands:

 - Openshift API access:
	 - sudo firewall-cmd --permanent --add-port=6443/tcp
 - Openshift Ingress Router (HTTPs):
	 - sudo firewall-cmd --permanent --add-port=443/tcp
 - Openshift Ingress Router (HTTP):
	 -  sudo firewall-cmd --permanent --add-port=80/tcp

## Single node Openshift without DNS
If you are planning to deploy a single node cluster but you don't have a valid domain you can use systemd-resolve to handle DNS requests for the required wildcard domain and forward those to your Openshift Cluster which will provide you with DNS resolution. 

Create a file called   /etc/NetworkManager/dispatcher.d/00-sno-local.sh

    # This is a NetworkManager dispatcher script to configure split DNS for SNO libvirt network
	export LC_ALL=C
	systemd-resolve --interface virbr0 --set-dns 192.168.122.$(YOUR_OCP_IP) --set-domain ~sno.openshift.local
	exit 0
    
## Deploy the demo environment into Single Node Openshift

Ensure ansible is installed and run the following commands

    ansible-playbook -i hosts/hosts playbooks/ocp-setup.yml

You will be prompted for your Openshift information as follows. If you have your kubeconfig set up you can comment out the step within the playbook:

    Please enter your openshift location ( example: https://api.openshift.local:6443): 
    Please enter your OCP user (With cluster-admin rights): cluster-admin
    Please enter your OCP user's password (Output will be hidden):

This process will take some time to finish as it deploys the various components within the cluster.