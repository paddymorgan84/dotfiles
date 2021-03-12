#!/usr/bin/env bash

set -e
set -f

printf "Set up my machine:\n"
IGNORE_PRE_REQS=${IGNORE_PRE_REQS:-false}
IGNORE_OMZ=${IGNORE_OMZ:-false}
IGNORE_DOTFILES=${IGNORE_DOTFILES:-false}
IGNORE_GIT=${IGNORE_GIT:-false}
IGNORE_SECRETS=${IGNORE_SECRETS:-false}
printf " - IGNORE_PRE_REQS = %s\n" "${IGNORE_PRE_REQS}"
printf " - IGNORE_OMZ      = %s\n" "${IGNORE_OMZ}"
printf " - IGNORE_DOTFILES = %s\n" "${IGNORE_DOTFILES}"
printf " - IGNORE_GIT      = %s\n" "${IGNORE_GIT}"
printf " - IGNORE_SECRETS  = %s\n" "${IGNORE_SECRETS}"


###
# Install pre-requisites
###
if ! ${IGNORE_PRE_REQS} ; then
  printf "\n🔧 Installing pre-requisites\n"

  apt-get clean
  apt-get update
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gcc \
    git \
    gnupg-agent \
    jq \
    make \
    nano \
    shellcheck \
    zip \
    unzip \
    zsh \
    software-properties-common
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
  ln -sf "${PWD}"/zsh/.zshenv "${HOME}"/.zshenv
  ln -sf "${PWD}"/zsh/.zshrc "${HOME}"/.zshrc
  ln -sf "${PWD}"/zsh/paddy.zsh-theme "${HOME}"/.oh-my-zsh/custom/themes/
  ln -sf "${PWD}"/zsh/aliases.zsh "${HOME}"/.oh-my-zsh/custom/aliases.zsh
  ln -sf "${PWD}"/zsh/exports.zsh "${HOME}"/.oh-my-zsh/custom/exports.zsh
  ln -sf "${PWD}"/zsh/functions.zsh "${HOME}"/.oh-my-zsh/custom/functions.zsh
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

    echo "Enter your GitHub Org";
    read -re org
    sed -i "s/MYORG/${org}/g" "${HOME}"/.zshenv
  else
    printf "oh-my-zsh isn't installed, skipping sensitive information\n"
  fi
fi
