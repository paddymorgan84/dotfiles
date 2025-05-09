#!/usr/bin/env bash

set -e
set -f

printf "Set up my machine:\n"

IGNORE_PRE_REQS=${IGNORE_PRE_REQS:-false}
IGNORE_BREW=${IGNORE_BREW:-true}
IGNORE_OMZ=${IGNORE_OMZ:-false}
IGNORE_DOTFILES=${IGNORE_DOTFILES:-false}
IGNORE_VSCODE=${IGNORE_VSCODE:-false}
IGNORE_GIT=${IGNORE_GIT:-false}
IGNORE_SECRETS=${IGNORE_SECRETS:-false}
IGNORE_DOTNET=${IGNORE_DOTNET:-false}
IGNORE_TERRAFORM=${IGNORE_TERRAFORM:-false}

printf " - IGNORE_PRE_REQS  = %s\n" "${IGNORE_PRE_REQS}"
printf " - IGNORE_BREW      = %s\n" "${IGNORE_BREW}"
printf " - IGNORE_OMZ       = %s\n" "${IGNORE_OMZ}"
printf " - IGNORE_DOTFILES  = %s\n" "${IGNORE_DOTFILES}"
printf " - IGNORE_VSCODE    = %s\n" "${IGNORE_VSCODE}"
printf " - IGNORE_GIT       = %s\n" "${IGNORE_GIT}"
printf " - IGNORE_SECRETS   = %s\n" "${IGNORE_SECRETS}"
printf " - IGNORE_DOTNET    = %s\n" "${IGNORE_DOTNET}"
printf " - IGNORE_TERRAFORM = %s\n" "${IGNORE_TERRAFORM}"


###
# Identify if I'm running on VS Code dev container or GitHub Codespaces. If I am, I only want the dotfiles.
###
if [ "${REMOTE_CONTAINERS}" ] || [ "${CODESPACES}" ] ; then
  IGNORE_BREW=true
  IGNORE_OMZ=true
  IGNORE_VSCODE=true
  IGNORE_GIT=true
  IGNORE_SECRETS=true
  IGNORE_TERRAFORM=true
fi

###
# Install pre-requisites
###
if ! ${IGNORE_PRE_REQS} ; then
  printf "\n🔧 Installing pre-requisites\n"

  sudo apt-get clean
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    g++ \
    gnupg-agent \
    software-properties-common
fi

###
# Install brew
###
if ! ${IGNORE_BREW} ; then
  printf "\n🔧 Installing brew\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  test -r ~/.profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
  echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile

  BREWFOLDER=$([ "${WSL_DISTRO_NAME}" ] && echo "linux" || echo "mac")

  ###
  # Perform NVM post install steps
  ###

  if [ ! -d "$HOME/.nvm" ]
  then
    mkdir ~/.nvm
    echo "export NVM_DIR=\"$HOME/.nvm\"" >> ~/.profile
    echo "[ -s \"/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh\" ] && \. \"/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh\"" >> ~/.profile
    echo "[ -s \"/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm\" ] && \. \"/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm\""  # This loads nvm bash_completion
  fi

  ###
  # Install brew formulae
  ###
  brew bundle --file "${PWD}"/brew/"${BREWFOLDER}"/Brewfile
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
ln -sf "$(pwd)/vscode/settings.json" "${HOME}/.vscode-server/data/Machine/settings.json"
cp "$(pwd)/vscode/keybindings.json" "/mnt/c/Users/pmorgan/AppData/Roaming/Code/User/keybindings.json"

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
  if [ ! -f "${HOME}/git/work/.gitconfig.work" ] ; then
    mkdir -p "${HOME}/git/work"
    cp git/.gitconfig.work "${HOME}/git/work/.gitconfig.work"
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

###
# Install dotnet - this cannot be done
###
if ! ${IGNORE_DOTNET} ; then
  printf "\n🔧 Installing dotnet\n"
  wget https://dot.net/v1/dotnet-install.sh
  sudo chmod +x ./dotnet-install.sh
  ./dotnet-install.sh -c Current
fi

###
# Install Terraform
###

if ! ${IGNORE_TERRAFORM} ; then
  # Only add GPG key if it's not already installed
  if ! gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --list-keys > /dev/null 2>&1; then
    echo "[+] Adding HashiCorp GPG key..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  else
    echo "[=] GPG key already exists."
  fi

  # Only add repo if it's not already present
  if ! grep -q "^deb .*hashicorp" /etc/apt/sources.list.d/hashicorp.list 2>/dev/null; then
    echo "[+] Adding HashiCorp APT repository..."
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
  else
    echo "[=] HashiCorp APT repository already present."
  fi

  # Only install if Terraform is not already installed
  if ! command -v terraform >/dev/null; then
    echo "[+] Installing Terraform..."
    sudo apt-get update -y
    sudo apt-get install -y terraform
  else
    echo "[=] Terraform already installed: $(terraform version | head -n1)"
  fi
fi
