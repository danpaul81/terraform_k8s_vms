variable "hosts" {
	description = "hostname / ip for vm's to be created"
	type = map
	default = {
		k8s2-master		= "192.168.110.90/24"
		k8s2-node1 		= "192.168.110.91/24"
		k8s2-node2  	= "192.168.110.92/24"
	}
}

variable "vm_user" {
	description 	="Local VM username"
	type			= string
	default 		= "vmware"
}

variable "vm_timeserver" {
	description 	= "NTP Server to put into VM config"
	type 			= string
	default 		= "192.168.110.10"
}

variable "vm_nameservers" {
	description 	= "DNS Servers to put into VM network config"
	type 			= string
	default 		= "192.168.110.10"
}

variable "vm_dns_searchpath" {
	description 	= "DNS Searchpath to put into VM network config"
	type 			= string
	default 		= "corp.local"
}

variable "vm_default_gateway" {
	description 	= "Default Gateway to put into VM network config"
	type 			= string
	default 		= "192.168.110.1"
}

variable "vm_network_interface" {
	description 	= "VM Network interface (guest OS) to be pre-configured"
	type 			= string
	default 		= "ens192"
}

### vSphere specific Variables

variable "vcenter_server" {
	description		= "vCenter Server"
	type			= string
	default			= "192.168.110.22"
}

variable "vcenter_password" {
	description		= "vCenter Server Password"
	type			= string
	default			= "VMware1!"
}

variable "vcenter_user" {
	description		= "vCenter Server User"
	type			= string
	default			= "administrator@vsphere.local"
}

variable "vsphere_library" {
	description		= "Existing vSphere Content Library to use for deployment"
	type			= string
	default			= "ubuntu"
}

variable "vsphere_library_image" {
	# get it from https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.ova and place in vSphere Content Library
	description		= "Existing vSphere Content Library OVA Image to use for deployment (tested with Ubuntu bionic)"
	type			= string
	default			= "bionic-server-cloudimg-amd64"
}

	variable "vsphere_datacenter" {
	description 	="vSphere pre-created Datacenter for ovpn_client VM"
	type			= string
	default 		= "DC-SiteA"
}

variable "vsphere_cluster" {
	description 	="vSphere pre-created Cluster for ovpn_client VM"
	type			= string
	default 		= "Compute-Cluster"
}

variable "vsphere_datastore" {
	description 	="vSphere pre-created Datastore for ovpn_client VM"
	type			= string
	default 		= "ds-site-a-nfs02"
}

variable "vsphere_resourcepool" {
	description 	="vSphere pre-created Resource Pool for ovpn_client VM"
	type			= string
	default 		= "Compute-Pool"
}

variable "vsphere_host" {
	description 	="vSphere pre-created ESXi Host for ovpn_client VM"
	type			= string
	default 		= "esxcomp-01a.corp.local"
}

variable "vsphere_network" {
	description 	="vSphere pre-created PortGroup or NSX Segment for ovpn_client VM"
	type			= string
	default 		= "LabNet"
}



# SSH keys for user Login. Please provide keys in named file
data "local_file" "provided_ssh_keys" {
  filename = "${path.module}/config_data/authorized_keys.txt"
}

# re-read each config file line-by line, remove line breaks and store in array
# template file will read each line and print with fitting spaces to keep resulting yaml valid
 locals {
	ssh_keys = [
	for line in split("\n", data.local_file.provided_ssh_keys.content):
	  chomp(line)
	 ]
}
