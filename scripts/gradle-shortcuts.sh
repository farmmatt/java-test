#!/usr/bin/env bash
# ============================================================================
# Project-Local Gradle Wrapper & Multi-Core Cached Build Shortcuts
# Source this file (`source scripts/gradle-shortcuts.sh`) in any environment
# even when global workspace dotfiles are not installed.
# ============================================================================

gw() {
    local dir="${PWD}"
    while [[ "${dir}" != "/" ]]; do
        if [[ -x "${dir}/gradlew" ]]; then
            "${dir}/gradlew" "$@"
            return $?
        fi
        dir="$(dirname "${dir}")"
    done
    if command -v gradle >/dev/null 2>&1; then
        gradle "$@"
    else
        echo "Error: neither ./gradlew nor global gradle found in PATH." >&2
        return 1
    fi
}

alias gwb='gw build --build-cache --parallel'
alias gwbs='gw build -x test --build-cache --parallel'
alias gwt='gw test --build-cache --parallel'
alias gwc='gw clean build --build-cache --parallel'
alias gwcheck='gw check --build-cache --parallel'
alias gwstop='gw --stop'
