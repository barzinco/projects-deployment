#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
sudo apt-get install -y git

# Prompt user for GitHub credentials
read -p "Enter your GitHub email address: " EMAIL
read -s -p "Enter your GitHub personal access token: " TOKEN
echo

# Generate an ED25519 SSH key
ssh-keygen -q -t ed25519 -C "$EMAIL" -N ""

# Add the SSH key to the SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Get the SSH public key
ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)

# Add the SSH public key to the GitHub account
curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/keys \
    -d "{\"title\":\"$(hostname)\",\"key\":\"$ssh_public_key\"}"

echo "We are going to download needed files:)"
GITHUB_REPOSITORY="shovel-project"
GITHUB_USER="barzinco"
GITHUB_BRANCH="stable"
DIR_NAME=".barzin"

mkdir -p "$HOME/$DIR_NAME"
cd "$HOME/$DIR_NAME"
git clone --single-branch --branch $GITHUB_BRANCH git@github.com:$GITHUB_USER/$GITHUB_REPOSITORY.git

bash "$HOME/$DIR_NAME/$GITHUB_REPOSITORY/common/install.sh"
