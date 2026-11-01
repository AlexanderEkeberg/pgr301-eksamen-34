variable "region" {
  description = "Regionen ressursene lages i"
  type        = string
  default     = "eu-west-1"
}

variable "candidate_number" {
  description = "Kandidatnummeret mitt, brukes i navn på ressurser"
  type        = string
  default     = "34"
}

variable "image" {
  description = "Imaget fra ECR som skal kjøres, med commit-SHA som tag"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}\\.dkr\\.ecr\\.[a-z0-9-]+\\.amazonaws\\.com/[a-z0-9][a-z0-9._/-]*:[A-Za-z0-9._-]+$", var.image))
    error_message = "image må være en ECR-adresse med tag, f.eks. <konto>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>"
  }
}