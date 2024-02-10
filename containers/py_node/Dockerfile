FROM ubuntu:22.04

ARG PYTHON_VER=3.12.1
ARG NODE_VER=20.11.0

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

# ユーザー作成
RUN groupadd developer && useradd -g developer py_node
USER py_node
WORKDIR /home/py_node

# install starship, pyenv, nodenv
RUN curl https://pyenv.run | bash \
&& curl -fsSL https://github.com/nodenv/nodenv-installer/raw/HEAD/bin/nodenv-installer | bash \
&& curl -sS https://starship.rs/install.sh > install.sh \
&& mkdir -p $/home/py_node/.starship/bin \
&& sh install.sh --yes --bin-dir=$/home/py_node/.starship/bin \
&& rm install.sh \
&& echo 'PATH=$PATH:$/home/py_node/.starship/bin:$/home/py_node/.pyenv/bin:$/home/py_node/.nodenv/bin' >> ~/.bashrc \
&& echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
&& echo 'eval "$(nodenv init -)"' >> ~/.bashrc \
&& echo 'eval "$(starship init bash)"' >> ~/.bashrc \
&& /home/py_node/.pyenv/bin/pyenv install $PYTHON_VER \
&& /home/py_node/.pyenv/bin/pyenv global $PYTHON_VER \
&& /home/py_node/.nodenv/bin/nodenv install $NODE_VER \
&& /home/py_node/.nodenv/bin/nodenv global $NODE_VER

LABEL maintainer="https://github.com/gosaaan1/hokulea-garage/"

CMD ["bash"]
