# makes use of vsphere content libraries to enable vm config functions (disksize, cpu, ram) for a pre-defined ova image
# you need to pre-create vsphere content library and library_item

provider "vsphere" {
	user = var.vcenter_user
	password = var.vcenter_password
	vsphere_server = var.vcenter_server
	allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
	name			= var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
	name			= var.vsphere_cluster
	datacenter_id 	= data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
	name			= var.vsphere_datastore
	datacenter_id 	= data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
	name			= var.vsphere_resourcepool
	datacenter_id 	= data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
	name          	= var.vsphere_host
	datacenter_id 	= data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
	name          	= var.vsphere_network
	datacenter_id 	= data.vsphere_datacenter.dc.id
}

data "vsphere_content_library" "library" {
	name			= var.vsphere_library
}

data "vsphere_content_library_item" "library_item_ubuntu" {
	name			= var.vsphere_library_image
	type			= "OVA"
	library_id 		= data.vsphere_content_library.library.id
}

# create cloud-init file for linux vm on vSphere On-Premises
resource "local_file" "cloud-init" {
	for_each 	= var.hosts
	content 	= templatefile("${path.module}/cloud-init-k8s-linux.tpl", { 
		user 				= var.vm_user, 
		ssh_authorized_keys	= local.ssh_keys,
		nameservers			= var.vm_nameservers,
		dns_searchpath		= var.vm_dns_searchpath,
		default_gateway		= var.vm_default_gateway,
		network_interface	= var.vm_network_interface,
		timeserver 			= var.vm_timeserver,
		ip_address			= each.value,
		hostname 			= each.key
		}
	)
	filename = "${path.module}/cloud-init-${each.key}.yaml"
}

resource "vsphere_virtual_machine" "linux" {
	for_each					= var.hosts
	name						= each.key
	resource_pool_id			= data.vsphere_resource_pool.pool.id
	datastore_id			 	= data.vsphere_datastore.datastore.id
	host_system_id				= data.vsphere_host.host.id
	wait_for_guest_net_timeout	= 0
	wait_for_guest_ip_timeout	= 0
	num_cpus 					= 4
	memory						= 4096
	disk {
		label = "disk0"
		size = 25 
	}
	cdrom {
		client_device = true
	}
	network_interface {
		network_id = data.vsphere_network.network.id
	}
	clone {
		template_uuid = data.vsphere_content_library_item.library_item_ubuntu.id
	}
	vapp {
		properties = {
			"instance-id" = each.key
#			"hostname" = "linuxvm"
#			"password" = "VMware1!"
			user-data = base64encode(local_file.cloud-init[each.key].content)
			#user-data = local_file.cloud-init[each.key].content
		}
	}
}
