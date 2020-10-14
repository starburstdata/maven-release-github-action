#!/usr/bin/env bash
set -euo pipefail
source ${GITHUB_ACTION_PATH}/common.sh

# ------------------------------------------------------------------------------
# Push the release commits and tags
# ------------------------------------------------------------------------------
echo "------------------------------------------------------------------------------"
if [[ "${MAVEN_RELEASE_PUSH_COMMITS}" == "true" ]]
then
  echo
  echo "Pushing release commits and tag"
  echo "------------------------------------------------------------------------------"
  git push && git push --tags
  set_output "executed" "true"
else
  echo "Skipped pushing release commits and tag"
  set_output "executed" "false"
fi
echo "------------------------------------------------------------------------------"
