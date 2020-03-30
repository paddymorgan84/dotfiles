HOME ?= `$HOME`
PWD ?= `pwd`

explain: ## Provide the explanation of how to use the Makefile
	### Welcome
	#
	#       _       _    __ _ _
	#    __| | ___ | |_ / _(_) | ___  ___
	#   / _` |/ _ \| __| |_| | |/ _ \/ __|
	#  | (_| | (_) | |_|  _| | |  __/\__ \
	#   \__,_|\___/ \__|_| |_|_|\___||___/

	#
	### Targets
	@cat Makefile* | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: provision
provision: zsh git vscode ## Provision my dotfiles

.PHONY: zsh
zsh: ## Link all the zsh files into the relevant places
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o install-oh-my-zsh.sh;
	sh install-oh-my-zsh.sh
	rm install-oh-my-zsh.sh
	chsh -s /usr/bin/zsh
	ln -sf $(PWD)/zsh/.zshrc $(HOME)/.zshrc
	ln -sf $(PWD)/zsh/paddy.zsh-theme $(HOME)/.oh-my-zsh/custom/themes/
	ln -sf $(PWD)/common/aliases $(HOME)/.oh-my-zsh/custom/aliases.zsh
	ln -sf $(PWD)/common/exports $(HOME)/.oh-my-zsh/custom/exports.zsh
	ln -sf $(PWD)/common/functions $(HOME)/.oh-my-zsh/custom/functions.zsh

.PHONY: git
git: ## Setup the git configuration
	ln -sf $(PWD)/git/.gitconfig $(HOME)/.gitconfig
	ln -sf $(PWD)/git/.gitignore $(HOME)/.gitignore
	@echo '##'
	@echo '# Setup the local git configuration'
	@echo '##'
ifeq ("$(wildcard $(HOME)/.gitconfig.local)","")
	cp .gitconfig.local $(HOME)/.gitconfig.local
	@echo "Enter your full name";
	@read -e name; \
	sed -i '' "s/GITNAME/$$name/" $(HOME)/.gitconfig
	@echo "Enter your email address";
	@read -e email; \
	sed -i '' "s/GITEMAIL/$$email/g" $(HOME)/.gitconfig
	@echo "Enter your PAT";
	@read -e pat; \
	sed -i '' "s/MYTOKEN/$$pat/g" $(HOME)/.oh-my-zsh/custom/exports.zsh
	@echo "Enter your GitHub Org";
	@read -e org; \
	sed -i '' "s/MYORG/$$org/g" $(HOME)/.oh-my-zsh/custom/exports.zsh

.PHONY: vscode
vscode: ## Install application specific settings
	ln -sf $(PWD)/vscode/settings.json "/mnt/c/users/patrick.morgan/appdata/roaming/code/user/settings.json"
	ln -sf $(PWD)/vscode/keybindings.json "/mnt/c/users/patrick.morgan/appdata/roaming/code/user/keybindings.json"
