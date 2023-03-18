# NOTE https://qiita.com/satofujino/items/a7350aefc3cdde563592
# NOTE 不要になったカスタムメトリクスは手動削除できない。 15か月後に自動的に有効期限切れになる => https://dev.classmethod.jp/articles/tsnote-support-cloudwatch-delete-metrics-launch-001/
module "rds_slowquery_metric_filter" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 4.0"

  log_group_name                      = "/aws/rds/instance/${local.name}/slowquery"
  metric_transformation_name          = "SlowQueries"
  metric_transformation_namespace     = "${local.name}/LogMetrics"
  metric_transformation_default_value = "0"
  metric_transformation_value         = "1"
  metric_transformation_unit          = "Count"
  name                                = "SlowQuery"
  pattern                             = "Query_time"
}
