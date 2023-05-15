#!/bin/bash
# shellcheck source-path=SCRIPTDIR

REPO_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export REPO_PATH

. "${REPO_PATH}/bashplate.sh"

print_debug "Testing print_debug without TERM_DEBUG"
TERM_DEBUG='' print_debug "Testing print_debug with TERM_DEBUG=<empty>"
TERM_DEBUG=1 print_debug "Testing print_debug with TERM_DEBUG=1"
print_info "Testing print_info"
TERM_PREFIX=prefix print_info "Testing print_info with a prefix"
print_success "Testing print_success"
print_warn "Testing print_warn"
print_error "Testing print_error"
print_critical "Testing print_critical"

nested_test() {
    TERM_PREFIX_OFFSET=1 print_info "Testing nested print_info"
}

nested_test
