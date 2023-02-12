/**
 * Requires Terraform >= 0.12
 */
terraform {
  required_version = ">= 0.12"
}

locals {
  key_prefix = var.prefix_namespace ? "${var.namespace}${var.prefix_separator}" : ""

  tags = merge({
    Environment = var.environment
    Namespace   = var.namespace
    ManagedBy   = "terraform"
  }, var.tags)
}

/**
 * Generate a CMK KMS Key to encrypt the Secrets.
 */
resource aws_kms_key key {
  description         = "Key for encrypting ${var.namespace} secrets."
  enable_key_rotation = true

  tags = local.tags
}

/**
 * Generate an Alias for the Key above.
 */
resource aws_kms_alias alias {
  name          = "alias/${var.namespace}-secrets-key"
  target_key_id = aws_kms_key.key.key_id

  depends_on = [aws_kms_key.key]
}

/**
 * Create the Secrets from the set. If the namespace is being prefixed the secret name will be in the
 * format of: NAMESPACE_SECRETNAME
 */
resource aws_secretsmanager_secret secret {
  for_each = var.secrets

  name       = join("", [local.key_prefix, each.value])
  kms_key_id = aws_kms_key.key.key_id

  recovery_window_in_days = var.recovery_window

  tags = local.tags
}

/**
 * For secrets with values provided, create a version.
 */
resource aws_secretsmanager_secret_version value {
  for_each = var.values

  secret_id = aws_secretsmanager_secret.secret[each.key].id

  secret_string = each.value
}

/**
 * Create an IAM policy that grants read access to the secrets (nd can decrypt the KMS key.
 */
resource aws_iam_policy policy {
  name        = "${var.namespace}-secrets-reader"
  path        = "/secrets/${var.namespace}/"
  description = "Allows read access to secrets for ${var.namespace}."

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["kms:Decrypt"],
      "Resource": "${aws_kms_key.key.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:List*",
        "secretsmanager:Get*",
        "secretsmanager:Describe*"
      ],
      "Resource": ${jsonencode(coalescelist(values(aws_secretsmanager_secret.secret)[*].arn, []))}
    }
  ]
}
POLICY
}
