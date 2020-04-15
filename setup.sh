#!/bin/sh

cp $(PWD)/git/.gitconfig.local $(HOME)/.gitconfig.local
echo "Enter your full name";
read name; \
sed -i "s/GITNAME/$$name/" $(HOME)/.gitconfig
echo "Enter your email address";
read email; \
sed -i "s/GITEMAIL/$$email/g" $(HOME)/.gitconfig
echo "Enter your PAT";
read pat; \
sed -i "s/MYTOKEN/$$pat/g" $(HOME)/.oh-my-zsh/custom/exports.zsh
echo "Enter your GitHub Org";
read org; \
sed -i "s/MYORG/$$org/g" $(HOME)/.oh-my-zsh/custom/exports.zsh

echo "\e[92mUpdating apt...\e[0m"
sudo apt update
echo "\e[92mUpgrading apt...\e[0m"
sudo apt upgrade
echo "\e[92mInstalling Make...\e[0m"
sudo apt install make
echo "\e[92mInstalling Ansible...\e[0m"
sudo apt install ansible
echo "\e[92mInstalling Zsh...\e[0m"
sudo apt install zsh
