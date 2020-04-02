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

# Quick folders
alias work="cd ~/git/emisgroup"
alias mine="cd ~/git/paddymorgan84"

# Weather
alias weather='curl wttr.in'

# Random
alias whatalias='alias | grep '
