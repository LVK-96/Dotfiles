#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Vi mode
set -o vi

# ls with colors
alias ls='ls --color=auto'

# Git status in bash prompt
source /usr/share/git/completion/git-prompt.sh
export PS1="\[\033[32m\]\w\[\033[33m\]\$(GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWDIRTYSTATE=1 __git_ps1)\[\033[00m\] $ "

export TERM='xterm-256color'
export EDITOR='nvim'
alias vim="nvim"
