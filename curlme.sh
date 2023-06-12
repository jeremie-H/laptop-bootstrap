#!/bin/bash

# need sudo permissions
[ $(id -u) -eq 0 ] || printf "check for sudo permissions ..."
[ $(id -u) -eq 0 ] || exec sudo /bin/bash -c "$(printf '%q ' "$BASH_SOURCE" "$USER" "$@")"
printf "\e[32m OK \e[0m!\n"
printf "\e[32m test $(id -u)\e[0m!\n"
exit 1;
USER_NO_ADMIN="$1"
shift

ROOT_GIT_REPO="/home/$USER_NO_ADMIN/.config/git"
REPO_NAME="laptop-bootstrap"
REPO_PATH="$ROOT_GIT_REPO/$REPO_NAME"


printf "\e[32m GGG $(printf '%q ' "$BASH_SOURCE" "$@") \e[0m!\n"
echo "USER_NO_ADMIN=$USER_NO_ADMIN"


function install_git_ansible() {
  # avoid prompt when apt-get install
  # https://raphaelhertzog.com/2010/09/21/debian-conffile-configuration-file-managed-by-dpkg/
  echo "installing git & python3-pip ..."
  apt-get --assume-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install git python3-pip


  printf "installing ansible ... "
  pip3 install -q ansible
  printf "\e[32m ansible v$(ansible --version | grep core)\e[0m\n"
}


function clone_repo() {
  #tmp_dir=$(mktemp -d -t bootstrap-dotfiles-XXXXXXXXXX)
  #echo "temporary directory $tmp_dir"
  echo "clone ansible repository laptop-bootstrap to $ROOT_GIT_REPO"
  sudo -u "$USER_NO_ADMIN" mkdir -p "$ROOT_GIT_REPO"
  sudo -u "$USER_NO_ADMIN" git -C "$ROOT_GIT_REPO" clone --quiet https://github.com/jeremie-H/laptop-bootstrap.git "$REPO_PATH" > /dev/null
}

#install_git_ansible
#clone_repo

cd $REPO_PATH
sudo -u "$USER_NO_ADMIN" whoami
sudo -u "$USER_NO_ADMIN" ansible-playbook playbook.yml -i inventory.yml --extra-vars "unix_user=$USER_NO_ADMIN"



