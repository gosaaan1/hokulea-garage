## 負荷試験用のRDSを設置する

```
> cd ./rds_stress_test
> aws-vault exec hokulea -- terraform init
> aws-vault exec hokulea -- terraform apply -var="cidr_blocks={RDSへのリモートアクセスを許可するIPアドレス}"
```

## 負荷試験の実施

RDSの負荷試験に [sysbench](https://github.com/akopytov/sysbench) を使います。

キャッシュメモリの空きをなくすためにインデックス付きのカラムをBETWEEN句でWHERE条件に指定したSELECTのみ実行

```
> apt install -y sysbench
> sysbench --db-driver=mysql --mysql-host={RDSのホスト名} --mysql-password=rdsstresstest --tables=1 --table_size=20000000 select_random_ranges prepare
> sysbench --db-driver=mysql --mysql-host={RDSのホスト名} --mysql-password=rdsstresstest --threads=100 --time=120 select_random_ranges run
> sysbench --db-driver=mysql --mysql-host={RDSのホスト名} --mysql-password=rdsstresstest cleanup
```
