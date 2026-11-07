variable "region" {
  description = "Region de AWS del laboratorio"
  type        = string
  default     = "us-east-1"
}

variable "nombre" {
  description = "Prefijo para nombrar los recursos"
  type        = string
  default     = "lab-devops"
}
