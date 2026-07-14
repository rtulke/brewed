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

# Installation profiles are selected by a user or hardware SHA-256 checksum.
# Generate a hardware checksum with:
#   ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/ {print $4}' | shasum -a 256 | awk '{print $1}'
CURRENT_USER="${SUDO_USER:-$(id -un)}"
CURRENT_USER_HASH="$(printf '%s' "$CURRENT_USER" | shasum -a 256 | awk '{print $1}')"
CURRENT_HARDWARE_HASH="$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/ {print $4}' | shasum -a 256 | awk '{print $1}')"

## Profile 1
PROFILE_1_USER_ID="9f9a47fe61845e5c14fc5462006fc2ec4ab4a2d1e7489241be0a82739080a074"
PROFILE_1_HARDWARE_ID="3114d797c64da865ab8b6f65d68d1e6b82f6250c50d053efa9dc9dd3e0ce6dc1"
PROFILE_1_CASKS=(
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
PROFILE_1_FORMULAE=(
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
PROFILE_1_MAS=(
    361304891     # Apple Numbers
    361285480     # Apple Keynote
    361309726     # Apple Pages
    1500855883    # CapCut
)
PROFILE_1_BREW_PINS=(
    python
)

## Profile 2
PROFILE_2_USER_ID="83fe8e73187b191293cb791192a35de75bebc632ee7e9c33794a722e292330c7"
PROFILE_2_HARDWARE_ID="3114d797c64da865ab8b6f65d68d1e6b82f6250c50d053efa9dc9dd3e0ce6dc1"
PROFILE_2_CASKS=()
PROFILE_2_FORMULAE=()
PROFILE_2_MAS=()
PROFILE_2_BREW_PINS=()

## Profile 3
PROFILE_3_USER_ID="ec37193df5af8be8cd96f59efdfa5e8b9e8daa2bb3146626322224d9057a2302"
PROFILE_3_HARDWARE_ID="3114d797c64da865ab8b6f65d68d1e6b82f6250c50d053efa9dc9dd3e0ce6dc1"
PROFILE_3_CASKS=()
PROFILE_3_FORMULAE=()
PROFILE_3_MAS=()
PROFILE_3_BREW_PINS=()

## Profile 4
PROFILE_4_USER_ID="e4d6dc0f6e2842e950ae809a86e90456285822d9d350ccc4dae596e0a724d7a3"
PROFILE_4_HARDWARE_ID="3114d797c64da865ab8b6f65d68d1e6b82f6250c50d053efa9dc9dd3e0ce6dc1"
PROFILE_4_CASKS=()
PROFILE_4_FORMULAE=()
PROFILE_4_MAS=()
PROFILE_4_BREW_PINS=()

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

select_profile() {
    case "$CURRENT_USER_HASH" in
        "$PROFILE_1_USER_ID")
            PROFILE_ID=1
            PROFILE_SOURCE="user"
            return
            ;;
        "$PROFILE_2_USER_ID")
            PROFILE_ID=2
            PROFILE_SOURCE="user"
            return
            ;;
        "$PROFILE_3_USER_ID")
            PROFILE_ID=3
            PROFILE_SOURCE="user"
            return
            ;;
        "$PROFILE_4_USER_ID")
            PROFILE_ID=4
            PROFILE_SOURCE="user"
            return
            ;;
    esac

    local hardware_matches=0

    if [[ "$CURRENT_HARDWARE_HASH" == "$PROFILE_1_HARDWARE_ID" ]]; then
        PROFILE_ID=1
        ((hardware_matches += 1))
    fi

    if [[ "$CURRENT_HARDWARE_HASH" == "$PROFILE_2_HARDWARE_ID" ]]; then
        PROFILE_ID=2
        ((hardware_matches += 1))
    fi

    if [[ "$CURRENT_HARDWARE_HASH" == "$PROFILE_3_HARDWARE_ID" ]]; then
        PROFILE_ID=3
        ((hardware_matches += 1))
    fi

    if [[ "$CURRENT_HARDWARE_HASH" == "$PROFILE_4_HARDWARE_ID" ]]; then
        PROFILE_ID=4
        ((hardware_matches += 1))
    fi

    ((hardware_matches > 0)) || die "No installation profile configured for this user or device."
    ((hardware_matches == 1)) || die "Hardware checksum matches multiple profiles. Configure unique hardware checksums."

    PROFILE_SOURCE="hardware"
}

load_profile() {
    set +u
    PROFILE_ID=""
    PROFILE_SOURCE=""
    select_profile

    case "$PROFILE_ID" in
        1)
            CASKS=("${PROFILE_1_CASKS[@]}")
            FORMULAE=("${PROFILE_1_FORMULAE[@]}")
            MAS=("${PROFILE_1_MAS[@]}")
            BREWPINNING=("${PROFILE_1_BREW_PINS[@]}")
            ;;
        2)
            CASKS=("${PROFILE_2_CASKS[@]}")
            FORMULAE=("${PROFILE_2_FORMULAE[@]}")
            MAS=("${PROFILE_2_MAS[@]}")
            BREWPINNING=("${PROFILE_2_BREW_PINS[@]}")
            ;;
        3)
            CASKS=("${PROFILE_3_CASKS[@]}")
            FORMULAE=("${PROFILE_3_FORMULAE[@]}")
            MAS=("${PROFILE_3_MAS[@]}")
            BREWPINNING=("${PROFILE_3_BREW_PINS[@]}")
            ;;
        4)
            CASKS=("${PROFILE_4_CASKS[@]}")
            FORMULAE=("${PROFILE_4_FORMULAE[@]}")
            MAS=("${PROFILE_4_MAS[@]}")
            BREWPINNING=("${PROFILE_4_BREW_PINS[@]}")
            ;;
        *)
            die "No installation profile selected."
            ;;
    esac

    set -u
    log "Using matching installation profile via $PROFILE_SOURCE checksum."
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
    if ((${#FORMULAE[@]})); then
        log "Installing Homebrew formulae"
        brew install "${FORMULAE[@]}"
    else
        log "No Homebrew formulae configured for '$CURRENT_USER'."
    fi

    if ((${#CASKS[@]})); then
        log "Installing Homebrew casks"
        brew install --cask "${CASKS[@]}"
    else
        log "No Homebrew casks configured for '$CURRENT_USER'."
    fi

    if ((${#BREWPINNING[@]})); then
        log "Pinning Homebrew software"
        brew pin "${BREWPINNING[@]}"
    fi

    if ((${#MAS[@]})); then
        log "Installing Mac App Store apps"
        mas install "${MAS[@]}"
    else
        log "No Mac App Store apps configured for '$CURRENT_USER'."
    fi
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
    load_profile
    update_brew
    create_user
    install_software
    ask_for_ssh
    log "Setup completed successfully."
}

main "$@"
