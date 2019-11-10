for f in ~/.dotfiles/helpers/*.helper; do source $f; done

# Allow editing the current command in vi with Esc then v
set -o vi
EDITOR=vim;

# Prefer GB English and use UTF-8.
LANG='en_GB.UTF-8';
LC_ALL='en_GB.UTF-8';

# Don’t clear the screen after quitting a manual page.
MANPAGER='less -X';

alias wificonnect="nmcli -ask device wifi connect"
alias wifilist="nmcli device wifi"
alias xreset="xrandr --output eDP-1 --mode 2048x1152"
