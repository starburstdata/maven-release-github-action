#!/usr/bin/env bash
set -euo pipefail
source ${GITHUB_ACTION_PATH}/common.sh

version=$(mavenProjectVersion | sed 's/-SNAPSHOT//')

set_output "version" "${version}"
echo "MAVEN_PROJECT_VERSION=${version}" >> $GITHUB_ENV

echo "Releasing project version ${version}"
