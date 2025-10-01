# Terraform Module: AWS CodePipeline

이 Terraform 모듈은 AWS CodePipeline을 설정하고, 이를 활용하여 CI/CD 파이프라인을 관리합니다.  
해당 모듈은 소스 코드를 빌드 및 배포하는 데 필요한 단계(stage)와 알림(notification) 리소스를 정의합니다.

## 주요 기능
- AWS CodePipeline 리소스 생성
- 소스(Source), 빌드(Build), 배포(Deploy) 단계 구성
- 다중 소스 프로바이더 지원 (CodeCommit, CodeStarSourceConnection)
- 다중 배포 타입 지원 (ECS, CodeBuild)
- Slack 알림 통합(AWS Chatbot Slack 사용)

## 사용 방법 (Usage)

### CodeCommit + ECS 배포 예제

```hcl
module "code_pipeline" {
  source = "./terraform-aws-code-pipeline"

  pipelines = {
    my-pipeline = {
      provider                     = "CodeCommit"
      branch_name                  = "main"
      repository_name              = "my-repo"
      ecs_service_name             = "my-ecs-service"
      build_project_name           = "my-codebuild-project"
      deploy_type                  = "ECS"
      build_environment_variables  = {
        ENV  = "production"
        KEY2 = "value2"
      }
    }
  }

  pipeline_role_arn            = "arn:aws:iam::123456789012:role/service-role/AWS-CodePipeline-Service"
  pipeline_s3_bucket           = "my-codepipeline-artifacts"
  chatbot_slack_target_arn     = "arn:aws:chatbot::account-id:chat-configuration/slack-channel/my-channel"
  ecs_cluster_name             = "my-ecs-cluster"
  ecs_deployment_file          = "taskdef.json"
  region                       = "us-west-2"
  environment                  = "production"
  common_tags = {
    Project = "example-project"
    Owner   = "team-name"
  }
}
```

### GitHub + CodeBuild 배포 예제

```hcl
module "code_pipeline" {
  source = "./terraform-aws-code-pipeline"

  pipelines = {
    github-pipeline = {
      provider                      = "CodeStarSourceConnection"
      branch_name                   = "main"
      connection_arn                = "arn:aws:codestar-connections:region:account-id:connection/connection-id"
      FullRepositoryId              = "github-org/repository"
      ecs_service_name              = "my-ecs-service"
      build_project_name            = "my-build-project"
      deploy_type                   = "CodeBuild"
      build_environment_variables   = {
        BUILD_ENV = "production"
      }
      deploy_environment_variables  = {
        DEPLOY_ENV = "production"
        TARGET_ENV = "prod"
      }
    }
  }

  pipeline_role_arn            = "arn:aws:iam::123456789012:role/service-role/AWS-CodePipeline-Service"
  pipeline_s3_bucket           = "my-codepipeline-artifacts"
  chatbot_slack_target_arn     = "arn:aws:chatbot::account-id:chat-configuration/slack-channel/my-channel"
  ecs_cluster_name             = "my-ecs-cluster"
  ecs_deployment_file          = "taskdef.json"
  region                       = "us-west-2"
  environment                  = "production"
  common_tags = {
    Project = "example-project"
    Owner   = "team-name"
  }
}
```

## 변수 (Variables)

### 필수 변수

| 변수 이름                    | 타입    | 설명 |
|------------------------------|---------|------|
| `pipelines`                  | map(object) | CodePipeline의 세부 설정 |
| `pipeline_role_arn`          | string  | CodePipeline에서 사용할 IAM 역할 ARN |
| `pipeline_s3_bucket`         | string  | CodePipeline 아티팩트를 저장할 S3 버킷 이름 |
| `chatbot_slack_target_arn`   | string  | Slack 알림을 위한 AWS Chatbot ARN |
| `ecs_cluster_name`           | string  | ECS 클러스터 이름 |
| `ecs_deployment_file`        | string  | ECS 배포에 사용할 Task Definition JSON 파일 |
| `region`                     | string  | 리소스를 생성할 AWS 리전 |
| `environment`                | string  | 환경 이름 (dev, prd 등) |

### 선택적 변수

| 변수 이름        | 타입         | 기본값 | 설명 |
|------------------|--------------|--------|------|
| `connection_arn` | string       | `""`   | CodeStar Connection ARN |
| `common_tags`    | map(string)  | `{}`   | 공통 태그 설정 |

### pipelines 객체 구조

| 속성 이름                      | 타입         | 필수 여부 | 설명 |
|--------------------------------|--------------|-----------|------|
| `provider`                     | string       | 예        | 소스 프로바이더 ("CodeCommit" 또는 "CodeStarSourceConnection") |
| `branch_name`                  | string       | 예        | 브랜치 이름 |
| `ecs_service_name`             | string       | 예        | ECS 서비스 이름 |
| `build_project_name`           | string       | 예        | CodeBuild 프로젝트 이름 |
| `repository_name`              | string       | 선택      | CodeCommit 리포지토리 이름 (CodeCommit 사용 시 필수) |
| `connection_arn`               | string       | 선택      | CodeStar Connection ARN (GitHub/Bitbucket 사용 시 필수) |
| `FullRepositoryId`             | string       | 선택      | 전체 리포지토리 ID (예: "owner/repo") |
| `deploy_type`                  | string       | 선택      | 배포 타입 ("ECS" 또는 "CodeBuild") |
| `build_environment_variables`  | map(string)  | 선택      | 빌드 단계 환경 변수 |
| `deploy_environment_variables` | map(string)  | 선택      | 배포 단계 환경 변수 (CodeBuild 배포 시) |
| `deploy_input_artifacts`       | string       | 선택      | 배포 입력 아티팩트 |

## 출력 값 (Outputs)

| 출력 이름        | 설명 |
|------------------|------|
| `pipeline_names` | 생성된 CodePipeline의 이름 목록 |

## 배포 타입

### ECS 배포
- ECS 서비스에 직접 배포
- `deploy_type = "ECS"` 설정
- `ecs_service_name` 필수

### CodeBuild 배포
- CodeBuild 프로젝트를 통한 배포
- `deploy_type = "CodeBuild"` 설정
- `deploy_environment_variables`로 배포 환경 변수 설정 가능

## 소스 프로바이더

### CodeCommit
```hcl
provider         = "CodeCommit"
repository_name  = "my-repo"
branch_name      = "main"
```

### GitHub/Bitbucket (CodeStarSourceConnection)
```hcl
provider         = "CodeStarSourceConnection"
connection_arn   = "arn:aws:codestar-connections:region:account:connection/connection-id"
FullRepositoryId = "owner/repository"
branch_name      = "main"
```

## 알림 (Notifications)
AWS Chatbot을 사용하여 Slack 채널에 CodePipeline 알림을 전송합니다. 알림 유형:
- 실행 실패 (failed)
- 실행 취소 (canceled)
- 실행 시작 (started)
- 실행 중단 (resumed)
- 실행 성공 (succeeded)
- 실행 대체 (superseded)

## 요구 사항 (Requirements)

- Terraform 버전: `>= 0.13`
- 필요한 프로바이더: `aws` >= `3.0`

## 리소스

이 모듈은 아래의 주요 리소스를 생성합니다:
- `aws_codepipeline` - AWS CodePipeline
- `aws_codestarnotifications_notification_rule` - CodePipeline 알림 규칙
