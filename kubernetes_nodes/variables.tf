variable "public_key_path" {
  type        = string
  description = "File path to public key to be added to node"
}

variable "worker_hostname" {
  type = string
  description = "Prefix of the worker hostname, based on the number of workers the index will be added to the name."
  default = "worker"
}

variable "master_hostname" {
  type = string
  description = "Prefix of the master hostname"
  default = "master"
}

variable "parent_domain" {
  type = string
  description = "Suffix of the FQDN of hosts"
}

variable "libvirt_vm_dir" {
  type = string
  description = "Root directory where to store vm disks and isos"
}

variable "libvirt_fqdn" {
  type = string
  description = "Fully Qualified Domain Name of the libvirt hypervisor"
}

variable "libvirt_pool_name" {
  type = string
  description = "Name of the libvirt pool where to store the imported disk images."
  default = "kube_data"
}

variable "network_bridge" {
  type = string
  description = "Name of the network bridge inside hypervisor to attach the nodes to."
  default = "kube_network"
}

variable "worker_count" {
  type        = number
  description = "Number of kubernetes workers to create"
  default = 1
}

variable "worker_memory" {
  type        = number
  description = "Amount of ram for a kubernetes worker vm"
  default = 1536
}

variable "worker_cpu_count" {
  type        = number
  description = "Number of vcpus for a kubernetes worker vm"
  default = 1
}

variable "master_memory" {
  type        = number
  description = "Amount of ram for a kubernetes master vm"
  default = 1536
}

variable "master_cpu_count" {
  type        = number
  description = "Number of vcpus for a kubernetes master vm"
  default = 1
}
