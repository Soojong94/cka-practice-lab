#!/bin/bash
# Problem 000: 환경 검증 (setup.sh와 동일)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/common.sh"
exec bash "${SCRIPT_DIR}/setup.sh"
