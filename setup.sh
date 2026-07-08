#!/usr/bin/env bash
# ./macos-setup.sh
#
# macOS bootstrap script: updates Homebrew, enables the SSH server,
# creates an admin user and installs a base set of software.
#
# Usage (run directly from GitHub):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rtulke/brewed/main/macos-setup.sh | bash)"
#
# Requirements: Homebrew must be installed, user must have sudo rights.

set -euo pipefail

# --- configuration -----------------------------------------------------------

NEW_USER="cray"
NEW_USER_FULLNAME="Robert Tulke"
NEW_USER_SHELL="/bin/zsh"

CASKS=(
    telegram
    google-chrome
    iterm2
    the-unarchiver
    appcleaner
    adobe-acrobat-reader
    adobe-creative-cloud
    claude
    codex
    chatgpt
    zoom
    spotify
    vlc
    whatsapp
    inkscape
    libreoffice
)

FORMULAE=(
    ffmpeg
    trash
    jq
    fzf
    msmtp
    isync
    mc
    neomutt
    rename
    tree
    htop
    tmux
    python3
    git
    coreutils
    gh
    qemu
    mc
)

# --- functions ---------------------------------------------------------------

log() {
    printf '\n==> %s\n' "$*"
}

check_requirements() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        echo "ERROR: this script runs on macOS only." >&2
        exit 1
    fi
    if ! command -v brew >/dev/null 2>&1; then
        echo "ERROR: Homebrew not found, install it first: https://brew.sh" >&2
        exit 1
    fi
}

update_brew() {
    log "Updating Homebrew"
    brew update
    brew upgrade
}

setup_ssh() {
    log "Enabling OpenSSH server (Remote Login)"
    sudo systemsetup -setremotelogin on
    sudo systemsetup -getremotelogin
}

create_user() {
    if id "${NEW_USER}" >/dev/null 2>&1; then
        log "User ${NEW_USER} already exists, skipping"
        return 0
    fi
    log "Creating admin user ${NEW_USER}"
    # read password from /dev/tty so it works when piped via curl | bash
    local PASSWORD PASSWORD_CONFIRM
    read -r -s -p "Password for ${NEW_USER}: " PASSWORD < /dev/tty
    printf '\n'
    read -r -s -p "Confirm password: " PASSWORD_CONFIRM < /dev/tty
    printf '\n'
    if [[ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]]; then
        echo "ERROR: passwords do not match." >&2
        exit 1
    fi
    sudo sysadminctl -addUser "${NEW_USER}" \
        -fullName "${NEW_USER_FULLNAME}" \
        -password "${PASSWORD}" \
        -shell "${NEW_USER_SHELL}" \
        -admin
    unset PASSWORD PASSWORD_CONFIRM
}

install_software() {
    log "Installing casks"
    for CASK in "${CASKS[@]}"; do
        brew install --cask "${CASK}" || echo "WARNING: cask ${CASK} failed, continuing"
    done

    log "Installing formulae"
    for FORMULA in "${FORMULAE[@]}"; do
        brew install "${FORMULA}" || echo "WARNING: formula ${FORMULA} failed, continuing"
    done
}

# --- main --------------------------------------------------------------------

main() {
    check_requirements
    update_brew
    setup_ssh
    create_user
    install_software
    log "Done."
}

main "$@"
