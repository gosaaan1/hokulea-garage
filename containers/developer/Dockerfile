FROM ubuntu:22.04

# タイムゾーンの設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###############################################################################
# root
###############################################################################

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y locales build-essential procps curl file git
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

###############################################################################
# install linuxbrew
###############################################################################

RUN groupadd -r dev && useradd -r -g dev dev
USER dev

# RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# RUN test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)" \
# ; test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
# ; test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile \
# ; echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc \
# ; /home/linuxbrew/.linuxbrew/bin/brew install gcc
WORKDIR /home/dev
RUN git clone https://github.com/Homebrew/brew .linuxbrew
RUN eval "$(.linuxbrew/bin/brew shellenv)"
RUN .linuxbrew/bin/brew update --force --quiet
RUN chmod -R go-w "$(.linuxbrew/bin/brew --prefix)/share/zsh"
# RUN test -d .linuxbrew && eval "$(.linuxbrew/bin/brew shellenv)" \
# ; test -r ~/.bash_profile && echo "eval \"\$($(.linuxbrew/bin/brew --prefix).linuxbrew/bin/brew shellenv)\"" >> ~/.bash_profile \
#; echo "eval \"\$($(.linuxbrew/bin/brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
# ; .linuxbrew/bin/brew install gcc

###############################################################################
# install developer tools
###############################################################################
# RUN .linuxbrew/bin/brew install sqlite3 

###############################################################################
# install starship
###############################################################################
# NOTE Nead FontはWindows, Mac側にインストールし、VSCodeの設定の`Terminal › Integrated: Font Family`で`Nerd Font`を指定してください
# RUN .linuxbrew/bin/brew install starship \
# && echo 'eval "$(starship init bash)"' >> ~/.bashrc

###############################################################################
# install pyenv
###############################################################################
# https://devguide.python.org/getting-started/setup-building/
RUN .linuxbrew/bin/brew install \
 gcc \
 sqlite3 \
 pkg-config openssl@3.0 xz gdbm tcl-tk \
 pyenv \
 nodenv \
&& .linuxbrew/bin/brew cleanup

###############################################################################
# install nodenv
###############################################################################
RUN test -d .linuxbrew && eval "$(.linuxbrew/bin/brew shellenv)" \
; test -r ~/.bash_profile && echo "eval \"\$($(.linuxbrew/bin/brew --prefix).linuxbrew/bin/brew shellenv)\"" >> ~/.bash_profile \
; echo "eval \"\$($(.linuxbrew/bin/brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc \
; echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
; echo 'eval "$(nodenv init -)"' >> ~/.bashrc

CMD ["bash"]
