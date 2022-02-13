
# Check for an interactive session
[ -z "$PS1" ] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
PS1='\[\e[1;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'

export GOBIN=~/go/bin
export GOPATH=~/go

export PATH=$PATH:$GOBIN