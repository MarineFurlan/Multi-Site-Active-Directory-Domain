packer {
  # Packer utilise ce plugin pour communiquer avec VMware Workstation.
  required_plugins {
    vmware = {
      source = "github.com/hashicorp/vmware"
      version = ">= 1.16.1"
    }
  }
}

source "vmware-iso" "windows-server" {
  vm_name = "Novera-Win2025-Template"
}

build {
  sources = [
    "source.vmware-iso.windows-server"
    iso_url = "D:/DevSecOps/VMs/ISOs/26100.32230.260111-0550.lt_release_svc_refresh_SERVER_EVAL_x64FRE_fr-fr.iso"
    network_adapter_type = "e1000e"
  ]
}