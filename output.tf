output secrets {
  description = "A hash map of secret Keys with their ARN."
  value       = { for k, v in aws_secretsmanager_secret.secret : k => v.arn }
}

output container_defintion_secrets {
  description = <<EOF
An list of Secret objects that can be passed directly to the `secrets` property of a a ContainerDefintion resource. Similar
to the output above, but matches the required value if this is being passed directly to a container definition.
EOF
  value       = [ for k, v in aws_secretsmanager_secret.secret : { name = var.force_upper_case ? upper(k) : k, valueFrom = v.arn } ]
}

output kms_key_id {
  description = "The Id of the KMS Key used to encrypt the secrets."
  value       = aws_kms_key.key.key_id
}

output kms_key_arn {
  description = "ARN of the KMS Key."
  value       = aws_kms_key.key.arn
}

output kms_alias {
  description = "Alias for the KMS Key."
  value       = aws_kms_alias.alias.name
}

output iam_policy_arn {
  description = "IAM Policy that allows read access to the secrets."
  value       = aws_iam_policy.policy.arn
}
