#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

readonly RESULTS_DIR="${RESULTS_DIR:-/tmp/results}"
readonly ROOT_DIR="${ROOT_DIR:-/node}"

readonly result="${RESULTS_DIR}/chkrootkit.log"
readonly done="${RESULTS_DIR}/done"

touch "$result"
{
  chkrootkit -r "$ROOT_DIR" 2>&1 | tee "$result"
} || true
echo -n "$result" > "$done"
