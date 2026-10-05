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
  iso_url = "D:/DevSecOps/VMs/ISOs/26100.32230.260111-0550.lt_release_svc_refresh_SERVER_EVAL_x64FRE_fr-fr.iso"
  iso_checksum = "sha256:F7AB045C3680F3D4A0CC826B68A947E8253A617DEC8E2BBFC221201CFE2BD2B7"
  network_adapter_type = "e1000e"
  ssh_username = "Administrator"
}

build {
  sources = [
    "source.vmware-iso.windows-server"
  ]
}