terraform {
  required_version = ">= 0.13"

  required_providers {
    vcd = {
      source = "vmware/vcd"
    }
  }
}

provider "vcd" {
  user = var.vcd_user
  password = var.vcd_pass
  auth_type = "integrated"
  org = var.vcd_org
  vdc = var.vcd_vdc
  url = var.vcd_url
  max_retry_timeout = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
  #logging              = true
  #logging_file         = "tenant-debug.log"
}

#fetch a vApp template from catalog
data "vcd_catalog" "fetch_vcd_catalog" {
  org  = var.org
  name = var.vcd_catalog_name
}

data "vcd_catalog_vapp_template" "vcd_catalog" {
  org        = var.org
  catalog_id = var.vcd_catalog_id
  name       = var.vapp_template_name
}

#create vApp
resource "vcd_vapp" "postgres_cluster" {
  name = "postgres_cluster"
}

#attach an existing Org VDC Network to a vApp
resource "vcd_vapp_org_network" "direct-network" {
  vapp_name        = "postgres_cluster"
  org_network_name = var.network_name
  reboot_vapp_on_removal = true
  depends_on = [vcd_vapp.postgres_cluster]
}

#create VM1
resource "vcd_vapp_vm" "postgres_primary" {
  vapp_name = "postgres_cluster"
  name      = "postgres_primary"
  vapp_template_id = var.vapp_template_id
  memory = 4096
  cpus   = 2

  guest_properties = {
    "guest.hostname" = "postgres_primary"
  }

  network {
    type               = "org"
    name               = var.network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }
  
  customization {
    force                      = true
    enabled                    = true
    allow_local_admin_password = true
    auto_generate_password     = true
  }

  depends_on = [vcd_vapp_org_network.direct-network]
}

#create VM2
resource "vcd_vapp_vm" "postgres_standby" {
  vapp_name = "postgres_cluster"
  name      = "postgres_standby"
  vapp_template_id = var.vapp_template_id
  memory = 4096
  cpus   = 2

  guest_properties = {
    "guest.hostname" = "postgres_standby"
  }

  network {
    type               = "org"
    name               = var.network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }
  
  customization {
    force                      = true
    allow_local_admin_password = true
    auto_generate_password     = true
  }

  depends_on = [vcd_vapp_org_network.direct-network]
}
