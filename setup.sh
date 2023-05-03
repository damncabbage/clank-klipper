#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_DIR=$(unset CDPATH && cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

# Mostly just cut-paste from my ~/.bash_history

sudo apt update
sudo apt install build-essential git

./repo/scripts/install-debian.sh 

sudo systemctl restart klipper
