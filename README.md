# OpenShift Origin Multi-Node Cluster

An OpenShift 3.6 cluster of 5 machine:
| Machine  | Hostname          | IP             | Description |
| :------- | :----             | :---:          | :---- |
| Toolbox  | toolbox.local.net |  192.168.1.100 | Ansible, Bind DNS, and NFS storage |
| Master   | master.local.net  |  192.168.1.101 | Cluster Master node |
| Infra    | infra.local.net   |  192.168.1.110 | Infra Node hosting Docker registry and HA Proxy router |
| Node1    | node1.local.net   |  192.168.1.111 | Worker node |
| Node2    | node2.local.net   |  192.168.1.112 | Worker node |

## Table of Content
[TOC]



## Hardware Requirements
This demo environment requires a machine of:
 - 4 cores
 - 16 GB RAM
 - 40 GB free disk space
| Machine | CPU | Memory  | Primary Disk             | Secondary Disk |
| :------ | :-: | :-----: | :----                    | :---- |
| Toolbox | 1   | 2048 MB | 40 GB dynamic allocation | NA    |
| Master  | 1   | 3072 MB | 40 GB dynamic allocation | 15 GB, dynamic, for Docker storage |
| Infra   | 1   | 3072 MB | 40 GB dynamic allocation | 20 GB, dynamic, for Docker storage |
| Node1   | 1   | 3072 MB | 40 GB dynamic allocation | 20 GB, dynamic, for Docker storage |
| Node2   | 1   | 3072 MB | 40 GB dynamic allocation | 20 GB, dynamic, for Docker storage |

> **Note:**
>  If your machine has 8 GB RAM you can do the following:
>  **1. Edit the machines-config.yml:**
>  
>  - Remove node2 at the end of the file.
>  - Adjust machines memory to be:
>  | Machine | Memory  | 
>  | :------  | :-----: | 
>  | Toolbox | 512 MB   |
>  | Master   | 2048 MB | 
>  | Infra      | 2048 MB | 
>  | Node1   | 2048 MB |
>  
>  **2. Edit /ansible/ansible-hosts.yaml: remove node2 from [worker_nodes] group.**


## Prerequisites
The following steps are tested on a Windows host machine.
### Install VirtualBox

 1. Install [VirtualBox 1.5](https://www.virtualbox.org/wiki/Download_Old_Builds_5_1)
 Check the [comparability](https://www.vagrantup.com/docs/virtualbox) between Vagrant and VirtualBox first. 
 2. Download the [Extension Pack](http://download.virtualbox.org/virtualbox/5.1.30/Oracle_VM_VirtualBox_Extension_Pack-5.1.30-118389.vbox-extpack) and add it to VirtualBox: **File --> Preferences --> Extensions --> Add**

### Install Vagrant 
 1. Install [Vagrant](https://www.vagrantup.com/downloads.html). This environment has been tested with Vagrant 1.9.7
 
 2. Install Vagrant VirtualBox Guest Plugin
```sh
vagrant plugin install vagrant-vbguest
```

## Network
All the machines are configures with NAT and Host Only adapters. 
> **Note:**
> The network may not behave properly over VPN, please disable any VPN before running the cluster.


## Cluster Provisioning
Clone the repository.
> **Recommendation:**
>   It's recommended to change the SSK keys under keys directory.

And run the following command
```sh
cluster init [parallel]
```
The command will start the machines in the following order:
 1. master, infra, node1, and node2
 2. toolbox
 
> **Note:**
>  The second argument 'parallel' is optional. It directs vagrant to start machines in parallel when possible.
 
As it's the first run of the machines, Vagrant will run provisioning scripts to install any required tools and configure the machines connectivity and networking.

## Connecting to The Cluster
### Test  Network Connectivity
Firstly, try to ping the cluster machines from your host:
```sh
ping 192.168.1.100
ping 192.168.1.101
ping 192.168.1.110
ping 192.168.1.111
ping 192.168.1.112
```
### Add Cluster DNS to Host Machine
Now, we need to cluster DNS to host in order to resolve machines hostnames:

 - Go to **Network Connections**
 - Select the **VirtualBox Host-Only Network --> Properties --> Internet Protocol version 4 --> Properties**
 - Make sure that the IP addressis **192.168.1.1**, otherwise, try another adapter.
 - Add DNS server **192.168.1.100** and save.
 - Try to ping using machine hostname:
```sh
ping toolbox.local.net
```
 
### SSH Connection to Cluster Machines
Use your preferred SSH Client to connect to the machines. I personally recommend [MobaXterm](https://mobaxterm.mobatek.net/).
Use the private key in the /keys directory to connect.
Machines Users:
| User    | Password | 
| :------ | :------  | 
| root    | vagrant  |
| vagrant | vagrant  | 

## Installation and Configuration
> **Recommendation:**
>  I recommend that you take snapshots of the machines at this point, so you call roll back to them.

Connect to the Toolbox machine, and make sure that Ansible can reach to all the cluster machines:
```sh
ansible cluster -m ping
```
### Docker

 - Install Docker and configure its storage:
```sh
ansible-playbook /vagrant/ansible/playbooks/setup-docker.yml
```
 - Pull Docker images prior to OpenShift installation:
```sh
ansible-playbook /vagrant/ansible/playbooks/populate-docker-registry.yml
```
> **Recommendation:**
>  Take snapshots of machines: master, infra, node1, and node1.

## OpenShift
 

 - Install OpenShift Prerequisites: 
```sh
ansible-playbook /vagrant/ansible/playbooks/openshift-pre-install.yml
```
 - Install OpenShift:
```sh
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml
```
 - Configure OpenShift:
```sh
ansible-playbook /vagrant/ansible/playbooks/openshift-post-install.yml
```
 - Now, try to login to OpenShift Console from host machine
 https://master.local.net:8443
 Accept the certificate and use admin/admin to login
 - Also try the Docker registry
 https://registry-console-default.cloudapps.local.net

 
## Cluster Control 

 - Start the Cluster:
```sh
cluster up [parallel]
```
 - Shutdown the Cluster:
```sh
cluster down
```

## Next Enhancements

- Enhance documentation.
- Convert provisioning shell scripts to Ansible playbooks.
- Use GlusterFs for storage.
