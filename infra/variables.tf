variable "prefix" {
}
variable "environment" {
}

variable "tags" {
}

variable "location"{

}

variable "ctrlvm_count"{
  default = 2
}

variable "ctrlvm_size"{
}

variable "ctrl_disk_size_gb" {
  default = 32

}

variable "wkr_vm_count" {
  default = 3
  
}

variable "wkr_vm_size"{
}


variable "wkr_disk_size_gb" {
  
}