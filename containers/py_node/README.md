# Python-Node.js開発コンテナ

手元のPCで簡単にPython & Node.jsを使った開発環境を用意することができます。  
SQLiteとPostgreSQLをデータベースとして使用することができます。

## 必要なもの

- このリポジトリの.devcontainerディレクトリ以下のソース
- [デスクトップ版 Visual Studio Code](https://code.visualstudio.com/Download) ※以下の拡張機能が必要です。
    - [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) ※プリインストールされているかもしれません
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows, Mac), Docker CE/EE & Docker Compose (Linux, WSL)

## 使い方

- ホームディレクトリ下に`py_node_projects`ディレクトリを作成し、その下に`.devcontainer`ディレクトリをコピーします。  ※わかりやすくするために`py_node_projects`にしていますが、好きな名前に変えてください。
- VSCodeで`py_node_projects`フォルダを開きます。
- VSCodeの >< マークをクリックし、**コンテナーで開く（またはコンテナーで再度開く）**を選択します。
  
![スクリーンショット 2024-02-11 115218](https://github.com/gosaaan1/hokulea-garage/assets/123862848/7952a215-68a9-4f89-a508-5a4f3f17e28f)
![スクリーンショット 2024-02-11 115147](https://github.com/gosaaan1/hokulea-garage/assets/123862848/10d2dad1-300f-4f50-9f71-0b5562ec354f)
- `/workspace`ディレクトリの下にプロジェクトをクローン、または作成します。
- ターミナルを開き、`python --version`, `node --version`を実行し、PythonとNode.jsが正常に動作することを確認します。

### データベースアクセスが必要なアプリ開発をしたい

この開発コンテナには`sqlite3`と`PostgreSQL`がインストールされています。

#### DBクライアント

VSCodeの拡張機能**Database Client**を使うと簡単に接続できます。

![スクリーンショット 2024-02-11 122355](https://github.com/gosaaan1/hokulea-garage/assets/123862848/8c3d5111-a88b-4ad2-96a4-665729088a1c)

#### SQLite

`*.db`ファイルの場所を`Database Path`で選択します。

![スクリーンショット 2024-02-11 115853](https://github.com/gosaaan1/hokulea-garage/assets/123862848/1ad8683e-e2c6-401f-b8f0-fa6b81e526b8)

#### PostgreSQL

以下のキャプチャを参考に設定してください。パスワードは`postgres`です。

![スクリーンショット 2024-02-11 115825](https://github.com/gosaaan1/hokulea-garage/assets/123862848/157e9537-d020-4623-867a-920817160e0e)

### デフォルトとは違うPython, Node.jsのバージョンを使いたい

`pyenv`, `nodenv`がインストールされているので、プロジェクト毎に異なるバージョンを使用することができます。  
以下はPython3.7を使用する場合の例です。Node.jsは`pyenv`を`nodenv`、`python`を`node`に読み替えて実行してください。

```
cd my-project
pyenv install 3.7
pyenv local 3.7
python --version
```

### 使い慣れたVSCodeの拡張機能やコマンドを使いたい

- たいていの拡張機能は開発コンテナ上でも動作します。
- `apt`コマンドで任意のパッケージをインストールすることができます。

## その他

- ターミナルのプロンプトでPython, Node.jsのバージョンやGitのブランチ名などがわかるようにするために[Starship](https://starship.rs/)を導入しています。
- ソースやデータベースのデータはDockerの名前付きボリュームに保存しています。
    - `/workspace`: 名前付きボリュームの`workspace-data`
    - PostgreSQLのデータ: 名前付きボリュームの`postgres-data`

## 参考文献

- [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers)
- [Python 3 と PostgreSQL (postgres)](https://github.com/devcontainers/templates/tree/main/src/postgres)
