# Terraform Module: AWS CodePipeline

이 Terraform 모듈은 AWS CodePipeline을 설정하고, 이를 활용하여 CI/CD 파이프라인을 관리합니다.  
해당 모듈은 소스 코드를 빌드 및 배포하는 데 필요한 단계(stage)와 알림(notification) 리소스를 정의합니다.

## 주요 기능
- AWS CodePipeline 리소스 생성
- 소스(Source), 빌드(Build), 배포(Deploy) 단계 구성
- Slack 알림 통합(AWS Chatbot Slack 사용)
- ECS를 활용한 배포 통합

## 사용 방법 (Usage)

아래는 이 모듈을 사용하는 간단한 예제입니다:

```hcl
module "code_pipeline" {
  source  = "app.terraform.io/habitfactory/code-pipeline/aws"
  version = "1.0.0"

  pipelines = {
    my-pipeline = {
      provider           = "CodeCommit"
      branch_name        = "main"
      repository_name    = "my-repo"
      ecs_service_name   = "my-ecs-service"
      connection_arn     = "arn:aws:codestar-connections:region:account-id:connection/connection-id"
      FullRepositoryId   = "github-org/repository"
      environment_variables = {
        ENV  = "production"
        KEY2 = "value2"
      }
    }
  }

  pipeline_role_arn    = "arn:aws:iam::123456789012:role/service-role/AWS-CodePipeline-Service"
  pipeline_s3_bucket   = "my-codepipeline-artifacts"
  build_project_name   = "my-codebuild-project"
  chatbot_slack_target_arn = "arn:aws:chatbot:region:account-id:chat-configuration/my-slack-channel"
  ecs_cluster_name     = "my-ecs-cluster"
  ecs_deployment_file  = "taskdef.json"
  region               = "us-west-2"
  environment          = "production"
  common_tags          = {
    Project = "example-project"
    Owner   = "team-name"
  }
}
```

## 변수 (Variables)

| 변수 이름                  | 타입    | 기본 값 | 필수 여부 | 설명 |
|----------------------------|---------|---------|-----------|------|
| `pipelines`                | map     | `n/a`   | 예        | CodePipeline의 세부 설정 (소스, 빌드, 배포 정보 포함) |
| `pipeline_role_arn`        | string  | `n/a`   | 예        | CodePipeline에서 사용할 IAM 역할 ARN |
| `pipeline_s3_bucket`       | string  | `n/a`   | 예        | CodePipeline 아티팩트를 저장할 S3 버킷 이름 |
| `chatbot_slack_target_arn` | string  | `n/a`   | 예        | Slack 알림을 위한 AWS Chatbot ARN |
| `build_project_name`       | string  | `n/a`   | 예        | 빌드 단계에서 참조할 CodeBuild 프로젝트 이름 |
| `ecs_cluster_name`         | string  | `n/a`   | 예        | ECS 클러스터 이름 |
| `ecs_deployment_file`      | string  | `n/a`   | 예        | ECS 배포에 사용할 Task Definition JSON 파일 |
| `region`                   | string  | `"us-east-1"` | 아니오 | 리소스를 생성할 AWS 리전 |
| `common_tags`              | map(string) | `{}`    | 아니오     | 공통 태그 설정 (예: `Project`, `Environment` 등) |

## 출력 값 (Outputs)

| 출력 이름       | 설명 |
|-----------------|------|
| `pipeline_arns` | 생성된 CodePipeline의 ARN 목록 |
| `notification_arns` | 생성된 알림(Notification)의 ARN 목록 |

## 요구 사항 (Requirements)

- Terraform 버전: `>= 0.13`
- 필요한 프로바이더:
  - `aws` >= `3.0`

## 리소스

이 모듈은 아래의 주요 리소스를 생성합니다:
- `aws_codepipeline` (AWS CodePipeline)
- `aws_codestarnotifications_notification_rule` (CodePipeline Notification Rule)

## 알림 (Notifications)
AWS Chatbot을 사용하여 Slack 채널에 CodePipeline 알림을 전송합니다. 알림 유형은 아래와 같습니다:
- 실행 실패(failed)
- 실행 취소(canceled)
- 실행 시작(started)
- 실행 중단(resumed)
- 실행 성공(succeeded)
