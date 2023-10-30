#!/usr/bin/env bash

dryrun=''
if [[ "$1" == '-d' ]]; then
  dryrun=echo
fi

function cd_git_root {
  >&2 echo "looking for .git"
  if [ -d ".git" ]; then
    >&2 echo "found .git"
    return
  else
    >&2 echo "going up a directory"
    cd ..
    if [ "$(pwd)" != '/' ]; then
      cd_git_root
    else
      clone_repo
    fi
  fi
}

function clone_repo {
  >&2 echo "Cloning nix-config"

  git_dir=~/"git/dudeofawesome"
  mkdir -p "$git_dir"
  cd "$git_dir"
  git clone "https://github.com/dudeofawesome/nix-config"
  cd "nix-config"
}

function main {
  cd_git_root

  >&2 echo "====/ INSTALL NIX /===="
  # https://nix.dev/install-nix
  $dryrun curl -L https://nixos.org/nix/install \
    | $dryrun sh -s -- --daemon

  # load nix env vars
  source /etc/bash.bashrc

  >&2 echo "====/ SETUP BASE NIX-DARWIN /===="
  # Create temporary configuration.nix flake
  # https://github.com/LnL7/nix-darwin#step-1-creating-flakenix
  $dryrun mkdir -p ~/.config/nix-darwin
  $dryrun pushd ~/.config/nix-darwin
  $dryrun nix --experimental-features 'nix-command flakes' flake init -t nix-darwin
  $dryrun sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
  if [[ "$(uname -p)" == "arm" ]]; then
    # switch to arm
    $dryrun sed -i '' "s/x86_64-darwin/aarch64-darwin/" flake.nix
  fi
  $dryrun popd

  # Install nix-darwin
  # https://github.com/LnL7/nix-darwin#step-2-installing-nix-darwin
  $dryrun nix run nix-darwin -- switch --flake ~/.config/nix-darwin

  >&2 echo "====/ INSTALL HOMEBREW /===="
  sudo --validate
  $dryrun /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  >&2 echo "====/ APPLY FLAKE /===="
  flake=$(hostname)
  if [ ! -d "hosts/darwin/$flake" ]; then
    read -p 'What host would you like to apply?' flake
  fi
  # Apply flake
  $dryrun darwin-rebuild switch --flake ".#$flake"
}

main
