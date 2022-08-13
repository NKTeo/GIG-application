# WAFv2 (Web ACL) attached to ALB
resource "aws_wafv2_web_acl" "lb_web_acl" {
    name  = "lb-web-acl"
    scope = "REGIONAL"
    default_action {
        allow {}
    }

    rule { # Limit the number of requests to 500 per second
        name     = "RateLimit"
        priority = 2
        action {
            block {}
        }

        statement {
            rate_based_statement { # Rate limit rule
                aggregate_key_type = "IP"
                limit              = 500 # per 5min period for a single originating IP address
            }
        }

        visibility_config { # Defines and enables Amazon CloudWatch metrics and web request sample collection
            cloudwatch_metrics_enabled = true # Whether the associated resource sends metrics to CloudWatch
            metric_name                = "RateLimit"
            sampled_requests_enabled   = true
        }
    }
    # The Core rule set (CRS) rule group contains rules that are generally applicable to web applications. This provides protection against exploitation of a wide range of vulnerabilities, including some of the high risk and commonly occurring vulnerabilities described in OWASP publications such as OWASP Top 10
    rule { 
        name     = "CoreRuleSet"
        priority = 1

        override_action {
            count {}
        }

        statement {
        managed_rule_group_statement {
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"

                excluded_rule {
                    name = "SizeRestrictions_QUERYSTRING"
                }

                excluded_rule {
                    name = "NoUserAgent_HEADER"
                }
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "CoreRuleSet"
            sampled_requests_enabled   = true
        }
    }


    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "lb-web-acl"
        sampled_requests_enabled   = true
    }
}

resource "aws_wafv2_web_acl_association" "web_acl_association_lb" {
    resource_arn = "${var.alb_arn}"
    web_acl_arn  = aws_wafv2_web_acl.lb_web_acl.arn
}