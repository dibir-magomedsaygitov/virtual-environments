#!/bin/bash -e
################################################################################
##  File:  ruby.sh
##  Desc:  Installs Ruby requirements
################################################################################

source $HELPER_SCRIPTS/install.sh

sudo apt-get install ruby-full
sudo gem update --system

# Install Ruby requirements
apt-get install -y libz-dev openssl libssl-dev

echo "Install Ruby..."
toolset="$INSTALLER_SCRIPT_FOLDER/toolset.json"
RELEASE_URL="https://api.github.com/repos/ruby/ruby-builder/releases/latest"
TOOLSET_VERSIONS=$(jq -r '.toolcache[] | select(.name | contains("ruby")) | .versions[]' $toolset)
PLATFORM_VERSION=$(jq -r '.toolcache[] | select(.name | contains("ruby")) | .platform_version' $toolset)
RUBY_PATH="$AGENT_TOOLSDIRECTORY/Ruby"

echo "Check if Ruby hostedtoolcache folder exist..."
if [ ! -d $RUBY_PATH ]; then
    mkdir -p $RUBY_PATH
fi

for TOOLSET_VERSION in ${TOOLSET_VERSIONS[@]}; do
    PACKAGE_TAR_NAME=$(curl $RELEASE_URL | jq -r '.assets[].name' | grep "^ruby-${TOOLSET_VERSION}-ubuntu-${PLATFORM_VERSION}.tar.gz$" | sort -V | tail -1)
    RUBY_VERSION=$(echo $PACKAGE_TAR_NAME | cut -d'-' -f 2)
    PACKAGE_TAR_TEMP_PATH="/tmp/$PACKAGE_TAR_NAME"
    RUBY_VERSION_PATH="$RUBY_PATH/$RUBY_VERSION"
    mkdir -p $RUBY_VERSION_PATH

    echo "Downloading tar archive $PACKAGE_TAR_NAME"
    DOWNLOAD_URL="https://github.com/ruby/ruby-builder/releases/download/toolcache/${PACKAGE_TAR_NAME}"
    download_with_retries $DOWNLOAD_URL $PACKAGE_TAR_TEMP_PATH

    echo "Expand '$PACKAGE_TAR_NAME' to the '$RUBY_VERSION_PATH' folder"
    tar xf $PACKAGE_TAR_TEMP_PATH -C $RUBY_VERSION_PATH

    COMPLETE_FILE_PATH="$RUBY_VERSION_PATH/x64.complete"
    if [ ! -f $COMPLETE_FILE_PATH ]; then
        echo "Create complete file"    
        touch $COMPLETE_FILE_PATH
    fi
done
