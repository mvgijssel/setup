output "fqdn" {
  value = var.name
  description = "The fully qualified domain name of the node"
}

output "id" {
  value = libvirt_domain.node.id
  description = "Id to identify when the module has changed"
}
