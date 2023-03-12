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



## 参考リンク

- [Amazon RDS for MySQL のパラメータ設定 パート 1: パフォーマンス関連のパラメータ](https://aws.amazon.com/jp/blogs/news/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-1-parameters-related-to-performance/)
- [Amazon RDS for MySQL のパラメータ設定 パート 2: レプリケーション関連のパラメータ](https://aws.amazon.com/jp/blogs/news/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-2-parameters-related-to-replication/)
- [Amazon Web