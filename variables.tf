variable environment {
  description = "The environment the Secrets are used in."
  type        = string
  default     = ""
}

variable namespace {
  description = "A namespace that the secrets are stored under - this could be the name of a service, for example."
  type        = string
}

variable prefix_namespace {
  description = "Whether secret names should be prefixed with the given namespace. ie, `{namespace}_{secret_name}`."
  type        = bool
  default     = true
}

variable prefix_separator {
  description = "When the namespace is prefixed, this is the separator between the namespace and the secret name. Defaults to `-`"
  type        = string
  default     = "-"
}

variable force_upper_case {
  description = "Force the secret names in outputs to be in uppercase. This is useful when the outputs are used as environment variables."
  type        = bool
  default     = false
}

variable secrets {
  description = <<EOF
A set of secrets. This is just the names of the secrets and does not include values.  This allows you to create the secrets, but keep the
values out of your statefile. Optionally, you can provide values for secrets below.
EOF
  type        = set(string)
}

variable values {
  description = <<EOF
Values to set for secrets. Requires a map where the key is the secret name present in the `secrets` set above.

*Warning*: these values will be stored in your Terraform statefile - you must encrypt and secure your statefile accordingly."
EOF
  type        = map(string)
  default     = {}
}

variable tags {
  description = "Any additional tags that should be added to taggable resources created by this module."
  type        = map(string)
  default     = {}
}
