
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
    