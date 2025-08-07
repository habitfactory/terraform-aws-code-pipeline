variable "pipelines" {
  type = map(object({
    provider              = string
    ecs_service_name      = string
    deploy_input_artifacts = optional(string)
    repository_name       = optional(string) # CodeStarSourceConnection의 경우 필요 없음
    connection_arn        = optional(string) # CodeStarSourceConnection만 필요
    FullRepositoryId      = optional(string) # CodeStarSourceConnection만 필요
    branch_name           = string
    environment_variables = map(string)
  }))
}

variable "pipeline_role_arn" {
  description = "The IAM role ARN for CodePipeline"
  type        = string
}

variable "pipeline_s3_bucket" {
  description = "S3 bucket for storing pipeline artifacts"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "connection_arn" {
  description = "name of connection arn"
  type        = string
  default     = ""
}

variable "region" {
  description = "name of region"
  type        = string
}

variable "build_project_name" {
  description = "build project name"
  type        = string
}
