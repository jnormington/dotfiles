export BROWSER=/usr/bin/firefox
export EDITOR=vim
export TERMINAL=urxvt

export PATH=$HOME/.local/bin:$PATH

export LANG='en_GB.UTF-8';
export LC_ALL='en_GB.UTF-8';

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';
export PAGER='less'

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Golang path
export GOPATH=$HOME/go
export GOROOT=$HOME/.local/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Node/Ruby version manager
export NVM_DIR="$HOME/.nvm"
export RVM_DIR="$HOME/.rvm"
