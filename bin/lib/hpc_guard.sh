#!/bin/bash
# hpc_guard.sh -- shared SCC safety guards for scripts that compile/build.
#
# SOURCE this file (do not run it), then call the guard before any heavy build:
#     source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/hpc_guard.sh"
#     require_compute_node || exit 1
#
# require_compute_node
#   Refuse to run heavy compilation on an SCC login node. The scheduler exports
#   $NSLOTS (and $JOB_ID) only inside a batch/interactive job; a shell without
#   them is a login node, where heavy compiles are against SCC policy and get
#   throttled or killed. Returns 0 when it's safe to build, 1 otherwise.
#   Override for a node you know is safe (or for testing): ALLOW_LOGIN_NODE=1.
require_compute_node() {
  if [ -n "${NSLOTS:-}" ] || [ -n "${JOB_ID:-}" ]; then
    return 0
  fi
  if [ "${ALLOW_LOGIN_NODE:-}" = "1" ]; then
    printf 'WARNING: no $NSLOTS/$JOB_ID (looks like a login node), but ALLOW_LOGIN_NODE=1 -- proceeding.\n' >&2
    return 0
  fi
  printf 'ERROR: this looks like an SCC login node -- no $NSLOTS/$JOB_ID from the scheduler.\n' >&2
  printf '       Heavy compilation on login nodes is against SCC policy and will be slow or killed.\n' >&2
  printf '       Request an interactive job first, then re-run this inside it:\n' >&2
  printf '         qrsh -P <project> -pe omp 4      # match the core count to the build\n' >&2
  printf '       (Override for a node you know is safe: ALLOW_LOGIN_NODE=1)\n' >&2
  return 1
}
