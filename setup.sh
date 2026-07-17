#!/usr/bin/env bash
#
# macOS bootstrap script
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/rtulke/brewed/main/setup.sh)

set -euo pipefail

## Configuration
NEW_USER_SHELL="/bin/zsh"

# Installation profiles are selected by a hardware SHA-256 checksum.
# Generate a hardware checksum with:
#   ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/ {print $4}' | shasum -a 256 | awk '{print $1}'
CURRENT_HARDWARE_HASH="$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/ {print $4}' | shasum -a 256 | awk '{print $1}')"

## Profile 1
PROFILE_1_HARDWARE_ID="0000000000000000000000000000000000000000000000000000000000000001"
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
PROFILE_2_HARDWARE_ID="3114d797c64da865ab8b6f65d68d1e6b82f6250c50d053efa9dc9dd3e0ce6dc1"
PROFILE_2_CASKS=(
    adobe-creative-cloud
    balenaetcher
    basictex
    bitwarden
    calibre
    capcut
    chatgpt
    claude
    claude-code@latest
    codex
    devcleaner
    font-raleway
    gimp
    google-chrome
    google-earth-pro
    iterm2
    kindle-create
    kindle-previewer
    microsoft-auto-update
    microsoft-teams
    mullvad-vpn
    mweb-pro
    nordvpn
    obsidian
    raspberry-pi-imager
    steam
    telegram
    threema@beta
    tor-browser
    transmit
    utm
    visual-studio-code
    whatsapp
    windows-app
    wireshark-app
)

PROFILE_2_FORMULAE=(
    ada-url
    airsnare
    ansible
    aom
    arp-scan
    brotli
    btop
    c-ares
    ca-certificates
    cairo
    cask
    certifi
    cffi
    cmake
    container-compose
    coreutils
    cryptography
    dav1d
    deno
    diffutils
    emacs
    ffmpeg
    flac
    fmt
    fontconfig
    freetype
    fribidi
    gdk-pixbuf
    gemini-cli
    gettext
    gh
    ghostscript
    giflib
    gitea
    glew
    glib
    gmp
    gnutls
    graphite2
    groff
    harfbuzz
    hashcat
    hcxtools
    hdrhistogram_c
    hermes-agent
    htop
    icu4c@78
    ifstat
    iftop
    imagemagick
    jasper
    jbig2dec
    jq
    jpeg-turbo
    json-c
    lame
    leptonica
    libarchive
    libass
    libavif
    libb2
    libbluray
    libdatrie
    libde265
    libevent
    libffi
    libgcrypt
    libgit2
    libgpg-error
    libheif
    libidn
    libidn2
    libimagequant
    liblinear
    libmaxminddb
    libnghttp2
    libnghttp3
    libngtcp2
    libogg
    libpaper
    libpcap
    libplacebo
    libpng
    libraqm
    librsvg
    libsamplerate
    libscrypt
    libsmi
    libsndfile
    libsodium
    libssh
    libssh2
    libtasn1
    libthai
    libtiff
    libtool
    libudfread
    libunistring
    libunibreak
    libvmaf
    libvorbis
    libvpx
    libx11
    libxau
    libxcb
    libxdmcp
    libxext
    libxrender
    libyaml
    little-cms2
    llvm
    llhttp
    lua
    luajit
    lynx
    lz4
    lzo
    m4
    mas
    masscan
    mdless
    mdv
    merve
    midnight-commander
    minizip
    molten-vk
    mpdecimal
    mpg123
    mpv
    mujs
    nbytes
    ncftp
    ncurses
    netpbm
    nettle
    nmap
    node
    oniguruma
    openjpeg
    openssl@3
    openssl@4
    opus
    p11-kit
    pandoc
    pango
    pcre2
    pcre2
    pillow
    pixman
    pkgconf
    psutils
    pwgen
    pycparser
    pydantic
    pytest
    python@3.12
    python@3.13
    python@3.14
    readline
    rename
    ripgrep
    rp
    rubberband
    ruby
    rust
    s-lang
    sdl2-compat
    sdl3
    sevenzip
    shaderc
    shellcheck
    simdjson
    simdutf
    speexdsp
    sqlite
    sshscan
    svt-av1
    tesseract
    tor
    tree
    tree-sitter
    tree-sitter@0.25
    uchardet
    unbound
    uvwasi
    vapoursynth
    vulkan-headers
    vulkan-loader
    webp
    wget
    wireshark
    x264
    x265
    xcodegen
    xorgproto
    xorriso
    xxhash
    xz
    yt-dlp
    z3
    zimg
    zstd
)

