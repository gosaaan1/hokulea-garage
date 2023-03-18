module "log_metric_alarms" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.0"

  for_each = local.log_metrics

  alarm_name          = each.key
  alarm_description   = each.value.description
  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  evaluation_periods  = each.value.evaluation_periods
  period              = each.value.period
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"  # https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarms-and-missing-data

  namespace          = each.value.namespace
  metric_name        = each.value.metric_name
  statistic          = each.value.statistic
  extended_statistic = each.value.extended_statistic

  tags = local.tags
}

