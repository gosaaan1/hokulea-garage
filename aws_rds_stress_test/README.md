# aws_rds_stress_test

RDSの負荷テストとCloudWatchメトリクスのアラーム動作を確認するためのインフラ。

## RDS(MySQL)の設置

Terraformで必要なインフラを設置します。

実行には[terraform-mfa](/containers/terraform-mfa) Dockerコンテナが必要になりますので、[/containers/terraform-mfa/README.md](/containers/terraform-mfa/README.md) を参考にセットアップを行ってください。

```
cd ./aws_rds_stress_test
aws-vault exec hokulea -- terraform init
aws-vault exec hokulea -- terraform apply -var="cider_blocks={RDSへのリモートアクセスを許可するIPアドレス}"
```

## 負荷試験の実施

RDSの負荷試験に [sysbench](https://github.com/akopytov/sysbench) を使います。
WindowsではWSL(Windows Subsystem for Linux)が必要になります。

```
apt install -y sysbench
sysbench --db-driver=mysql --mysql-host={RDSのホスト名} --mysql-password=rdsstresstest --tables=1 --table_size=2000000 select_random_ranges prepare
sysbench --db-driver=mysql --mysql-host={RDSのホスト名} --mysql-password=rdsstresstest --threads=100 --time=120 select_random_ranges run
sysbench --db-driver=mysql --mysql-host={RDSのホスト名} --mysql-password=rdsstresstest cleanup
```
