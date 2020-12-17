#!/bin/bash -e
################################################################################
##  File:  aws.sh
##  Desc:  Installs the AWS CLI
################################################################################

source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/invoke-tests.sh

# Install the AWS CLI v1 on Ubuntu16 and Ubuntu18, and AWS CLI v2 on Ubuntu20
if isUbuntu20 ; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
    rm awscliv2.zip
    rm -rf aws
fi

if isUbuntu16 || isUbuntu18 ; then
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    rm awscli-bundle.zip
    rm -rf awscli-bundle
fi

curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
invoke_tests "CLI.Tools" "AWS"