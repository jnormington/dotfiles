for f in ~/.dotfiles/helpers/*.helper; do source $f; done

# Allow editing the current command in vi with Esc then v
set -o vi

shopt -s histappend

# Omit duplicates and commands that begin with a space from history.
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=32768;
export HISTFILESIZE="${HISTSIZE}";

export EDITOR=vim;

# Prefer GB English and use UTF-8.
export LANG='en_GB.UTF-8';
export LC_ALL='en_GB.UTF-8';

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

# Filetree display
alias tree="ls -lR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

export GOPATH=~/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

alias wificonnect="nmcli -ask device wifi connect"
alias wifilist="nmcli device wifi"
alias xreset="xrandr --output eDP-1 --mode 2048x1152"