PROFILE_2_MAS=(
    1193539993     # Brother iPrint&Scan
    682658836     # GarageBand
    1351639930     # Gifski
    408981434     # iMovie
    361285480     # Keynote
    302584613     # Kindle
    441258766     # Magnet
    361304891     # Numbers
    1507139439     # One Markdown
    361309726     # Pages
    897118787     # Shazam
    1406961198     # SimpleClient
    899247664     # TestFlight
    1450874784     # Transporter
    1230249825     # VMware Remote Console
    6447090616     # WhisperNotes
    1451685025     # WireGuard
    497799835     # Xcode
)

PROFILE_2_BREW_PINS=()

## Profile 3
PROFILE_3_HARDWARE_ID="7ddeccbff31577fe3e3dc83d7e9530ca5e5ed7348f2fd9163dd5f8e173b60e38"
PROFILE_3_CASKS=()
PROFILE_3_FORMULAE=()
PROFILE_3_MAS=()
PROFILE_3_BREW_PINS=()

## Profile 4
PROFILE_4_HARDWARE_ID="0000000000000000000000000000000000000000000000000000000000000003"
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

    ((hardware_matches > 0)) || die "No installation profile configured for this device."
    ((hardware_matches == 1)) || die "Hardware checksum matches multiple profiles. Configure unique hardware checksums."
}

load_profile() {
    set +u
    PROFILE_ID=""
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
    log "Using matching hardware installation profile."
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
    local username="$1"
    local full_name="$2"

    if id "$username" >/dev/null 2>&1; then
        log "User '$username' already exists."
        return
    fi

    log "Creating admin user '$username'"
    local password password_confirm
    read -rsp "Password: " password < /dev/tty
    echo
    read -rsp "Confirm password: " password_confirm < /dev/tty
    echo

    [[ "$password" == "$password_confirm" ]] || die "Passwords do not match."

    sudo sysadminctl \
        -addUser "$username" \
        -fullName "$full_name" \
        -password "$password" \
        -shell "$NEW_USER_SHELL" \
        -admin

    unset password password_confirm

    if id "$username" >/dev/null 2>&1; then
        log "User '$username' created successfully."
    else
        die "User creation failed."
    fi
}

ask_for_user_creation() {
    local answer username full_name

    echo
    read -rp "Create an additional admin user? [y/N] " answer < /dev/tty

    case "$answer" in
        y|Y|yes|YES)
            ;;
        *)
            log "Skipping additional user creation."
            return
            ;;
    esac

    read -rp "Username: " username < /dev/tty
    [[ -n "$username" ]] || die "Username must not be empty."
    [[ "$username" =~ ^[A-Za-z0-9._-]+$ ]] || die "Username contains unsupported characters."

    read -rp "Full name: " full_name < /dev/tty
    [[ -n "$full_name" ]] || die "Full name must not be empty."

    create_user "$username" "$full_name"
}

install_software() {
    if ((${#FORMULAE[@]})); then
        log "Installing Homebrew formulae"
        brew install "${FORMULAE[@]}"
    else
        log "No Homebrew formulae configured for the selected hardware profile."
    fi

    if ((${#CASKS[@]})); then
        log "Installing Homebrew casks"
        brew install --cask "${CASKS[@]}"
    else
        log "No Homebrew casks configured for the selected hardware profile."
    fi

    if ((${#BREWPINNING[@]})); then
        log "Pinning Homebrew software"
        brew pin "${BREWPINNING[@]}"
    fi

    if ((${#MAS[@]})); then
        log "Installing Mac App Store apps"
        mas install "${MAS[@]}"
    else
        log "No Mac App Store apps configured for the selected hardware profile."
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
    ask_for_user_creation
    install_software
    ask_for_ssh
    log "Setup completed successfully."
}

main "$@"
