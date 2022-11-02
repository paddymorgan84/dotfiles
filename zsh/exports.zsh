# Cows
export ANSIBLE_COW_SELECTION=random

# Go
export GOPATH=$HOME/go
export GOROOT=$(brew --prefix golang)/libexec
export GOPRIVATE='github.com/paddymorgan84'
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# dotnet
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools
