# AWS Lambda について

## [AWS Lambda特徴](https://aws.amazon.com/jp/lambda/features/?pg=ln&sec=hs)

1. [イベント駆動型](https://docs.aws.amazon.com/lambda/latest/dg/lambda-services.html#intro-core-components-event-sources)のサーバレスコンピューティングサービス
    - クラウドに入ってきたデータやクラウド内を移動するデータの加工に使うことができる。
        - Amazon S3 バケット内のオブジェクト変更。
        - Amazon DynamoDB内のテーブル更新。
        - Amazon Kinesisストリーム。
    - Lambdaを使ったバックエンドサービスの構築ができる。
        - Lambda API
        - Amazon API Gateway
        - AWS Step Functions内の状態遷移
1. 既存のプログラミング言語が使えるので学習コストが低い。
    - Java, Go, PowerShell, Node.js, C#, Python, Rubyをサポート。
    - Lambda Layerを使って、複数のLambda関数でライブラリを共有することができる。
1. 完全に自動化されたインフラストラクチャの管理。
    - セキュリティバッチの適用が不要。
    - Amazon Cloud Watchによる組み込みロギング・モニタリング機能を提供。
1. 耐障害性。
    - 複数のAZ全体でコンピューティング性能を維持することができる。
    - メンテナンスの時間帯や定期的なダウンタイムが発生しない。
1. 関数をコンテナイメージとしてパッケージ化し、デプロイすることができる。
    - [Lambdaコンテナイメージの作成](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html#images-create-sam)
    - [AWS LambdaでPython+Flask環境を作成する](https://ryosh.github.io/posts/20210421/)
    - [aws-wsgi](https://pypi.org/project/aws-wsgi/)
    - [プロキシリソースとのプロキシ統合を設定する](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)
    - [チュートリアル: Lambda 非プロキシ統合を使用して API Gateway REST API をビルドする](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/getting-started-lambda-non-proxy-integration.html)
1. オートスケーリング。
    - リクエスト数に応じて自動でスケールすることができる。
    - リクエスト数に上限はない。
1. Amazon RDS プロキシによるフルマネージド型の接続ブール利用。
    - 数千の同時接続を効率的に管理するので、スケーラブルで安全なアプリケーションを簡単に構築することができる。
    - MySQLとAuroraでサポート。
1. パフォーマンスのきめ細やかな制御。
    - プロビジョニングされた同時実行。（2桁のミリ秒で応答するハイパー対応状態）
    - 同時実行数（スケールアップ、スケールダウン、完全なオフ）の調整が簡単にできる。
1.  共有ファイルシステム。
    - EFS(Amazon Elastic File System)により低レイテンシーのデータ処理が可能。
    - サーバレスインスタンスやコンテナベースのアプリケーション間でファイル共有が可能。
        - 機械学習の推論を実行することができる。
1. Lambda@Edge。
    - Amazon CloudFrontのイベントに応答するコードを実行することができる。
    - エンドユーザーにパーソナライズされたコンテンツを低レイテンシーで配信できる。
1. AWS Step Functionによる複数の関数のオーケストレート。
    - 順次、並列、分岐、エラー処理のステップを使用して、Lambda関数のコレクションをトリガーするワークフローを定義することができる。
    - 複雑なタスクや長時間実行するタスクを構築することができる。
1. 統合型セキュリティモデル。
    - VPC内のリソースへの安全なアクセスが可能。
1. 信頼と完全性の管理。
    - コード署名により、改変されていないコードがデプロイされていることを検証することができる。
    - 大規模なチーム内であっても高いセキュリティ基準を適用することができる。
1.  従量課金制。
    - 実行時間に対して料金を支払う。
1. 柔軟性のあるリソースモデル。
    - 関数に割り当てるメモリ量を選択すると、それに比例したCPUパワー、ネットワーク帯域幅、ディスクI/Oが割り当てられる。
1. AWS Lambdaの拡張機能。
    - AWS Lambda Telemetry API
        - ログ、メトリクス、トレースなど細かな診断情報をLambdaから取得し、任意の宛先に送信することができる。
    - 好みのセキュリティエージェントをLambdaに統合することも可能。

## サーバレスなWebアプリケーションの基本構成

### [ウェブアプリケーションのリファレンスアーキテクチャ](https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/web-application.html)

![Webアプリケーションの基本構成](https://docs.aws.amazon.com/images/wellarchitected/latest/serverless-applications-lens/images/reference-architecture-for-web-application.png)

- サーバレスWebアプリケーションの基本構成
    - Amazon Cognitoはユーザー認証を行ってくれるサービス。アプリケーション側で認証機能を作る必要がないので、開発工数を短縮することができる。Amazon API Gatewayと連携することで、APIの利用回数制限など「ビジネスプランプラン」を構築することができる。

### [デプロイ構成](https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/opex-deploying.html)

![デプロイ構成](https://docs.aws.amazon.com/images/wellarchitected/latest/serverless-applications-lens/images/ci-cd-pipeline-for-multiple-accounts.png)

- API GatewayやAWS Step Functionsなど他のサービスと組み合わせてデプロイすることがほとんどなので、構成管理のためにIaCが必要となる。図ではAWS CloudFormation(IaC)が用いられているが、AWS SAMを使うことで、開発者はインフラをあまり意識せずに開発に集中することができる。
- [AWS SAM](http://aws.amazon.com/serverless/sam/)
    - サーバーレスアプリケーションのパッケージ化、テスト、展開に使用するオープンフレームワーク。
    - AWS サーバレス アプリケーション モデル。CloudFunction(AWS版のIaC)の拡張機能。
    - 参考：[『AWS SAM を使って、Lambda のローカル実行環境を試してみる』](https://qiita.com/sugimount-a/items/ab040661ff12db6a2f6e)
- Terraformで構築したインフラで利用することができきる。
    - [AWS SAM CLI Terraform のサポート](https://docs.aws.amazon.com/ja_jp/serverless-application-model/latest/developerguide/terraform-support.html) ★T.B.D


## メリット・デメリット

### 非サーバレスと比べて…

- マイクロサービス向き。（モノシリックには不向き）
- 可用性が考慮されているので障害に強い。
- OSやミドルウェアのパッチは自動で行われるので、サービスのダウンタイムが発生しない。
- 同時実行数やメモリサイズを簡単に変更できるため、リソースを効率よく利用することができる。
- 使った分（実行時間×リクエスト数）課金されるので、アイドルタイムが多いサービス向き。
- 大量のリクエスト／イベントを処理する場合はランニングコストがEC2より高くなる可能性があるので、試算は必要。
- 実行時間やリソースの制限がEC2よりは厳しい。

- 参考：[Lambda使用のメリット・デメリット](https://www.distant-view.co.jp/column/6518/#)
