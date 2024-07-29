# POLICY CREATION
resource "newrelic_alert_policy" "policy01" {
  name = "policy01"
  incident_preference = "PER_CONDITION" # PER_POLICY is default
}


# CONDITION 
resource "newrelic_nrql_alert_condition" "condition" {
  count = length(var.my-conditions)
  policy_id                      = newrelic_alert_policy.policy01.id
  account_id                     = var.nr_account_id
  name                           = var.my-conditions[count.index].name
  description                    = var.my-conditions[count.index].description
  # runbook_url                    = "https://www.example.com"
  enabled                        = var.my-conditions[count.index].enabled
  violation_time_limit_seconds   = var.my-conditions[count.index].violation_time_limit_seconds
  fill_option                    = var.my-conditions[count.index].fill_option_value
  # fill_value                     = 1.0
  aggregation_window             = var.my-conditions[count.index].aggregation_window
  aggregation_method             = var.my-conditions[count.index].aggregation_method
  aggregation_delay              = var.my-conditions[count.index].aggregation_delay
  expiration_duration            = var.my-conditions[count.index].expiration_duration
  open_violation_on_expiration   = var.my-conditions[count.index].open_violation_on_expiration
  close_violations_on_expiration = var.my-conditions[count.index].close_violations_on_expiration
  slide_by                       = var.my-conditions[count.index].slide_by

  nrql {
    query = var.my-conditions[count.index].query
  }

  critical {
    operator              = "above"
    threshold             = var.my-conditions[count.index].critical_threshold
    threshold_duration    = var.my-conditions[count.index].crt_threshold_duration
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = var.my-conditions[count.index].warning_threshold
    threshold_duration    = var.my-conditions[count.index].war_threshold_duration
    threshold_occurrences = "ALL"
  }
}


#DESTINATION 
resource "newrelic_notification_destination" "destinaiton01" {
  account_id = var.nr_account_id
  name = "destination01"
  type = "EMAIL"

  property {
    key = "email"
    value = var.recipient-email
  }
}


#CHANNEL 
resource "newrelic_notification_channel" "channel01" {
  account_id = var.nr_account_id
  name = "channel01"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.destinaiton01.id
  product = "IINT"

  property {
    key = "subject"
    value = "ALERT!"
  }

  property {
    key = "customDetailsEmail"
    value = "Changes in the Infrastructure"
  }
}

# WORKFLOW 
resource "newrelic_workflow" "workflow01" {
  name = "workflow01"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "filter"
    type = "FILTER"

    predicate {
      attribute = "priority"
      operator = "EXACTLY_MATCHES"
      values = [ "critical" ]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.channel01.id
  }
}

