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
  fi
}

function main {
  cd_git_root

  # Install nix
  # https://nix.dev/install-nix
  $dryrun curl -L https://nixos.org/nix/install \
    | $dryrun sh -s -- --daemon

  # load nix env vars
  source /etc/bash.bashrc

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

  # Install Homebrew
  $dryrun /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  flake=$(hostname)
  if [ ! -d "hosts/darwin/$flake" ]; then
    read -p 'What host would you like to apply?' flake
  fi
  # Apply flake
  $dryrun darwin-rebuild switch --flake ".#$flake"
}

main
