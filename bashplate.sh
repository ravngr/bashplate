#!/bin/bash
# shellcheck disable=SC2034

# bashplate variables
BASHPLATE=true
export BASHPLATE
BASHPLATE_VERSION="v1.0.2"
export BASHPLATE_VERSION


## Options
# Exit on errors
set -o errexit

# Exit un unset variables
set -o nounset

# Carry non-zero error codes through conditional chains
set -o pipefail


## Globals
# Terminal escape characters
_TERM_ESC='\033['
_TERM_ESC_TERM='m'

# Terminal colour/style codes
TERM_RESET="${_TERM_ESC}0${_TERM_ESC_TERM}"

TERM_STYLE_BOLD=1
TERM_STYLE_BRIGHT=2
TERM_STYLE_UNDER=4

TERM_STYLE_FG_BLACK=30
TERM_STYLE_FG_RED=31
TERM_STYLE_FG_GREEN=32
TERM_STYLE_FG_YELLOW=33
TERM_STYLE_FG_BLUE=34
TERM_STYLE_FG_PURPLE=35
TERM_STYLE_FG_CYAN=36
TERM_STYLE_FG_GRAY=37

TERM_STYLE_BG_BLACK=40
TERM_STYLE_BG_RED=41
TERM_STYLE_BG_GREEN=42
TERM_STYLE_BG_YELLOW=43
TERM_STYLE_BG_BLUE=44
TERM_STYLE_BG_PURPLE=45
TERM_STYLE_BG_CYAN=46
TERM_STYLE_BG_GRAY=47

# Make values available in scripts
export TERM_RESET

# Export style variables
for var in "${!TERM_STYLE_@}"; do
    export "${var?}"
done


## Functions
# Function to print message with style arguments
print_style() {
    local result="$1"

    if [[ $TERM == "xterm"* || $TERM == "screen"* ]]; then
        until [ -z "${2:-}" ]; do
            # Prefix control codes
            result="${_TERM_ESC}${2}${_TERM_ESC_TERM}${result}"
            shift || break
        done

        # Attach reset sequence
        echo -e "${result}${TERM_RESET}"
    else
        echo -e "${result}"
    fi
}

# Styles for messages
style_debug=( "$TERM_STYLE_FG_GRAY" )
style_good=( "$TERM_STYLE_FG_GREEN" )
style_info=()
style_warn=( "$TERM_STYLE_FG_YELLOW" )
style_error=( "$TERM_STYLE_BOLD" "$TERM_STYLE_FG_RED" )
style_critical=( "$TERM_STYLE_BOLD" "$TERM_STYLE_BG_RED" "$TERM_STYLE_FG_GRAY" )

_get_datetime() {
    date +"%Y-%m-%d %H:%M:%S.%03N"
}

_get_prefix() {
    if [ -z "${TERM_PREFIX_OFFSET:-}" ]; then
        TERM_PREFIX_OFFSET=0
    fi

    local source_file
    source_file=$(basename "${BASH_SOURCE[TERM_PREFIX_OFFSET+2]}")
    local source_line
    source_line="${BASH_LINENO[TERM_PREFIX_OFFSET+1]}"

    if [ -z "${TERM_PREFIX:-}" ]; then
        echo "${source_file}:${source_line}"
    else
        echo "${TERM_PREFIX} ${source_file}:${source_line}"
    fi
}

print_debug() {
    if [[ -n "${TERM_DEBUG:-}" || -n "${CI:-}" ]]; then
        local prefix
        prefix="$(_get_datetime) [D] $(_get_prefix)"
        prefix=$(print_style "${prefix}" "${style_debug[@]}")
        echo -e "${prefix} $*"
    fi
}

print_info() {
    local prefix
    prefix="$(_get_datetime) [I] $(_get_prefix)"
    prefix=$(print_style "${prefix}" "${style_info[@]}")
    echo -e "${prefix} $*"
}

print_success() {
    local prefix
    prefix="$(_get_datetime) [I] $(_get_prefix)"
    prefix=$(print_style "${prefix}" "${style_good[@]}")
    echo -e "${prefix} $*"
}

print_warn() {
    local prefix
    prefix="$(_get_datetime) [W] $(_get_prefix)"
    prefix=$(print_style "${prefix}" "${style_warn[@]}")
    echo -e "${prefix} $*"
}

print_error() {
    local prefix
    prefix="$(_get_datetime) [E] $(_get_prefix)"
    prefix=$(print_style "${prefix}" "${style_error[@]}")
    echo -e "${prefix} $*"
}

print_critical() {
    local prefix
    prefix="$(_get_datetime) [E] $(_get_prefix)"
    prefix=$(print_style "${prefix}" "${style_critical[@]}")
    echo -e "${prefix} $*"
}

source_required_env() {
    env_path="$1"

    if [ ! -e "${env_path}" ]; then
        TERM_PREFIX_OFFSET=1 print_critical "Missing required file $(print_style "${env_path}" ${TERM_STYLE_BOLD})"
    fi

    set -a
    TERM_PREFIX_OFFSET=1 print_info "Reading $(print_style "${env_path}" ${TERM_STYLE_BOLD})"
    # shellcheck disable=SC1090
    source "$1"
    set +a
}

source_optional_env() {
    env_path="$1"

    if [ -e "${env_path}" ]; then
        set -a
        TERM_PREFIX_OFFSET=1 print_info "Reading $(print_style "${env_path}" ${TERM_STYLE_BOLD})"
        # shellcheck disable=SC1090
        source "$1"
        set +a
    fi
}
