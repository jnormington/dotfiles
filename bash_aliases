for f in ~/.dotfiles/helpers/*.helper; do source $f; done

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

alias wificonnect="nmcli -ask device wifi connect"
alias wifilist="nmcli device wifi"

alias xclip="xclip -selection clipboard"
alias tma="tmux attach -t"
alias tmd="tmux detach"
alias tmn="~/.dotfiles/scripts/tmux_sessions"

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Add defaults and a touch of color.
alias ls='ls -lh --color=auto'
alias grep='grep --color=auto --exclude-dir=\.git'

alias c='clear'
