locals {
  name = "hokulea"
  tags = {
    Name = "Hokulea"
    Bill = "RDSStressTest"
  }

  vpc_cidr = "10.0.0.0/16"

  mysql_parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "slow_query_log"
      value = "1"
    },
    {
      name  = "long_query_time"
      value = "10"
    },
    {
      name  = "log_output"
      value = "FILE"
    },
  ]

  log_metrics = {
    "RDS-スロークエリー" = {
      description         = "スロークエリー"
      comparison_operator = "GreaterThanThreshold"
      threshold           = "0"
      evaluation_periods  = "1"
      period              = "60"
      namespace           = "${local.name}/LogMetrics"
      metric_name         = "SlowQueries"
      statistic           = "Sum"
      extended_statistic  = null
    }
  }

  # see about best practice => https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
  # see about metrics => https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/rds-metrics.html
  metrics = {
    # "RDS-CPU使用率" = {
    #   description         = "CPU使用率"
    #   comparison_operator = "GreaterThanThreshold"
    #   threshold           = null
    #   evaluation_periods  = "1"
    #   period              = "60"
    #   namespace           = "AWS/RDS"
    #   metric_name         = "CPUUtilization"
    #   statistic           = "Average"
    #   extended_statistic  = null
    # }
    "RDS-CPUクレジット残高" = {
      description         = "CPUクレジット残高"
      comparison_operator = "LessThanThreshold"
      threshold           = "50"
      evaluation_periods  = "1"
      period              = "60"
      namespace           = "AWS/RDS"
      metric_name         = "CPUCreditBalance"
      statistic           = "Minimum"
      extended_statistic  = null
    }
    # NOTE extendes_static の バイト数は (RDSインスタンスの物理メモリサイズ/4) の値を設定してください。
    "RDS-空きメモリ" = {
      description         = "空きメモリ"
      comparison_operator = "GreaterThanThreshold"
      threshold           = "90" # 1分間に100MBを下回る状態が90%を超える
      evaluation_periods  = "1"
      period              = "60"
      namespace           = "AWS/RDS"
      metric_name         = "FreeableMemory"
      statistic           = null
      extended_statistic  = "PR(:100000000)" # 100MBを下回る割合を求める
    }
    # NOTE ストレージの自動スケーリングを有効にしているときは下記を参考にしきい値を検討します。
    # https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html#USER_PIOPS.Autoscaling
    "RDS-空きストレージ" = {
      description         = "空きストレージ"
      comparison_operator = "LessThanThreshold"
      threshold           = "2000000000"
      evaluation_periods  = "1"
      period              = "300"
      namespace           = "AWS/RDS"
      metric_name         = "FreeStorageSpace"
      statistic           = "Minimum"
      extended_statistic  = null
    }
    # IOPS メトリクスの想定値はディスクの仕様とサーバーの設定によって異なるため、ベースラインを使用して一般的な値を把握します。
    # 値とベースラインとの差が一貫しているかどうかを調べます。
    #  => https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_Storage.html#Concepts.Storage.GeneralSSD
    # 最適な IOPS パフォーマンスを得るには、読み取りおよび書き込みオペレーションが最小限になるように、一般的な作業セットがメモリに収まることを確認してください。
    # "RDS-ReadIOPS" = {
    #   description         = "Read IOPS"
    #   comparison_operator = "GreaterThanThreshold"
    #   threshold           = null
    #   evaluation_periods  = "1"
    #   period              = "60"
    #   namespace           = "AWS/RDS"
    #   metric_name         = "ReadIOPS"
    #   statistic           = "Average"
    #   extended_statistic  = null
    # }
    # "RDS-WriteIOPS" = {
    #   description         = "Write IOPS"
    #   comparison_operator = "GreaterThanThreshold"
    #   threshold           = null
    #   evaluation_periods  = "1"
    #   period              = "60"
    #   namespace           = "AWS/RDS"
    #   metric_name         = "WriteIOPS"
    #   statistic           = "Average"
    #   extended_statistic  = null
    # }
    "RDS-バーストバランス" = {
      description         = "Burst balance"
      comparison_operator = "LessThanThreshold"
      threshold           = "50"
      evaluation_periods  = "1"
      period              = "60"
      namespace           = "AWS/RDS"
      metric_name         = "BurstBalance"
      statistic           = "Minimum"
      extended_statistic  = null
    }
    # 読み書き遅延
    # "RDS-ReadLatency" = {
    #   description         = "RDS Read latency"
    #   comparison_operator = "GreaterThanThreshold"
    #   threshold           = null
    #   evaluation_periods  = "1"
    #   period              = "60"
    #   namespace           = "AWS/RDS"
    #   metric_name         = "ReadLatency"
    #   statistic           = "Average"
    #   extended_statistic  = null
    # }
    # "RDS-WriteLatency" = {
    #   description         = "RDS Write latency"
    #   comparison_operator = "GreaterThanThreshold"
    #   threshold           = null
    #   evaluation_periods  = "1"
    #   period              = "60"
    #   namespace           = "AWS/RDS"
    #   metric_name         = "WriteLatency"
    #   statistic           = "Average"
    #   extended_statistic  = null
    # }

    # ユーザー接続数が多いことが、インスタンスのパフォーマンスが下がっていること、応答時間が長くなっていることに関連しているとわかった場合、
    # データベース接続数を制限することを検討します。
    # NOTE データベース最大接続数（想定されるワークロードでの接続数）をしきい値に設定します。
    "RDS-データベース接続数" = {
      description         = "データベース接続数"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = "50"
      evaluation_periods  = "1"
      period              = "60"
      namespace           = "AWS/RDS"
      metric_name         = "DatabaseConnections"
      statistic           = "Maximum"
      extended_statistic  = null
    }
  }
}