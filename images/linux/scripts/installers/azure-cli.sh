#!/bin/bash -e
################################################################################
##  File:  azure-cli.sh
##  Desc:  Installed Azure CLI (az)
################################################################################

source $HELPER_SCRIPTS/invoke-tests.sh

# Install Azure CLI (instructions taken from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
invoke_tests "CLI.Tools" "Azure CLI"