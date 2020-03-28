resource "aws_ssm_parameter" "rails_master_key" {
  name  = "agent-network.${var.app_environment}.rails_master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}
