#!/usr/bin/env bash
set -euo pipefail
source ${GITHUB_ACTION_PATH}/common.sh

version=$(mavenProjectVersion | sed 's/-SNAPSHOT//')

if [[ "${MAVEN_RELEASE_VERSION}" != "" ]]; then
  version="${MAVEN_RELEASE_VERSION}"
fi

set_output "version" "${version}"
echo "MAVEN_PROJECT_VERSION=${version}" >> $GITHUB_ENV

echo "Releasing project version ${version}"
