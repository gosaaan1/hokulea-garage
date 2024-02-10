FROM ubuntu:22.04

# タイムゾーンの設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 必要なパッケージのインストール
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
locales \
curl git \
build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
sqlite3 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

ARG USER=py_node
ARG STARSHIP_BIN=/home/$USER/.starship/bin
ARG PYTHON_VER=3.12.1
ARG PYENV_BIN=/home/$USER/.pyenv/bin
ARG NODE_VER=20.11.0
ARG NODENV_BIN=/home/$USER/.nodenv/bin

# ユーザー作成
RUN groupadd developer && useradd -g developer $USER
USER $USER
WORKDIR /home/$USER

# install starship, pyenv, nodenv
RUN curl https://pyenv.run | bash \
&& curl -fsSL https://github.com/nodenv/nodenv-installer/raw/HEAD/bin/nodenv-installer | bash \
&& curl -sS https://starship.rs/install.sh > install.sh \
&& mkdir -p $STARSHIP_BIN \
&& sh install.sh --yes --bin-dir=$STARSHIP_BIN \
&& rm install.sh \
&& echo 'PATH=$PATH:$STARSHIP_BIN:$PYENV_BIN:$NODENV_BIN' >> ~/.bashrc \
&& echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
&& echo 'eval "$(nodenv init -)"' >> ~/.bashrc \
&& echo 'eval "$(starship init bash)"' >> ~/.bashrc \
&& $PYENV_BIN/pyenv install $PYTHON_VER \
&& $PYENV_BIN/pyenv global $PYTHON_VER \
&& $NODENV_BIN/nodenv install $NODE_VER \
&& $NODENV_BIN/nodenv global $NODE_VER

LABEL maintainer="https://github.com/gosaaan1/hokulea-garage/"

CMD ["bash"]
