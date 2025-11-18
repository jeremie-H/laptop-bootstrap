#!/bin/bash
set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Logging setup
LOG_FILE="/tmp/laptop-bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Laptop Bootstrap Script ==="
echo "Log file: $LOG_FILE"
echo "Started at: $(date)"

# Need sudo permissions
if [ "$(id -u)" -ne 0 ]; then
  printf "Checking for sudo permissions ... "
  exec sudo /bin/bash -c "$(printf '%q ' "$BASH_SOURCE" "$USER" "$@")"
fi
printf "\e[32m OK \e[0m!\n"

USER_NO_ADMIN="${1:-$USER}"
shift || true

# Use XDG_CONFIG_HOME if set, otherwise default to ~/.config
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/home/$USER_NO_ADMIN/.config}"
ROOT_GIT_REPO="$XDG_CONFIG_HOME/git"
REPO_NAME="laptop-bootstrap"
REPO_PATH="$ROOT_GIT_REPO/$REPO_NAME"

echo "Target user: $USER_NO_ADMIN"
echo "Repository path: $REPO_PATH"

function install_git_ansible() {
  # Avoid prompt when apt-get install
  # https://raphaelhertzog.com/2010/09/21/debian-conffile-configuration-file-managed-by-dpkg/
  echo "Installing git & python3-pip ..."
  apt-get update -qq
  apt-get --assume-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install git python3-pip

  printf "Installing ansible ... "
  pip3 install -q ansible
  printf "\e[32m ansible v$(ansible --version | grep core)\e[0m\n"
}

function clone_repo() {
  echo "Cloning ansible repository laptop-bootstrap to $ROOT_GIT_REPO"
  sudo -u "$USER_NO_ADMIN" mkdir -p "$ROOT_GIT_REPO"

  if [ -d "$REPO_PATH" ]; then
    echo "Repository already exists, pulling latest changes..."
    sudo -u "$USER_NO_ADMIN" git -C "$REPO_PATH" pull --quiet
  else
    sudo -u "$USER_NO_ADMIN" git -C "$ROOT_GIT_REPO" clone --quiet https://github.com/jeremie-H/laptop-bootstrap.git "$REPO_PATH"
  fi
}

# Uncomment to enable installation and cloning
# install_git_ansible
# clone_repo

# For local development, use current directory
REPO_PATH='.'

cd "$REPO_PATH" || { echo "Failed to change directory to $REPO_PATH"; exit 1; }

echo "Running ansible-playbook as user: $USER_NO_ADMIN"
sudo -u "$USER_NO_ADMIN" whoami

if ! sudo -u "$USER_NO_ADMIN" ansible-playbook playbook.yml -i inventory.yml --extra-vars "unix_user=$USER_NO_ADMIN"; then
  echo "ERROR: Ansible playbook execution failed. Check logs at $LOG_FILE"
  exit 1
fi

echo "=== Bootstrap completed successfully at $(date) ==="
echo "Log file: $LOG_FILE"



