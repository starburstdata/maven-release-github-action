#!/usr/bin/env bash

set -euo pipefail
[[ $TRACE_ENABLED == "true" ]] && set -x

# If we are using maven wrapper, make sure it's downloaded. Otherwise downloading/uncompressing
# may contaminate commands outputs.
${MAVEN_BIN} -f "${MAVEN_PROJECT_POM}" --version
