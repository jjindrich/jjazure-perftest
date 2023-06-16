resource "tls_private_key" "ssh_key_generic_vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
