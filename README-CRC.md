# Instructions for Openshift Local (Formally CRC)

## Deploy the demo environment into CRC

Ensure ansible is installed and run the following commands

    ansible-playbook -i hosts/hosts playbooks/crc-setup.yml

The ansible playbook will automatically create the crc instance and set the relevant required parameters such as CPU, Memory and Disk.

The default configuration parameters can be found at:

    - [playbooks/roles/crc-config/defaults/main.yml](playbooks/roles/crc-config/defaults/main.yml )   

This process will take some time to finish as it deploys the various components within the cluster.