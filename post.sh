#!/usr/bin/env bash
set -euo pipefail
source ${GITHUB_ACTION_PATH}/common.sh

echo "------------------------------------------------------------------------------"
if [[ (-d ${RELEASE_POST_SCRIPTS}) && (${MAVEN_RELEASE_EXECUTE_POST_SCRIPTS} == "true") ]]
then
  # Make the release Maven project version available to any scripts
  echo "Running release post scripts for version ${MAVEN_PROJECT_VERSION}"
  echo "------------------------------------------------------------------------------"
  for postReleaseScript in `ls ${RELEASE_POST_SCRIPTS}`
  do
    script="${RELEASE_POST_SCRIPTS}/${postReleaseScript}"
    if [[ -x "${script}" ]]
    then
      echo "Running ${script}"
      ${script} ${MAVEN_PROJECT_VERSION}
      echo "------------------------------------------------------------------------------"
    fi
  done
  set_output "executed" "true"
else
  echo "!!! Skipping running release post scripts as ${RELEASE_POST_SCRIPTS} does not exist"
  set_output "executed" "true"
fi
echo "------------------------------------------------------------------------------"
