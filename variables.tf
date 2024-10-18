variable "vcd_user" {}
variable "vcd_pass" {}
variable "vcd_org" {}
variable "vcd_vdc" {}
variable "vcd_url" {}

variable "vcd_max_retry_timeout" {
  default = 60
}

variable "vcd_allow_unverified_ssl" {}

variable "vcd_catalog_name" {
  type = string
}

variable "vcd_catalog_id" {
  type = string
}

variable "vapp_template_name" {
  type = string
}

variable "vapp_template_id" {
  type = string
}

variable "network_name" {
  type = string
}