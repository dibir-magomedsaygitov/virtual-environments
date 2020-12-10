#!/bin/bash -e
################################################################################
##  File:  7-zip.sh
##  Desc:  Installs 7-zip
################################################################################

echo "test purposes"
source $HELPER_SCRIPTS/invoke-tests.sh

# Install 7-Zip
echo "install 7zip"
apt-get update -y
apt-get install -y p7zip p7zip-full p7zip-rar

# Run tests to determine that the software installed as expected
invoke_pester_tests "Common.Tools" "7-Zip"