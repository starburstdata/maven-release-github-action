#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# NOTES:
# http://mywiki.wooledge.org/BashFAQ/031
# ------------------------------------------------------------------------------

set -euo pipefail

source /maven.bash

export RELEASE_POST_SCRIPTS=".mvn/release/post"

# ------------------------------------------------------------------------------
# Fail is the Maven Wrapper is not present.
# ------------------------------------------------------------------------------
if [[ ! -f ./mvnw ]]
then
  echo
  echo "------------------------------------------------------------------------------"
  echo "!!! Cannot perform release because the Maven Wrapper is not present."
  echo "------------------------------------------------------------------------------"
  exit 0
fi

# ------------------------------------------------------------------------------
# We don't want to attempt a release if the last commit is from the automation
# user that performed a release.
# ------------------------------------------------------------------------------
lastReleaseSha1=$(git log --author="${GIT_USER_NAME}" --pretty=format:"%H" -1)
if [[ "${lastReleaseSha1}" = "${GITHUB_SHA}" ]]
then
  echo "Skipping release: the latest commit ${GITHUB_SHA} is release commit from ${GIT_USER_NAME}. There are no new commits to release."
  exit 0
fi

# ------------------------------------------------------------------------------
# We don't want to attempt a release if we are on the wrong branch.
# ------------------------------------------------------------------------------
branch=${GITHUB_REF##*/}
echo "Current branch: ${branch}"
if [[ -n "${RELEASE_BRANCH_NAME}" && ! "${branch}" = "${RELEASE_BRANCH_NAME}" ]]
then
  echo "!!! Skipping release: we are on ${branch} and should be on ${RELEASE_BRANCH_NAME}."
  exit 0
fi

# ------------------------------------------------------------------------------
# Setup the automation user performing the release.
# ------------------------------------------------------------------------------
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# ------------------------------------------------------------------------------
# Prepare Maven settings.xml for the release
# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

if [[ -f ${MAVEN_RELEASE_SETTINGS_XML} ]]
then
  # Use the provided Maven settings.xml
  echo
  echo "------------------------------------------------------------------------------"
  echo "Using the provided Maven settings: ${MAVEN_RELEASE_SETTINGS_XML}"
  echo "------------------------------------------------------------------------------"
  export MAVEN_CONFIG="-s ${MAVEN_RELEASE_SETTINGS_XML}"
else
  # Use the template we provide that resides in the docker image
  echo
  echo "------------------------------------------------------------------------------"
  echo "Using the built-in Maven settings template"
  echo "------------------------------------------------------------------------------"
  export MAVEN_CONFIG="-s /settings.xml"
fi

# ------------------------------------------------------------------------------
# Running release:prepare
# ------------------------------------------------------------------------------
echo
echo "------------------------------------------------------------------------------"
echo "Executing release:prepare using -Darguments=\"${MAVEN_RELEASE_ARGUMENTS}\""
echo "------------------------------------------------------------------------------"
./mvnw -B release:prepare -Darguments="${MAVEN_RELEASE_ARGUMENTS}"

# ------------------------------------------------------------------------------
# Running release:perform
# ------------------------------------------------------------------------------
if [[ ("$?" -eq 0) && (${MAVEN_RELEASE_EXECUTE_PERFORM} == "true") ]]
then
  echo
  echo "------------------------------------------------------------------------------"
  echo "Executing release:perform using -Darguments=\"${MAVEN_RELEASE_ARGUMENTS}\""
  ./mvnw -B release:perform -Darguments="${MAVEN_RELEASE_ARGUMENTS}"
  echo "------------------------------------------------------------------------------"
fi

# ------------------------------------------------------------------------------
# Push the release commits and tags
# ------------------------------------------------------------------------------
if [[ ("$?" -eq 0) && (${MAVEN_RELEASE_PUSH_COMMITS} == "true")]]
then
  echo
  echo "------------------------------------------------------------------------------"
  echo "Pushing release commits and tag"
  echo "------------------------------------------------------------------------------"
  git push && git push --tags
else
  echo
  echo "------------------------------------------------------------------------------"
  echo "!!! Skipping pushing release commits and tag"
  echo "------------------------------------------------------------------------------"
fi

# ------------------------------------------------------------------------------
# Run any post-release scripts if present
# ------------------------------------------------------------------------------

if [[ (-d ${RELEASE_POST_SCRIPTS}) && (${MAVEN_RELEASE_EXECUTE_POST_SCRIPTS} == "true") ]]
then
  # Make the release Maven project version available to any scripts
  export MAVEN_PROJECT_VERSION=$(mavenProjectVersion ./target/checkout/pom.xml)
  echo
  echo "------------------------------------------------------------------------------"
  echo "Running release post scripts"
  echo "------------------------------------------------------------------------------"
  for postReleaseScript in `ls ${RELEASE_POST_SCRIPTS}`
  do
    script="${RELEASE_POST_SCRIPTS}/${postReleaseScript}"
    if [[ -x "${script}" ]]
    then
      ${script} ${MAVEN_PROJECT_VERSION}
    fi
  done
else
  echo "------------------------------------------------------------------------------"
  echo "!!! Skipping running release post scripts"
  echo "------------------------------------------------------------------------------"
fi
