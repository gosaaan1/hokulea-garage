FROM ubuntu:22.04

# タイムゾーンの設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 必要なパッケージのインストール
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
locales \
sudo \
curl git \
unzip \
pass \
build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
sqlite3 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# install aws-vault
RUN curl -L https://github.com/99designs/aws-vault/releases/download/v6.2.0/aws-vault-linux-amd64 -o /usr/bin/aws-vault \
&& chmod 755 /usr/bin/aws-vault

ENV AWS_VAULT_BACKEND pass
ENV GPG_TTY /dev/pts/0

RUN groupadd --gid 1000 developer \
    && useradd --uid 1000 --gid 1000 -m terraform -s /bin/bash \
    && echo terraform ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/terraform \
    && chmod 0440 /etc/sudoers.d/terraform \
&& mkdir /workspace \
&& chown terraform:developer /workspace

USER terraform
WORKDIR /home/terraform

# install starship, pyenv, nodenv, tfenv
RUN curl https://pyenv.run | bash \
&& curl -fsSL https://github.com/nodenv/nodenv-installer/raw/HEAD/bin/nodenv-installer | bash \
&& curl -sS https://starship.rs/install.sh > install.sh \
&& mkdir -p /home/terraform/.starship/bin \
&& sh install.sh --yes --bin-dir=/home/terraform/.starship/bin \
&& rm install.sh \
&& git clone --depth=1 https://github.com/tfutils/tfenv.git /home/terraform/.tfenv

RUN echo 'PATH=$PATH:$HOME/.starship/bin:$HOME/.pyenv/bin:$HOME/.nodenv/bin:$HOME/.tfenv/bin:$PATH' >> ~/.bashrc \
&& echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
&& echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
&& echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
&& echo 'eval "$(nodenv init -)"' >> ~/.bashrc \
&& echo 'eval "$(tfenv init -)"' >> ~/.bashrc \
&& echo 'eval "$(starship init bash)"' >> ~/.bashrc

LABEL maintainer="https://github.com/gosaaan1/hokulea-garage/"

CMD ["bash"]
