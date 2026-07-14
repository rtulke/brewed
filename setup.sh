#!/usr/bin/env bash
#
# macOS bootstrap script
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/rtulke/brewed/main/setup.sh)

set -euo pipefail

## Configuration
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
    rectangle
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
    mas
)

MAS=(
    361304891     # Apple Numbers
    361285480     # Apple Keynote
    361309726     # Apple Pages
    1500855883    # CapCut
)

## Pinning software that should not be updated by brew.
BREWPINNING=(
    python
)

## Functions

log() {
    printf "\n==> %s\n" "$*"
}

warn() {
    printf "\nWARNING: %s\n" "$*" >&2
}

die() {
    printf "\nERROR: %s\n" "$*" >&2
    exit 1
}

check_requirements() {
    [[ "$(uname -s)" == "Darwin" ]] || die "This script only runs on macOS."
    command -v brew >/dev/null 2>&1 || die "Homebrew is not installed."
}

update_brew() {
    log "Updating Homebrew"
    brew update
    brew upgrade
}

setup_commandline_tools() {
    log "Installing xcode tools"
    xcode-select --install
}

setup_brew_pin() {
    log "Brew Pinning Setup"
    brew pin python
}

setup_ssh() {
    log "Enable Remote Login (SSH)"

    if sudo systemsetup -setremotelogin on; then
        sudo systemsetup -getremotelogin
    else
        warn "Could not enable Remote Login.

On current versions of macOS, Terminal requires
'Full Disk Access' before systemsetup may change
this setting.

System Settings
→ Privacy & Security
→ Full Disk Access

Continuing installation..."
    fi
}

create_user() {
    if id "$NEW_USER" >/dev/null 2>&1; then
        log "User '$NEW_USER' already exists."
        return
    fi

    log "Creating admin user '$NEW_USER'"
    local PASSWORD PASSWORD_CONFIRM
    read -rsp "Password: " PASSWORD < /dev/tty
    echo
    read -rsp "Confirm password: " PASSWORD_CONFIRM < /dev/tty
    echo

    [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]] || die "Passwords do not match."

    sudo sysadminctl \
        -addUser "$NEW_USER" \
        -fullName "$NEW_USER_FULLNAME" \
        -password "$PASSWORD" \
        -shell "$NEW_USER_SHELL" \
        -admin

    unset PASSWORD PASSWORD_CONFIRM

    if id "$NEW_USER" >/dev/null 2>&1; then
        log "User '$NEW_USER' created successfully."
    else
        die "User creation failed."
    fi
}

install_software() {
    log "Installing Homebrew formulae"
    brew install "${FORMULAE[@]}"

    log "Installing Homebrew casks"
    brew install --cask "${CASKS[@]}"

    log "Pinning Homebrew software"
    brew pin "${BREWPINNING[@]}"

    log "Installing Mac App Store apps"
    mas install "${MAS[@]}"
}

ask_for_ssh() {
    echo
    read -rp "Enable Remote Login (SSH)? [y/N] " ANSWER < /dev/tty

    case "$ANSWER" in
        y|Y|yes|YES)
            setup_ssh
            ;;
        *)
            log "Skipping SSH configuration."
            ;;
    esac
}

## Main

main() {
    check_requirements
    update_brew
    create_user
    install_software
    ask_for_ssh
    log "Setup completed successfully."
}

main "$@"
