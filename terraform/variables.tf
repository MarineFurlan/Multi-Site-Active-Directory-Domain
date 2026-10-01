variable "vmware_username" {
  description = "Compte utilisé par l'API REST VMware Workstation"
  type        = string
}

variable "vmware_password" {
  description = "Mot de passe utilisé par l'API REST VMware Workstation"
  type        = string
  sensitive   = true
  ephemeral   = true
}