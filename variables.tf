variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Short name used as a prefix/tag for all resources"
  type        = string
  default     = "nca"
}

variable "availability_zone" {
  description = "Single AZ used for the environment (per revised single-AZ design)"
  type        = string
  default     = "eu-central-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet (ALB + NAT gateway)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "app_subnet_cidr" {
  description = "CIDR for the app subnet (web servers / ECS tasks)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR for the primary db subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_cidr_b" {
  description = "CIDR for the secondary db subnet (RDS requires 2 subnets in 2 AZs for a subnet group, even in single-AZ deployment)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone_b" {
  description = "Second AZ, used only for the RDS subnet group / ALB requirement"
  type        = string
  default     = "eu-central-1b"
}

variable "container_image" {
  description = "Full container image URI for the web service. The CI/CD pipeline updates this automatically on each app deploy — the default here is only the initial/fallback image."
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "ecs_desired_count" {
  description = "Desired ECS task count at baseline (off-peak)"
  type        = number
  default     = 2
}

variable "ecs_min_capacity" {
  description = "Minimum ECS task count for auto scaling"
  type        = number
  default     = 2
}

variable "ecs_max_capacity" {
  description = "Maximum ECS task count for auto scaling"
  type        = number
  default     = 8
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "ncadb"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "ncaadmin"
}

variable "db_password" {
  description = "Master password for RDS (pass via TF_VAR_db_password or a tfvars file that is gitignored — never commit this)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "alarm_email" {
  description = "Email address for SNS alarm notifications"
  type        = string
}
