terraform {
  required_providers {
    vmworkstation = {
      source  = "elsudano/vmworkstation"
      version = "2.0.1"
    }
  }
}

provider "vmworkstation" {
  endpoint = "http://127.0.0.1:8697/api"
  username = var.vmware_username
  password = var.vmware_password
  https    = false
  debug = "NONE"
}

data "vmworkstation_virtual_machine" "template" {
  denomination = "Novera-Win2025-Template"
}