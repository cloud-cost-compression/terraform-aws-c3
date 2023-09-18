# --- variables.tf ---

## Network ##

variable "vpc_cidr" {
  description = "CIDR of C3 VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "region" {
  description = "AWS region"
  type        = string
}


## C3 Controller ##

variable "controller_instance_name" {
  description = "The Instance Name to use for C3 EC2 Controller Node"
  default     = "c3-ec2-controller"
  type        = string
}
variable "controller_instance_type" {
  description = "The Instance Type to use for C3 Controller Node"
  default     = "t3.small"

  type = string
}

## EKS cluster ##

variable "eks_cluster_version" {
  description = "Version of the EKS cluster"
  default     = "1.27"
  type        = string
}
variable "eks_cluster_min_size" {
  description = "Minimum number of worker nodes running in the EKS cluster"
  default     = 1
  type        = string
}
variable "eks_cluster_max_size" {
  description = "Maximum number of worker nodes running in the EKS cluster"
  default     = 3
  type        = string
}
variable "eks_cluster_desired_size" {
  description = "Desired number of worker nodes running in the EKS cluster"
  default     = 1
  type        = string
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  default     = "c3-eks-cluster"
  type        = string
}
variable "eks_cluster_instance_type" {
  description = "Instance type of the EKS cluster"
  default     = "t3.small"
  type        = string
}
variable "cluster_logs_types" {
  description = "List of enabled logs - supported types: api, audit, authenticator"
  default = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  type = list(string)
}
variable "cluster_logs_retention" {
  description = "Retention of EKS cluster logs (in days)"
  default     = 7
  type        = number
}

### Add more buckets list
variable "s3_data_read_bucket_name" {
  description = "ARN of S3 bucket for data read processing"
  type        = string
}
variable "s3_data_write_bucket_name" {
  description = "ARN of S3 bucket for data write processing"
  type        = string
}

## EVL ##

variable "evl_app_version" {
  description = "Version of the C3 EVL application"
  type        = string
}

variable "evl_s3_bucket_name" {
  description = "S3 bucket name where EVL dependencies are stored"
  type        = string
}
