
resource "aws_kms_key" "artifacts" {
  count       = var.create_cmk ? 1 : 0
  description = "kms key for artifacts for ${local.name_suffix}"
  policy      = data.aws_iam_policy_document.artifacts_kms_policy.json
}

resource "aws_kms_alias" "artifacts" {
  count         = var.create_cmk ? 1 : 0
  target_key_id = aws_kms_key.artifacts[count.index].key_id
}