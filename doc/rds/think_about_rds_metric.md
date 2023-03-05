# RDSのしきい値に迷ったら

　『Amazon RDS ベストプラクティス』では、リソース不足やその他一般的なボトルネックによるRDSのパフォーマンス低下を特定するために、メトリクスを使って監視することを推奨しています。
『[メトリクスを使用したパフォーマンスの問題の特定](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html#CHAP_BestPractices.UsingMetrics)』を読んでみたけれど、「パフォーマンスが標準レベルを下回った」と判断するしきい値がわからないなぁ…という方のための判断材料の一つになればと思います。

## ▶サービス監視で重要なのは「停止が起こる予兆や発生をユーザー目線で捉える」こと

『[CloudWatchアラームによるサービス継続のための監視入門(動画10分)](https://youtu.be/o5asjiSwMSs)』をもとに、もう少しアレンジを加えてみます。

- ユーザー目線は環境で変わる。
    - 本番環境／ステージング環境／開発環境
- 環境によって監視すべきものは変わる。
    - 本番環境 ... 利用者から見た（クラウドを含む）サービス全体としての品質の低下・停止を検知することが目的。
    - ステージング環境 ... 本番運用を想定した性能テスト。リリース前にサービス品質低下・停止が起こる可能性がないか確認することが目的。
    - 開発環境 ... アプリケーションのバグによるサービス品質低下・停止が起こる要因を取り除くことが目的。

## ▶ボトルネックを検知するためのメトリクス

公式ドキュメントでは以下の項目を監視するように書かれています。
特に「ベースライン」や「バースト」など、クラウドサービス特有の概念に気づかず、ボトルネックの原因がわからないということもありがちなので、「CPUクレジット残高」や「バーストバランス」もあわせて監視するのが良いと思います。

- CPU
    - 消費量が大きくても問題ないケースがある。（スロークエリーは注意が必要）
    - アプリケーションの目標値（スループット、同時実行数）に沿った想定値であること。
    - 逆に想定外の値であれば、見直しの必要がある。
    - バースト系CPUの場合、CPUクレジット残高が枯渇するとベースライン以上の性能が得られない（バーストできない）現象が起こり、ボトルネックになるので注意が必要。
- RAM
    - CPU同様、アプリケーションの目標値に沿った想定値であれば問題なし。
    - 想定外の値であれば、見直しの必要があるのも同じ。
    - データキャッシュのヒット率低下に伴い、ストレージI/Oが増えボトルネックにつながるので注意が必要。
- ディスク容量
    - 十分な空き容量があれば問題なし。
    - ストレージの自動拡張を設定している場合はディスクフルになる心配はない。
    - 自動拡張にも制限がある（前回の拡張から6時間以内は再拡張不可など）ので、期待通りに自動拡張が行われているかチェックは必要。
- I/O容量 (IOPS, Latency, Throughput, Queue Depth)
    - ストレージI/OにもCPU同様「ベースライン」「バースト」の概念が存在する。
    - ベースライン(3IOPS/GB)を超えたI/Oはバースト可能であるが、バーストバランスが枯渇すると、ベースラインを超えることができなくなり、ボトルネックにつながる。
    - キャッシュのヒット率低下、OSのメモリスワップなどがIOPSを消費する要因になる。
- ネットワーク帯域幅
    - ネットワークの遅延はボトルネックにつながる。
- データベース接続
    - アプリケーション目標値を超える接続はRAMを圧迫する要因となる。
    - I/O容量と同様のボトルネックが生じる要因となる。





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