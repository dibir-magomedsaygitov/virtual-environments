#!/bin/bash -e
################################################################################
##  File:  java-tools.sh
##  Desc:  Installs Java and related tooling (Ant, Gradle, Maven)
################################################################################
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/etc-environment.sh

JAVA_TOOLCACHE_PATH="$AGENT_TOOLSDIRECTORY/Java_Adoptium_jdk"

installJavaFromAdoptOpenJDK() {
    local JAVA_VERSION=$1

    javaRelease=$(curl -s "https://api.adoptopenjdk.net/v3/assets/latest/$JAVA_VERSION/hotspot")
    archivePath=$(echo $javaRelease | jq -r '[.[] | select(.binary.os=="mac") | .binary.package.link][0]')
    fullVersion=$(echo $javaRelease | jq -r '[.[] | select(.binary.os=="mac") | .version.openjdk_version][0]')
    javaToolcacheVersionPath="$JAVA_TOOLCACHE_PATH/$fullVersion"
    javaToolcacheVersionArchPath="$javaToolcacheVersionPath/x64"

    echo "Downloading tar archive $archivePath"
    download_with_retries $archivePath "/tmp" "OpenJDK$JAVA_VERSION.tar.gz"

    mkdir "/tmp/jdk-$fullVersion" && tar -xzf "/tmp/OpenJDK$JAVA_VERSION.tar.gz" -C "/tmp/jdk-$fullVersion"
    mkdir -p "$javaToolcacheVersionArchPath"
    mv "/tmp/jdk-$fullVersion/*/*" "$javaToolcacheVersionArchPath"

    local JAVA_HOME_PATH="$javaToolcacheVersionArchPath/Contents/Home"

    if [[ $JAVA_VERSION == "8" ]]; then
        echo "export JAVA_HOME=${JAVA_HOME_PATH}" | tee -a /etc/environment
        export PATH="$JAVA_HOME_PATH:$PATH"
    else
        echo "export JAVA_HOME_${JAVA_VERSION}_X64=${JAVA_HOME_PATH}" | tee -a /etc/environment
    fi
}

JAVA_VERSIONS_LIST=$(get_toolset_value '.java.versions[]')
JAVA_DEFAULT=$(get_toolset_value '.java.default')

for JAVA_VERSION in "${JAVA_VERSIONS_LIST[@]}"
do
    installJavaFromAdoptOpenJDK $JAVA_VERSION
done

installJavaFromAdoptOpenJDK $JAVA_DEFAULT

# Install Ant
apt-fast install -y --no-install-recommends ant ant-optional
echo "ANT_HOME=/usr/share/ant" | tee -a /etc/environment

# Install Maven
curl -sL https://www-eu.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip -o maven.zip
unzip -d /usr/share maven.zip
rm maven.zip
ln -s /usr/share/apache-maven-3.6.3/bin/mvn /usr/bin/mvn

# Install Gradle
# This script downloads the latest HTML list of releases at https://gradle.org/releases/.
# Then, it extracts the top-most release download URL, relying on the top-most URL being for the latest release.
# The release download URL looks like this: https://services.gradle.org/distributions/gradle-5.2.1-bin.zip
# The release version is extracted from the download URL (i.e. 5.2.1).
# After all of this, the release is downloaded, extracted, a symlink is created that points to it, and GRADLE_HOME is set.
wget -O gradleReleases.html https://gradle.org/releases/
gradleUrl=$(grep -m 1 -o "https:\/\/services.gradle.org\/distributions\/gradle-.*-bin\.zip" gradleReleases.html | head -1)
gradleVersion=$(echo $gradleUrl | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p')
rm gradleReleases.html
echo "gradleUrl=$gradleUrl"
echo "gradleVersion=$gradleVersion"
curl -sL $gradleUrl -o gradleLatest.zip
unzip -d /usr/share gradleLatest.zip
rm gradleLatest.zip
ln -s /usr/share/gradle-"${gradleVersion}"/bin/gradle /usr/bin/gradle
echo "GRADLE_HOME=/usr/share/gradle" | tee -a /etc/environment

reloadEtcEnvironment