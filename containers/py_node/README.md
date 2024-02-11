# Python-Node.js開発コンテナ

手元のPCで簡単にPython & Node.jsを使った開発環境を用意することができます。  
SQLiteとPostgreSQLをデータベースとして使用することができます。

## 参考文献

- [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers)
- [Python 3 と PostgreSQL (postgres)](https://github.com/devcontainers/templates/tree/main/src/postgres)

## 必要なもの

- このリポジトリのソース ※ZIPファイルでダウンロードする
- デスクトップ版 Visual Studio Code ※以下の拡張機能が必要です。
    - Dev Containers
- Docker Desktop (Windows, Mac), Docker CE/EE & Docker Compose (Linux, WSL)

## 使い方

- ホームディレクトリ下に`py_node_projects`ディレクトリを作成し、リポジトリのソース`.devcontainer`をコピーします。
- VSCodeで`py_node_projects`を開きます。
- VSCodeの >< マークをクリックし、**コンテナで開く**を選択します。
- コンテナの`/workspace`を開いた状態でVSCodeが開き直されるので、必要に応じてプロジェクトをクローン、または作成します。
- クローン／作成したプロジェクトのディレクトリに`.vscode`がなければ、作成します。
- `settings.json`がなければ、リポジトリのソース`container_side`の`settings.json`ファイルをコピーします。
- ターミナルを開き、`python --version`, `node --version`を実行し、PythonとNode.jsが正常に動作することを確認します。

## デフォルトとは違うPython, Node.jsのバージョンを使用したいとき

`pyenv`, `nodenv`がインストールされているので、プロジェクト毎に異なるバージョンを使用することができます。  
以下はPython3.7を使用する場合の例です。Node.jsは`pyenv`を`nodenv`、`python`を`node`に読み替えて実行してください。

```
cd my-project
pyenv install 3.7
pyenv local 3.7
python --version
```

## 制約

- ターミナルのプロンプトでPython, Node.jsのバージョンがわかるようにするためにStarshipを導入しています。
- コンテナの`/workspace`は名前付きボリュームの`workspace-data`に保存されます。
- 同じく、PostgreSQLのデータは名前付きボリュームの`postgres-data`に保存されます。