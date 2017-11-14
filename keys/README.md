# Vagrant Cluster

Vagrant environment of 5 machines for openshift installation:

* toolbox.local.net: to host Ansible, and NFS storage.
* master01.local.net: to host openshift master node
* infra.local.net: to host the router and docker registry.
* node01.local.net, node02.local.net: worker nodes.

currently, the cluster is relaying on external DNS running on the host machine, I am using Posadis: http://posadis.sourceforge.net/docs/tutorial/cache.html

## Tools & Versions

* Vagrant 1.9.7
* Centos 7
* Posadis DNS
* Ansible

## Networking


## Provessioning Scripts

## To Do

* Enhance vagrant configurations.
* Move DNS to toolbox to break dependency on host machine.
* Convert provisioning shell scripts to Ansible playbooks.
* Automate the installation of openshift dependencies with Ansible.
* Minimize the machines size to 3.
* Use GlusterFs for storage.
