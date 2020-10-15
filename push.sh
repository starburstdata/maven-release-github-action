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
  if ! (git push origin HEAD:refs/heads/${RELEASE_BRANCH_NAME} && git push origin ${MAVEN_PROJECT_VERSION}); then
      echo "Failed to push release commits and tag"
      set_output "executed" "false"
      exit 1
  fi
  set_output "executed" "true"
else
  echo "Skipped pushing release commits and tag"
  echo "Branch to be pushed: origin HEAD:refs/heads/${RELEASE_BRANCH_NAME}"
  echo "Tag to be pushed: ${MAVEN_PROJECT_VERSION}"
  set_output "executed" "false"
fi
echo "------------------------------------------------------------------------------"
