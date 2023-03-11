FROM ubuntu:22.10

# タイムゾーンの設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###############################################################################
# root
###############################################################################

#NOTE リリース用ビルドをするときは --no-cache をつけること
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y locales
# NOTE gnupg, pass, pinentryがbrewでうまく動作しないのでaptでインストールしている
RUN apt-get install -y gnupg pass curl unzip
RUN apt-get install -y build-essential procps curl file git
# RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev zlib1g-dev libssl-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# install aws-vault
RUN curl -L https://github.com/99designs/aws-vault/releases/download/v6.2.0/aws-vault-linux-amd64 -o /usr/bin/aws-vault \
&& chmod 755 /usr/bin/aws-vault

ENV AWS_VAULT_BACKEND pass
ENV GPG_TTY /dev/pts/0

###############################################################################
# 一般ユーザー
###############################################################################

# NOTE ホストのファイルシステムをバインドする場合はrootにしないと書き込みができないのでコメントアウトしている。
#      一般ユーザーを使用する場合は名前付きボリュームを使う。
# RUN groupadd linuxbrew && useradd -m -s /bin/bash -g linuxbrew linuxbrew
# USER linuxbrew
# WORKDIR /home/linuxbrew

# install tfenv
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv \
&& echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile

# install brew
# 一般ユーザーはbrewでのみでパッケージのインストールが可能。既存のパッケージもbrewがオーバーライドする。
# RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# RUN test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)" \
# ; test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
# ; test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile \
# ; echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc

# NOTE Nead FontはWindows, Mac側にインストールし、VSCodeの設定の`Terminal › Integrated: Font Family`で`Nerd Font`を指定してください
# RUN /home/linuxbrew/.linuxbrew/bin/brew install starship \
# && echo 'eval "$(starship init bash)"' >> ~/.bashrc

# RUN /home/linuxbrew/.linuxbrew/bin/brew install pyenv \
# && echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# RUN /home/linuxbrew/.linuxbrew/bin/brew install nodenv \
# && echo 'eval "$(nodenv init -)"' >> ~/.bashrc

# ホームの情報はマウントしたボリュームに保存する
# VOLUME ["/root"]

CMD ["bash"]