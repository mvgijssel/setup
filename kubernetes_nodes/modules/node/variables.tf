variable "name" {
  type = string
}

variable "public_key_path" {
  type        = string
}

variable "image_path" {
  type = string
}

variable "libvirt_pool_name" {
  type = string
}

variable "network_bridge" {
  type = string
}

variable "memory" {
  type = number
}

variable "cpu_count" {
  type = number
}
