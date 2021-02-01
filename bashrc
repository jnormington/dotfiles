[[ $- != *i* ]] && return

# Ensure to have installed bash-completion for this file to exist - gets me everytime
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Set the PS1 prompt (with colors) - only display the last child/parent directory
PS1='\[\033[01;32m\][\u@\h\[\033[00;37m\] ${PWD#"${PWD%/*/*}/"} \[\033[01;32m\]] \$\[\033[00m\] '

# Allow editing the current command in vi with Esc then v
set -o vi

# Avoid dups in history.
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=32768;
export HISTFILESIZE="${HISTSIZE}";
shopt -s histappend

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize
shopt -s expand_aliases

# Add bash aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Source any custom envs
if [ -f ~/.custom_envs ]; then
    source ~/.custom_envs
fi

# RVM
[ -s "$RVM_DIR/scripts/rvm" ] && \. "$RVM_DIR/scripts/rvm"
[ -r $RVM_DIR/scripts/completion ] && . $RVM_DIR/scripts/completion

# NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
