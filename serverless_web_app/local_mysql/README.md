# local_mysql

Lambda関数のデバッグで使えるローカル環境のデータベースです。

## データベースの開始
```
docker-compose up
```

## MySQLクライアントを使う

3306番ポートを開いているので、MySQL Workbenchなど使い慣れたクライアントでもアクセスすることができますが、手軽に使えるWeb版のクライアントも用意しています。

1. ブラウザで`http://localhost:8001`にアクセスします。
2. 項目に以下の情報を入れてログインします。
    - サーバ：db
    - ユーザ名：test_user
    - パスワード：test_passwd
    - データベース：test


## Lambda関数からデータベースにアクセスする

```
sam local start-api --docker-network local_mysql_default
```