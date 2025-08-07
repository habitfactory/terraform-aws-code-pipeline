resource "aws_codepipeline" "this" {
  for_each = var.pipelines

  name     = each.key
  role_arn = var.pipeline_role_arn

  artifact_store {
    location = var.pipeline_s3_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = each.value.provider
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      namespace        = "SourceVariables"

      # CodeCommit일 때만 namespace, OutputArtifactFormat 설정 추가
      #namespace = each.value.provider == "CodeCommit" ? "SourceVariables" : null

      configuration = {
        # 공통 속성 (CodeCommit / CodeStarSourceConnection 둘 다 포함)
        BranchName           = each.value.branch_name
        OutputArtifactFormat = "CODE_ZIP"

        # CodeCommit 전용 속성
        RepositoryName       = each.value.provider == "CodeCommit" ? each.value.repository_name : null
        PollForSourceChanges = each.value.provider == "CodeCommit" ? "false" : null

        # CodeStarSourceConnection 전용 속성
        ConnectionArn    = each.value.provider == "CodeStarSourceConnection" ? each.value.provider : null
        ConnectionArn    = each.value.provider == "CodeStarSourceConnection" ? each.value.connection_arn : null
        FullRepositoryId = each.value.provider == "CodeStarSourceConnection" ? each.value.FullRepositoryId : null
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = var.build_project_name
        EnvironmentVariables = jsonencode([
          for k, v in each.value.environment_variables : {
            name  = k
            type  = "PLAINTEXT"
            value = v
          }
        ])
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name      = "Deploy"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "ECS"
      version   = "1"
      namespace = "DeployVariables"
      input_artifacts = ["BuildArtifact"]
      run_order = 1
      configuration = {
        ClusterName       = var.ecs_cluster_name
        ServiceName       = each.value.ecs_service_name
        DeploymentTimeout = "10"
      }
      region          = var.region
    }
  }
}