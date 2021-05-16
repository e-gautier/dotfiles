#!/usr/bin/env sh

set -e

# binaries
awk '/--- '$INSTALL_MODE'/{n=1;next}/---/{n=0}{if(n) system("sudo apt install -y "$0)}' binaries

# locales
sudo dpkg-reconfigure locales
