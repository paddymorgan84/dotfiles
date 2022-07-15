# Filesystem
alias ls='ls -lGh'
alias envs='env | sort'

# Files
alias lfends='find . -type f -print0 | xargs -0 dos2unix' #Convert all CRLF line endings to LF

# Helper to open stuff in Chrome
alias open-chrome='open -a "Google Chrome"'

# Date related aliases
alias week='date +%V'

# GUID Generator
alias guid='uuidgen | tr "[:upper:]" "[:lower:]"'

# IP addresses
alias publicip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ifconfig | grep 'inet ' | grep -v 127.0.0.1 | cut -d\\  -f2"

# Git
alias gdn='git diff --name-only'
alias gdns='git diff --name-status'
alias grmb='git branch --merged develop | egrep -v '"'"'(master|develop)'"'"' | xargs -r git branch -d'
alias gundo='git reset --soft HEAD~1'

# Quick folders
alias work="cd ~/git/azure"
alias mine="cd ~/git/github/paddymorgan84"

# Weather
alias weather='curl wttr.in'

# Random
alias whatalias='alias | grep '

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'

# WSL2
alias drop_cache="sudo sh -c \"echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\""

# Docker
alias dsc='docker stop $(docker ps -aq)' # Stop all docker containers currently running
alias drc='docker rm -vf $(docker ps -a -q)' # Remove all stopped docker containers
alias dri='docker rmi -f $(docker images -a -q)' # Remove all docker images

# VS Code
alias dotfiles='code ~/git/github/paddymorgan84/dotfiles'
alias journal='code ~/git/github/paddymorgan84/journal'
alias presentations='code ~/git/github/paddymorgan84/presentations'
alias university='code ~/git/github/paddymorgan84/university'
alias fplgo='code ~/git/github/paddymorgan84/fpl'
