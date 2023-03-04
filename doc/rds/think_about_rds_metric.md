# RDSのメトリクスを考える

　公式ドキュメントの「 [メトリクスを使用したパフォーマンスの問題の特定](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html#CHAP_BestPractices.UsingMetrics) 」を読んでも解り難いところが、「しきい値をどのように設定すれば、パフォーマンスが標準レベルを下回っていることを検知できるか？」という点だと思います。

実際にRDSの負荷テストを行う環境を作り、明らかにしてみたいと思います。

## 性能低下の指標

　公式ドキュメントではリソース不足やその他の一般的なボトルネックによるパフォーマンスの問題を特定するために、以下の項目を監視するように書かれています。

- CPU
- RAM
- ディスク容量
- I/O容量
    - Read/Write IOPS
    - Read/Write Latency
    - Read/Write Throughput
    - Queue Depth
- ネットワーク帯域幅
    - Network Receive/Transmit Throughput
- データベース接続

## 性能低下で起こること

では、これらのリソースが不足したときにどのようなことが起こるのか、考えてみましょう。

- CPU
    - クエリの処理時間が長くなるため、スループットが低下する。
    - バースト系インスタンスを使用する場合、CPUクレジット残高が枯渇するとベースラインまでしか性能が出なくなり悪化する。
- RAM
    - クエリの処理に必要なデータをキャッシュが保持できなくなると、ディスクI/Oが増えスループットが低下する。
- I/O容量
    - ディスクアクセスにも「ベースライン」「バースト」という概念がある。
    - バーストバランスが枯渇した状態でI/Oが発生するとデータ転送に時間がかかり、スループットが低下する。
- ネットワーク帯域幅
    - RDSのクライアント（アプリケーションサーバなど）とのデータ授受に時間がかかるため、スループットが低下する。
- データベース接続
    - 1接続ごとにクエリ処理のためのメモリを消費するため、必要以上のデータベース接続はRAMを圧迫しスワップを生じさせる。
    - I/O容量と同様のボトルネックが生じる要因となる。

[クエリのチューニング](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html#CHAP_BestPractices.TuningQueries)にも繋がる話ですが、「大量のリソースを消費するクエリ」がCPU, RAM, I/O容量に大きく影響を及ぼすので、まずはリソースの消費を最小限にするクエリやアプリケーションの実装、またキャッシュに効率よくデータを格納するようテーブル設計を行う必要があることがわかります。

## サービス停止の可能性

　過負荷状態が続いた時、RDSのサービスは停止するのでしょうか？

- OOM Killerによるプロセス終了
    - Linux系OSにはメモリ不足に陥った際、メモリを大量に消費しているプロセスを強制終了する OMM Killer というしくみがあります。
    - RDSもLinux+RDBMSを載せたIaaSと考えると十分に起こりうる可能性があります。
- ディスクフル
    - ストレージの空き容量がゼロになった場合もクエリ処理ができなくなります。
    - 短時間にデータが増大するようなケースにおいては自動拡張のしくみが追いつかず、ディスクフルになる可能性があります。
- ネットワーク/ハードウェア障害
    - インフラストラクチャの異常によるもの。
    - シングルAZの場合はオンプレミス同様起こりうる可能性があります。

RDSの場合OOM Killerやディスクフルよりも、CPUクレジット残高やバーストバランスの方がシビア(枯渇するまで数十分)なので、実際はベースラインを超えられなくなって「ほぼ止まっている」状態になると思います。オンプレミスでは無い概念なので、気づきにくい。インスタンスの再起動で回避できなくはないのですが、根本解決になりませんし、本番環境では再起動自体避けたいところです。


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

## 参考リンク

- [Amazon RDS for MySQL のパラメータ設定 パート 1: パフォーマンス関連のパラメータ](https://aws.amazon.com/jp/blogs/news/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-1-parameters-related-to-performance/)
- [Amazon RDS for MySQL のパラメータ設定 パート 2: レプリケーション関連のパラメータ](https://aws.amazon.com/jp/blogs/news/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-2-parameters-related-to-replication/)
- [Amazon Web Services ブログ Category: RDS for MySQL](https://aws.amazon.com/jp/blogs/news/category/database/amazon-rds/rds-for-mysql/)