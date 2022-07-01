#!/usr/bin/env bash

set -euo pipefail
[[ $TRACE_ENABLED == "true" ]] && set -x

source ${GITHUB_ACTION_PATH}/common.sh

# ------------------------------------------------------------------------------
# Running release:prepare
# ------------------------------------------------------------------------------

if [[ ( ${SKIP_PREPARE} == "true") ]]
then
  # TODO -> Zastanowić się nad tą wiadomością
    # TODO -> umieścić tutaj kod Pawła
  echo "Skipping commits check. Artifacts will be generated from already released system version"
  exit 0
fi

echo
echo "------------------------------------------------------------------------------"
echo "Executing release:prepare using -Darguments=\"${MAVEN_RELEASE_ARGUMENTS}\" ${RELEASE_ARGUMENTS}"
echo "------------------------------------------------------------------------------"
${MAVEN_BIN} -B release:prepare -Darguments="${MAVEN_RELEASE_ARGUMENTS}" ${RELEASE_ARGUMENTS}
echo "------------------------------------------------------------------------------"
set_output "executed" "true"
