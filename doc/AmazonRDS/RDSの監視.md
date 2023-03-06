# RDSの監視

Amazon RDSの運用監視を行う上で必要となるメトリクス（評価項目）としきい値の設定方法についてまとめています。 

## 前提知識

- [Amazon RDS ベストプラクティス](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [CloudWatchアラームによるサービス継続のための監視入門(動画10分)](https://youtu.be/o5asjiSwMSs)

## 調査のきっかけ

　「Amazon RDS ベストプラクティス」では、リソース不足やその他一般的なボトルネックによるRDSのパフォーマンス低下を特定するために、メトリクス(Amazon Cloud Watch)を使って監視することを推奨しています。ここで少し引っ掛かるのが「パフォーマンス低下」という表現。
[メトリクスを使用したパフォーマンスの問題の特定](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html#CHAP_BestPractices.UsingMetrics) には「パフォーマンスが標準レベルを下回った」とあるのですが、具体的にはどのような状態を指すのだろうと思ったのが発端でした。

## ポイントは「停止が起こる予兆や発生をユーザー目線で捉える」こと

「CloudWatchアラームによるサービス継続のための監視入門」の動画では「停止が起こる前兆や発生をユーザー目線で捉えること」が重要であると紹介しています。
例えば「CPU利用率がX%を超えたら」や「RAMの空き容量がYMBを切ったら」がサービス停止に即つながるとは限りません。
アラートが「オオカミ少年」になってしまうと、本当の問題に気づけなくなってしまいます。

### メトリクスから見えてくること

「Amazon RDS ベストプラクティス」では以下の項目をメトリクスにすることを推奨しています。
各メトリクスからどんな課題が見えてくるのでしょうか？

- CPU利用率
    - アプリケーションの目標値（スループット、同時実行数）に沿った想定値に収まっていることが重要。
    - 利用率が低すぎる場合はインスタンスクラスの引き下げ、高すぎる場合はスロークエリのチューニングや処理方式の見直しを行い、それでも改善しない場合はインスタンスクラスの引き上げを検討する。
    - バースト系インスタンスの場合、CPUクレジット残高が枯渇するとベースライン以上の性能が出せなくなり（バーストできない）、スループット低下が起こる。
- RAM空き容量
    - RAM（キャッシュ）が効率よく使えていることが重要。ヒット率低下はスループット低下につながる。
    - 頻繁にメモリ不足が発生する場合は、処理対象のデータがキャッシュに収まっていない可能性を考える。
    - キャッシュのヒット率に関連するメトリクスは用意されていないので、別途自作する必要がある。
- ストレージ空き容量
    - 空き容量の枯渇はサービス停止につながる。
    - 自動拡張のオプションを有効にしている場合でも、制約（前回の拡張から6時間以内は再拡張不可）があるので、期待通りに自動拡張が行われているかチェックは必要。
- I/O容量 (IOPS, Latency, Throughput, Queue Depth)
    - ストレージI/OにもCPU同様「ベースライン」「バースト」の概念が存在する。
    - ベースライン(3IOPS/GB)を超えたI/Oはバースト可能であるが、バーストバランスが枯渇すると、ベースラインを超えることができなくなり、スループット低下が起こる。
    - キャッシュのヒット率低下、OSのメモリスワップがIOPSを消費する原因になる。
    - ストレージ障害によるスループット低下、サービス停止も考慮する必要がある。
- ネットワーク帯域幅
    - ネットワークの遅延はスループット低下につながる。
- データベース接続
    - アプリケーション目標値を超える接続はCPUやRAMに負荷がかかり、スループットが低下する。

### ユーザー目線はいろいろ

ユーザーと言っても登場するアクターはさまざま。それぞれが求める「目線」とは？

- サービスの利用者。見えるのはコール＆レスポンスだけなので、いつもより反応が遅いだけで「異常が起きている」と感じる。
- サポートデスク。利用者が「異常が起きている」と感じていること。その原因を早期に知りたい。問い合わせがあった時に即答できるようにしておきたい。
- システム運用管理者。異常が起こる兆候を知りたい。異常なのか正常なのかを知りたい。何か起きそう／起きているならサポートデスクに連携しておきたい。
- 開発者。アプリケーションの不具合が起こっていないか。ボトルネックにつながるようなクエリを書いていないか。

## メトリクスの設計

上記をふまえ、メトリクスをどう設計すればよいか考えてみましょう。


----

## クエリのチューニング／テーブル設計の重要性

　[クエリのチューニング](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_BeskitPractices.html#CHAP_BestPractices.TuningQueries)に書かれているように、「大量のリソースを消費するクエリ」がCPU, RAM, I/O容量に大きく影響を及ぼします。
もちろんインスタンスクラスを上げることでカバーすることは可能ですが、その分運用コストは上がります。
リソースの消費を最小限にするクエリやアプリケーションの実装、またキャッシュに効率よくデータを格納するためのテーブル設計は重要です。

## DBパラメータ



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