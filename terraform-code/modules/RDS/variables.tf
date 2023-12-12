variable "db_name" {
  default = "main-db"
}

variable "db_size" {
  default = "db.t2.micro"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "zc49OdtssIjcBh18fR4X5"
}

variable "vpc_id" {
  type = string
}

variable "vpc_public_subnet_1_id" {
  type = string
}

variable "vpc_public_subnet_2_id" {
  type = string
}
