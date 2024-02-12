# codebuildモジュール

CodeCommitの指定したブランチからソースを取得し、Dockerイメージを作成し、ECRに格納するCodeBuildをAWSに設置します。

## 補足

* CodeCommit（ソースリポジトリ）とECR（コンテナリポジトリ）をあらかじめ作成しておく必要があります。
* `terraform apply`後はCodePipelineを設定して、ソースリポジトリにプッシュされる度にCodeBuildを実行するように設定します。

## 使い方

CodeCommitの`alpha`リポジトリの`beta`ブランチにある`gamma.yml`というbuildspecファイルをもとに`delta`というコンテナをビルドします。

* main.tf
    
  ```
  module "codebuild" {
    source = "./codebuild"
    repositories = {
      delta = {
        repository_name = "alpha"
        source_version  = "beta"
        buildspec       = "./gamma.yml"
      }
    }
  }
  ```

### パラメータ

* repositories (map): CodeBuildを作成するプロジェクト一覧。
    * キー名 (string): コンテナ名。
    * repository_name (string): ソースリポジトリ名。
    * source_version (string): ビルドに使用するソースリポジトリのブランチ。
    * buildspec (string): ビルドに使用するbuildspecファイル。通常は`buildspec.yml`を指定します。

### 戻り値

* なし。

----

## buildspecファイルのサンプル

`delta:1.0.0`のDockerイメージをビルドします。

* buildspec.yml
    
  ```
  version: 0.2

  env:
    variables:
      # AWS_DEFALUT_REGION と AWS_ACCOUNT_IDはCodeBuild側で設定済み
      IMAGE_NAME: "delta"
      VERSION: "1.0.0"
  phases:
    build:
      commands:
        - cd ./app
        - docker build -t $IMAGE_NAME:$VERSION .
    post_build:
      commands:
        # [ECRの「プッシュコマンドの表示」](https://ap-northeast-1.console.aws.amazon.com/ecr/repositories?region=ap-northeast-1)を参考に設定してください。
        # プライベートリポジトリを使う場合
        - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
        - docker tag $IMAGE_NAME:$VERSION $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_NAME:$VERSION
        - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_NAME:$VERSION
  ```