# terraform-mfa

AWSの多段階認証に対応したTerraformの実行環境を提供するコンテナです。

## Terraformを使ってみよう

### AWS側に必要な設定

AWS側に管理者権限を持つ terraform ユーザーを作成します。
Terraformはこのユーザーを使ってクラウドサービスの構築／廃棄を行います。

1. ルートなど、管理者権限のあるアカウントでAWS管理コンソールにログインし、IAMを開きます。
1. ユーザー`terraform`を作成します。
    * このユーザーでAWS管理コンソールで操作できないよう「AWS 認証情報タイプを選択」の「アクセスキー - プログラムによるアクセス」をチェックを入れておきます。
1. ユーザー`terraform`のアクセス権限に`AdministratorAccess`を割り当てます。
1. アクセスキーを発行します。
1. 多段階認証を利用するために、MFAデバイスの割り当てを行います。

### クライアント側に必要な設定

1. VSCodeを開き、新しいプロジェクト（フォルダー）を開きます。
1. プロジェクトルートに `.devcontainer.json` ファイルを以下の内容で作成します。
    ```
    {
        "image": "public.ecr.aws/l2m0t2f1/terraform-mfa:1.2",
        # 次の1行を記述すると、アクセスキーやシークレットキーはDockerの名前付きボリューム "terraform_credentials" に保存されます。
        # 認証情報を複数のコンテナで共有したいときはこの行を追加します
        "mounts": ["source=terraform_credentials,target=/root"],
        "extensions": [
            "eamodio.gitlens",
            "hashicorp.terraform"
        ]
    }
    ```
1. VSCodeのコマンドパレットから、`Remote-Containers: Open Folder in Container...` を実行し、`.devcontainer.json`が保存されているフォルダーを開きます。
1. VSCodeでターミナルを開き、以下のコマンドを順に実行します。
    * `gpg --gen-key`を実行し鍵を生成します。より強力な暗号化を使用する場合は `gpg --full-generate-key`を実行します。
    * `pass init {gpgコマンドで入力したメールアドレス}` を実行し、パスワードストアを初期化します。
    * `aws-vault add {プロファイル名}` を実行し、AWSのアクセスキーとシークレットキーを入力します。
    * `~/.aws/config`ファイルを以下の内容で作成します。
        ```
        [default]
        region=ap-northeast-1
        output=json

        [profile {プロファイル名}]
        mfa_serial=arn:aws:iam::{AWSのアカウントID}:mfa/terraform
        ```
    * `aws-vault exec {プロファイル名} --no-session -- env | grep AWS_`を実行し、AWSアクセスキーとシークレットキーが正しく設定されていることを確認します。
    * `aws-vault exec {プロファイル名} -- terraform init`を実行します。
    * `pass` を実行し、以下のような出力が得られることを確認します。     
        ```
        Password Store
        |-- {プロファイル名}
        `-- sts.GetSessionToken,ZGV2b3Bz,,1644128599
        ```
