###############################
# Network firewall rule group #
###############################
resource "aws_networkfirewall_rule_group" "allowed_domain" {
  capacity = 100
  name     = "domains-allowed"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".amazonaws.com", ".google.com", ".ubuntu.com", ".sonatype.com", ".nodejs.org", ".golang.org", ".github.com", "updates.jenkins.io", "pkg.jenkins.io", ".fedoraproject.org", ".datadoghq.com", ".clamav.net", ".nodesource.com", "repo.maven.apache.org", "pypi.org", "ppa.launchpad.net", "fonts.googleapis.com", "pypi.python.org", "npmjs.com", "registry.npmjs.org", "files.pythonhosted.org"]
      }
    }
  }
}

###########################
# Network firewall policy #
###########################
resource "aws_networkfirewall_firewall_policy" "fw_policy" {
  name = "${var.environment}-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allowed_domain.arn
    }
  }
}

####################
# Network firewall #
####################
resource "aws_networkfirewall_firewall" "aws_firewall" {
  firewall_policy_arn = aws_networkfirewall_firewall_policy.fw_policy.arn
  name                = "${var.environment}-firewall"
  vpc_id              = aws_vpc.aws_clean_room_vpc.id
  subnet_mapping {
    subnet_id = aws_subnet.firewall_subnet.id
  }
}