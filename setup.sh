#!/usr/bin/env bash

set -e
set -f

printf "Set up my machine:\n"
IGNORE_BREW=${IGNORE_BREW:-false}
IGNORE_OMZ=${IGNORE_OMZ:-false}
IGNORE_DOTFILES=${IGNORE_DOTFILES:-false}
IGNORE_VSCODE=${IGNORE_VSCODE:-false}
IGNORE_GIT=${IGNORE_GIT:-false}
IGNORE_SECRETS=${IGNORE_SECRETS:-false}
printf " - IGNORE_BREW = %s\n" "${IGNORE_BREW}"
printf " - IGNORE_OMZ      = %s\n" "${IGNORE_OMZ}"
printf " - IGNORE_DOTFILES = %s\n" "${IGNORE_DOTFILES}"
printf " - IGNORE_GIT      = %s\n" "${IGNORE_GIT}"
printf " - IGNORE_SECRETS  = %s\n" "${IGNORE_SECRETS}"


###
# Identify if I'm running on VS Code dev container or GitHub Codespaces. If I am, I only want the dotfiles.
###
if [ ${REMOTE_CONTAINERS} ] || [ ${CODESPACES} ] ; then
  IGNORE_BREW=true
  IGNORE_OMZ=true
  IGNORE_VSCODE=true
  IGNORE_GIT=true
  IGNORE_SECRETS=true
fi

###
# Install brew
###
if ! ${IGNORE_BREW} ; then
printf "\n🔧 Installing brew\n"
if [ "$(arch)" = "arm64" ]; then
  printf "\nRunning on arm64\n"
  if ! brew --version ; then
    sudo mkdir -p /opt/homebrew
    sudo chown -R "$(whoami)":wheel /opt/homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C /opt/homebrew
  else
    brew update
    brew upgrade
  fi
else
  printf "\nRunning on intel\n"
  if ! brew --version ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    brew update
    brew upgrade
  fi
fi

###
# Install brew formulae
###
brew bundle --file ./brew/Brewfile
brew autoremove
brew cleanup

fi

###
# Install oh my zsh
###
if ! ${IGNORE_OMZ} ; then
  printf "\n🔧 Installing oh-my-zsh\n"

  if [ -d "${HOME}/.oh-my-zsh" ]; then
    printf "oh-my-zsh is already installed\n"
  else
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
fi

###
# Installing dotfiles
###
if ! ${IGNORE_DOTFILES} ; then
  printf "\n🔧 Installing dotfiles\n"

  ## Don't need to do this with devcontainers. .zshenv was added to solve a environment variable mapping issue
  ## https://github.com/microsoft/vscode-remote-release/issues/3456
  if [[ -z ${REMOTE_CONTAINERS} ]] ; then
    ln -sf "${PWD}"/zsh/.zshenv "${HOME}"/.zshenv
  fi

  ln -sf "${PWD}"/zsh/.zshrc "${HOME}"/.zshrc
  ln -sf "${PWD}"/zsh/paddy.zsh-theme "${HOME}"/.oh-my-zsh/custom/themes/
  ln -sf "${PWD}"/zsh/aliases.zsh "${HOME}"/.oh-my-zsh/custom/aliases.zsh
  ln -sf "${PWD}"/zsh/exports.zsh "${HOME}"/.oh-my-zsh/custom/exports.zsh
  ln -sf "${PWD}"/zsh/functions.zsh "${HOME}"/.oh-my-zsh/custom/functions.zsh
  ln -sf "${PWD}"/git/.gitconfig "${HOME}"/.gitconfig
  mkdir -p "${HOME}"/.config/gh
  ln -sf "${PWD}"/gh/config.yml "${HOME}"/.config/gh/config.yml
fi

###
# Configuring VS Code
###
if ! ${IGNORE_VSCODE} ; then
printf "\n🔧  Installing code configuration\n"
ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
ln -sf "$(pwd)/vscode/settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
ln -sf "$(pwd)/vscode/keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"

EXTENSIONS=(
  donjayamanne.githistory
  dracula-theme.theme-dracula
  eamodio.gitlens
  esbenp.prettier-vscode
  golang.go
  hashicorp.terraform
  ms-kubernetes-tools.vscode-kubernetes-tools
  ms-vscode-remote.remote-containers
  PKief.material-icon-theme
  plex.vscode-regolint
  redhat.vscode-yaml
  tsandall.opa
)
for ext in "${EXTENSIONS[@]}"; do printf "installing: %s\n" "${ext}" && code --install-extension "${ext}" --force; done
fi


###
# Installing git configuration
###
if ! ${IGNORE_GIT} ; then
  printf "\n🔧 Installing git configuration\n"
  if [ ! -f "${HOME}/.gitconfig.local" ] ; then
    cp git/.gitconfig.local "${HOME}/.gitconfig.local"

    echo "Enter your full name";
    read -re var
    sed -i "s/GITNAME/${var}/" "${HOME}/.gitconfig.local"

    echo "Enter your email address";
    read -re var
    sed -i "s/GITEMAIL/${var}/" "${HOME}/.gitconfig.local"
  fi
fi

###
# Install sensitive information
###
if ! ${IGNORE_SECRETS} ; then
  printf "\n🔧 Installing oh-my-zsh\n"
  if [ -d "${HOME}/.oh-my-zsh" ]; then
    echo "Enter your GitHub PAT";
    read -re pat
    sed -i "s/MYTOKEN/${pat}/g" "${HOME}"/.zshenv
  else
    printf "oh-my-zsh isn't installed, skipping sensitive information\n"
  fi
fi
