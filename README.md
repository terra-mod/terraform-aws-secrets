# AWS Secrets

This module creates one or more AWS SecretsManager Secrets and optionally sets values in a new version. The module
accepts a set of secret objects that includes the `name` and optionally a `value`. If a value is specified, a new
secret version is stored with the value given.

You can also create just the secrets and set the values outside of terraform, which has the benefit of keeping secret
values out of your statefile.

This module creates an IAM Policy that grants read access to the generated secrets and has an output to output
the secrets in a format commonly used by ECS Task Definitions, ie `[{ name: "some-secret", valueFrom: "some-arn" }]`.

**Warning**: When passing values to this module, those values will be stored in the terraform state - thus, you should be
sure to take precautions on securing and encrypting that statefile.

##### Usage

        module secrets {
          source = "../../terraform-aws-secrets"
        
          environment      = local.environment
          namespace        = "my-namespace"
          
          prefix_separator = "-"
          force_upper_case = true
        
          secrets = ["mysql_user", "mysql_password"]
        
          values  = {
            mysql_user = "root"
          }
        
          tags = {
            Service = "my-api"
          }
        }