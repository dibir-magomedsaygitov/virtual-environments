#!/bin/bash -e
################################################################################
##  File:  github-cli.sh
##  Desc:  Installs GitHub CLI
##         Must be run as non-root user after homebrew
################################################################################

source $HELPER_SCRIPTS/invoke-tests.sh

# Install GitHub CLI
url=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r '.assets[].browser_download_url|select(contains("linux") and contains("amd64") and contains(".deb"))')
wget $url
apt install ./gh_*_linux_amd64.deb
rm gh_*_linux_amd64.deb

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
invoke_tests "CLI.Tools" "GitHub CLI"
