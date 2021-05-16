#!/usr/bin/env sh

set -e

# binaries
awk '/--- '$INSTALL_MODE'/{n=1;next}/---/{n=0}{if(n) system("sudo brew install "$0)}' binaries