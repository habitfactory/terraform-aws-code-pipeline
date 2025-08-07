output "pipeline_names" {
  value = [for pipeline in aws_codepipeline.this : pipeline.name]
}