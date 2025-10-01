variable "pipelines" {
  type = map(object({
    provider               = string
    ecs_service_name       = string
    deploy_input_artifacts = optional(string)
    repository_name        = optional(string) # CodeStarSourceConnection의 경우 필요 없음
    connection_arn         = optional(string) # CodeStarSourceConnection만 필요
    FullRepositoryId       = optional(string) # CodeStarSourceConnection만 필요
    branch_name            = string
    build_environment_variables  = map(string)
    deploy_environment_variables  = map(string)
    build_project_name     = string
    deploy_type            = optional(string)
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

variable "ecs_deployment_file" {
  description = "The deployment file used for ECS"
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

/*variable "build_project_name" {
  description = "build project name"
  type        = string
}*/

variable "chatbot_slack_target_arn" {
  description = "AWS Chatbot Slack Target ARN"
  type        = string
  #default     = "arn:aws:chatbot::524664341443:chat-configuration/slack-channel/devops-signalflow"
}
#추가변수
variable "environment" {
  description = "Environment name (dev, prd, etc.)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}