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

# Taps whose repository is not named homebrew-<name> and therefore needs
# its URL; formulae from other taps are tapped automatically when they are
# listed with their full name (user/tap/formula).
BREW_TAPS=(
    "rtulke/checkmate https://github.com/rtulke/checkmate"
)

## Hardening configuration
# Settings of the hardening step (CIS Apple macOS benchmark, level 1, with
# the deviations documented in the checkmate waiver file written below).
HARDENING_PASSWORD_MIN_LENGTH=10            # CIS: 15
HARDENING_LOCKOUT_ATTEMPTS=5                # failed logins before the account is locked
HARDENING_LOCKOUT_MINUTES=15                # duration of the lock
HARDENING_PASSWORD_HISTORY=15               # previous passwords that may not be reused
HARDENING_DISPLAY_SLEEP_MINUTES=10          # display off after (battery and power adapter)
HARDENING_SCREENSAVER_IDLE_SECONDS=1200     # screen saver after 20 minutes
HARDENING_SCREENSAVER_PASSWORD_DELAY=5      # password required 5 seconds after the screen saver starts
HARDENING_TIME_SERVER="time.apple.com"
HARDENING_LOGIN_BANNER="Nur für autorisierte Benutzer. Zugriffe werden protokolliert."
HARDENING_SSH_ALLOWED_USERS=""              # empty: the user running this script
HARDENING_SSH_ALLOWED_NETWORKS=""           # empty: the local network of the default interface
HARDENING_PROFILE_ID="local.brewed.cis-macos"
HARDENING_WAIVER_UNTIL="$(date -v+1y +%Y-%m-%d)"   # review the accepted deviations yearly
HARDENING_DRY_RUN="${HARDENING_DRY_RUN:-0}"   # 1: only print the changes

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
    affinity
    antigravity-cli
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
    displaylink
    duckduckgo
    firefox
    font-raleway
    gimp
    google-chrome
    google-earth-pro
    hermes-desktop
    intune-company-portal
    iterm2
    kimi
    kindle-create
    kindle-previewer
    macfuse
    microsoft-auto-update
    microsoft-teams
    mullvad-vpn
    nordvpn
    obsidian
    openvpn-connect
    qflipper
    raspberry-pi-imager
    steam
    telegram
    thinlinc-client
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
    colima
    container-compose
    coreutils
    cryptography
    dav1d
    deno
    diffutils
    docker
    emacs
    ffmpeg
    flac
    fmt
    fontconfig
    freetype
    fribidi
    gdk-pixbuf
    gettext
    gh
    ghostscript
    giflib
    git-filter-repo
    gitea
    glew
    glib
    gmp
    gnutls
    go
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
    jpeg-turbo
    jq
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
    libmagic
    libmaxminddb
    libnghttp2
    libnghttp3
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
    libunibreak
    libunistring
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
    llama.cpp
    llhttp
    llvm
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
    minisign
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
    pillow
    pixman
    pkgconf
    poppler
    psutils
    pwgen
    pycparser
    pydantic
    pytest
    python-tk@3.14
    python@3.12
    python@3.13
    python@3.14
    readline
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
    svt-av1
    tesseract
    tmux
    tor
    tree
    tree-sitter
    uchardet
    unbound
    uvwasi
    vapoursynth
    vhs
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
    rtulke/airsnare/airsnare
    rtulke/checkmate/checkmate
    rtulke/redactor/redactor
    rtulke/snooze/snooze
    rtulke/sshscan/sshscan
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
    1403919533     # MWeb Pro (license bought in the App Store)
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

setup_taps() {
    local entry name url
    for entry in "${BREW_TAPS[@]}"; do
        name="${entry%% *}"
        url="${entry#* }"
        brew tap | grep -qx "$name" || brew tap "$name" "$url"
    done
}

install_software() {
    setup_taps

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

## Hardening
#
# Applies the CIS Apple macOS benchmark (level 1) as far as it fits a
# personal development Mac. Every step is idempotent and can run again.
# Deliberate deviations (SSH, Siri, AirDrop, ...) are written to
# /etc/checkmate/waivers.yml, so a checkmate scan shows them with a reason.
#
# Preview without changes:  HARDENING_DRY_RUN=1 bash setup.sh

# as_root runs a command with sudo, or only prints it in a dry run.
as_root() {
    if [[ "$HARDENING_DRY_RUN" == "1" ]]; then
        printf '    [dry-run] sudo %s\n' "$*"
        return 0
    fi
    sudo "$@"
}

# as_user runs a command as the user running this script.
as_user() {
    if [[ "$HARDENING_DRY_RUN" == "1" ]]; then
        printf '    [dry-run] %s\n' "$*"
        return 0
    fi
    "$@"
}

# root_write FILE MODE writes stdin to a root-owned file.
root_write() {
    local file="$1" mode="$2" tmp
    tmp="$(mktemp)"
    cat > "$tmp"
    if [[ "$HARDENING_DRY_RUN" == "1" ]]; then
        printf '    [dry-run] write %s (mode %s):\n' "$file" "$mode"
        sed 's/^/        /' "$tmp"
        rm -f "$tmp"
        return 0
    fi
    sudo install -o root -g wheel -m "$mode" "$tmp" "$file"
    rm -f "$tmp"
}

# local_network prints the network of the default interface, e.g. 192.168.1.0/24.
local_network() {
    local iface ip mask bits=0 a b c d net
    iface="$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')"
    [[ -n "$iface" ]] || return 1
    ip="$(ipconfig getifaddr "$iface" 2>/dev/null)" || return 1
    mask="$(ifconfig "$iface" | awk '/inet / {print $4; exit}')"
    [[ "$mask" == 0x* ]] || return 1
    mask=$((mask))
    for ((i = 31; i >= 0; i--)); do (( (mask >> i) & 1 )) && ((bits += 1)); done
    IFS=. read -r a b c d <<< "$ip"
    net=$(( ((a << 24) | (b << 16) | (c << 8) | d) & mask ))
    printf '%d.%d.%d.%d/%d\n' $(( (net >> 24) & 255 )) $(( (net >> 16) & 255 )) $(( (net >> 8) & 255 )) $(( net & 255 )) "$bits"
}

ssh_enabled() {
    sudo launchctl print-disabled system 2>/dev/null | grep -q '"com.openssh.sshd" => enabled'
}

## Hardening: accounts and login

harden_root_account() {
    log "Root: no login shell (CIS 5.6); use 'sudo -s' instead of 'sudo -i'"
    as_root dscl . -create /Users/root UserShell /usr/bin/false
}

harden_password_policy() {
    log "Password policy: ${HARDENING_PASSWORD_MIN_LENGTH}+ characters, lock after ${HARDENING_LOCKOUT_ATTEMPTS} failures (CIS 5.2)"
    local policy
    policy="$(mktemp)"
    cat > "$policy" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>policyCategoryAuthentication</key>
    <array>
        <dict>
            <key>policyContent</key>
            <string>(policyAttributeFailedAuthentications &lt; policyAttributeMaximumFailedAuthentications) OR (policyAttributeCurrentTime &gt; (policyAttributeLastFailedAuthenticationTime + autoEnableInSeconds))</string>
            <key>policyIdentifier</key>
            <string>Lock the account after ${HARDENING_LOCKOUT_ATTEMPTS} failed logins</string>
            <key>policyParameters</key>
            <dict>
                <key>autoEnableInSeconds</key>
                <integer>$((HARDENING_LOCKOUT_MINUTES * 60))</integer>
                <key>policyAttributeMaximumFailedAuthentications</key>
                <integer>${HARDENING_LOCKOUT_ATTEMPTS}</integer>
            </dict>
        </dict>
    </array>
    <key>policyCategoryPasswordContent</key>
    <array>
        <dict>
            <key>policyContent</key>
            <string>policyAttributePassword matches '.{${HARDENING_PASSWORD_MIN_LENGTH},}+'</string>
            <key>policyIdentifier</key>
            <string>At least ${HARDENING_PASSWORD_MIN_LENGTH} characters</string>
        </dict>
        <dict>
            <key>policyContent</key>
            <string>policyAttributePassword matches '(.*[0-9].*){1,}+'</string>
            <key>policyIdentifier</key>
            <string>requireAlphanumeric</string>
        </dict>
        <dict>
            <key>policyContent</key>
            <string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){1,}+'</string>
            <key>policyIdentifier</key>
            <string>At least one special character</string>
        </dict>
        <dict>
            <key>policyContent</key>
            <string>policyAttributePassword matches '^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).*\$'</string>
            <key>policyIdentifier</key>
            <string>Upper and lower case letters and a digit</string>
        </dict>
        <dict>
            <key>policyContent</key>
            <string>none policyAttributePasswordHashes in policyAttributePasswordHistory</string>
            <key>policyIdentifier</key>
            <string>Not one of the last ${HARDENING_PASSWORD_HISTORY} passwords</string>
            <key>policyParameters</key>
            <dict>
                <key>policyAttributePasswordHistoryDepth</key>
                <integer>${HARDENING_PASSWORD_HISTORY}</integer>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF
    plutil -lint -s "$policy" || die "Generated password policy is invalid."
    if [[ "$HARDENING_DRY_RUN" != "1" ]]; then
        sudo pwpolicy -getaccountpolicies 2>/dev/null | tail -n +2 \
            | sudo tee "/var/root/pwpolicy-backup-$(date +%Y%m%d-%H%M%S).plist" >/dev/null || true
    fi
    as_root pwpolicy -setaccountpolicies "$policy"
    rm -f "$policy"
}

harden_login_window() {
    log "Login window: banner (CIS 5.8), no password hints (CIS 2.12.1), only the owner unlocks a session (CIS 5.7)"
    local txt
    txt="$(mktemp)"
    printf '%s\n' "$HARDENING_LOGIN_BANNER" > "$txt"
    # CIS checks for PolicyBanner.rtf; macOS shows .txt, .rtf and .rtfd.
    textutil -convert rtf "$txt" -output "${txt}.rtf"
    root_write /Library/Security/PolicyBanner.rtf 644 < "${txt}.rtf"
    as_root rm -f /Library/Security/PolicyBanner.txt
    rm -f "$txt" "${txt}.rtf"

    local user
    for user in $(dscl . -list /Users UniqueID | awk '$2 >= 501 {print $1}'); do
        if dscl . -read "/Users/$user" hint >/dev/null 2>&1; then
            as_root dscl . -delete "/Users/$user" hint
        fi
    done
    as_root security authorizationdb write system.login.screensaver authenticate-session-owner >/dev/null
}

harden_system_preferences() {
    log "System-wide settings require an administrator password (CIS 2.6.8)"
    local right work
    work="$(mktemp -d)"
    for right in system.preferences system.preferences.energysaver system.preferences.network \
                 system.preferences.printing system.preferences.sharing system.preferences.softwareupdate \
                 system.preferences.startupdisk system.preferences.timemachine; do
        security -q authorizationdb read "$right" > "$work/$right.plist" 2>/dev/null || continue
        plutil -replace shared -bool false "$work/$right.plist"
        plutil -replace group -string admin "$work/$right.plist"
        plutil -replace authenticate-user -bool true "$work/$right.plist"
        plutil -replace session-owner -bool false "$work/$right.plist"
        if [[ "$HARDENING_DRY_RUN" == "1" ]]; then
            printf '    [dry-run] sudo security authorizationdb write %s\n' "$right"
        else
            sudo security -q authorizationdb write "$right" < "$work/$right.plist"
        fi
    done
    rm -rf "$work"
}

## Hardening: sharing and remote access

harden_sharing() {
    log "Sharing: Screen Sharing, Remote Management, Remote Apple Events, SMB and NFS off (CIS 2.3.3, 4.3)"
    local ard=/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart
    [[ -x "$ard" ]] && as_root "$ard" -deactivate -stop >/dev/null 2>&1 || true
    local service
    for service in com.apple.screensharing com.apple.AEServer com.apple.smbd com.apple.nfsd; do
        as_root launchctl disable "system/$service"
        as_root launchctl bootout "system/$service" 2>/dev/null || true
    done
    as_root defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false
    as_user defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false
}

harden_ssh() {
    if ! ssh_enabled; then
        log "SSH is off: nothing to harden"
        return
    fi
    local users="${HARDENING_SSH_ALLOWED_USERS:-$USER}"
    local networks="${HARDENING_SSH_ALLOWED_NETWORKS:-$(local_network || true)}"
    local allow="" user net
    for user in $users; do
        if [[ -n "$networks" ]]; then
            for net in $networks; do allow+=" ${user}@${net}"; done
            allow+=" ${user}@127.0.0.1"
        else
            allow+=" ${user}"
        fi
    done
    log "SSH: only${allow}, no root, 3 attempts"
    root_write /etc/ssh/sshd_config.d/200-hardening.conf 644 <<EOF
# Written by brewed setup.sh (hardening).
PermitRootLogin no
AllowUsers${allow}
MaxAuthTries 3
LoginGraceTime 30
EOF
    if [[ "$HARDENING_DRY_RUN" != "1" ]]; then
        sudo sshd -t || die "Invalid sshd configuration in /etc/ssh/sshd_config.d/200-hardening.conf."
    fi
}

## Hardening: firewall, sudo, power and files

harden_firewall() {
    log "Firewall and stealth mode on (CIS 2.2)"
    local fw=/usr/libexec/ApplicationFirewall/socketfilterfw
    as_root "$fw" --setglobalstate on >/dev/null
    as_root "$fw" --setstealthmode on >/dev/null
}

harden_sudo() {
    log "sudo logs every allowed command (CIS 5.11)"
    local tmp
    tmp="$(mktemp)"
    printf 'Defaults log_allowed\n' > "$tmp"
    visudo -cqf "$tmp" || die "Invalid sudoers snippet."
    root_write /etc/sudoers.d/10-cis-logging 440 < "$tmp"
    rm -f "$tmp"
}

harden_power() {
    log "Display off after ${HARDENING_DISPLAY_SLEEP_MINUTES} minutes (CIS 2.10.1)"
    as_root pmset -a displaysleep "$HARDENING_DISPLAY_SLEEP_MINUTES"
    # On battery the Mac must not sleep before the display goes off.
    as_root pmset -b sleep "$HARDENING_DISPLAY_SLEEP_MINUTES"
}

harden_files() {
    log "Home folders 700 (CIS 5.1.1), sticky bit on world-writable folders in /Library (CIS 5.1.7)"
    local home
    for home in /Users/*; do
        [[ -d "$home" ]] || continue
        case "$(basename "$home")" in Shared|Guest) continue ;; esac
        as_root chmod 700 "$home"
    done
    local dir
    while IFS= read -r dir; do
        as_root chmod +t "$dir" 2>/dev/null || warn "macOS protects $dir; it stays as it is."
    done < <(sudo find /Library -type d -perm -002 ! -perm -1000 ! -xattrname com.apple.rootless 2>/dev/null)
}

harden_user_defaults() {
    log "Finder shows all filename extensions (CIS 6.1.1)"
    as_user defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    [[ "$HARDENING_DRY_RUN" == "1" ]] || killall Finder 2>/dev/null || true
}

## Hardening: configuration profile

# hardening_profile prints a configuration profile with the CIS settings
# that macOS only accepts as managed preferences: security, screen lock,
# updates and time, privacy, Safari and Terminal, sharing.
hardening_profile() {
    local id="$HARDENING_PROFILE_ID"
    payload() {  # payload TYPE KEYS-XML
        cat <<EOF
        <dict>
            <key>PayloadType</key><string>$1</string>
            <key>PayloadVersion</key><integer>1</integer>
            <key>PayloadIdentifier</key><string>${id}.$1</string>
            <key>PayloadUUID</key><string>$(uuidgen)</string>
            <key>PayloadDisplayName</key><string>$1</string>
            <key>PayloadEnabled</key><true/>
$2
        </dict>
EOF
    }
    cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadType</key><string>Configuration</string>
    <key>PayloadVersion</key><integer>1</integer>
    <key>PayloadScope</key><string>System</string>
    <key>PayloadIdentifier</key><string>${id}</string>
    <key>PayloadUUID</key><string>$(uuidgen)</string>
    <key>PayloadDisplayName</key><string>CIS macOS hardening (brewed)</string>
    <key>PayloadDescription</key><string>Security, screen lock, updates and time, privacy, Safari, Terminal and sharing settings of the CIS Apple macOS benchmark, level 1.</string>
    <key>PayloadOrganization</key><string>brewed</string>
    <key>PayloadRemovalDisallowed</key><false/>
    <key>PayloadContent</key>
    <array>
$(payload com.apple.security.firewall '            <key>EnableFirewall</key><true/>
            <key>EnableStealthMode</key><true/>')
$(payload com.apple.systempolicy.control '            <key>EnableAssessment</key><true/>')
$(payload com.apple.MCX "            <key>dontAllowFDEDisable</key><true/>
            <key>DisableGuestAccount</key><true/>
            <key>EnableGuestAccount</key><false/>
            <key>timeServer</key><string>${HARDENING_TIME_SERVER}</string>
            <key>forceInternetSharingOff</key><true/>")
$(payload com.apple.loginwindow '            <key>com.apple.login.mcx.DisableAutoLoginClient</key><true/>
            <key>RetriesUntilHint</key><integer>0</integer>
            <key>SHOWFULLNAME</key><true/>')
$(payload com.apple.screensaver "            <key>idleTime</key><integer>${HARDENING_SCREENSAVER_IDLE_SECONDS}</integer>
            <key>askForPasswordDelay</key><integer>${HARDENING_SCREENSAVER_PASSWORD_DELAY}</integer>")
$(payload com.apple.SoftwareUpdate '            <key>AutomaticCheckEnabled</key><true/>
            <key>AutomaticallyInstallAppUpdates</key><true/>')
$(payload com.apple.SubmitDiagInfo '            <key>AutoSubmit</key><false/>')
$(payload com.apple.applicationaccess '            <key>allowDiagnosticSubmission</key><false/>
            <key>allowApplePersonalizedAdvertising</key><false/>
            <key>forceOnDeviceOnlyDictation</key><true/>
            <key>allowContentCaching</key><false/>
            <key>allowMediaSharing</key><false/>
            <key>allowMediaSharingModification</key><false/>')
$(payload com.apple.assistant.support '            <key>Siri Data Sharing Opt-In Status</key><integer>2</integer>
            <key>Search Queries Data Sharing Status</key><integer>2</integer>')
$(payload com.apple.Accessibility '            <key>AXSAudioDonationSiriImprovementEnabled</key><false/>')
$(payload com.apple.Safari '            <key>AutoOpenSafeDownloads</key><false/>
            <key>WarnAboutFraudulentWebsites</key><true/>
            <key>WebKitPreferences.storageBlockingPolicy</key><integer>1</integer>
            <key>WebKitStorageBlockingPolicy</key><integer>1</integer>
            <key>BlockStoragePolicy</key><integer>2</integer>
            <key>WebKitPreferences.privateClickMeasurementEnabled</key><true/>
            <key>ShowFullURLInSmartSearchField</key><true/>
            <key>ShowOverlayStatusBar</key><true/>')
$(payload com.apple.Terminal '            <key>SecureKeyboardEntry</key><true/>')
$(payload com.apple.ManagedClient.preferences '            <key>PayloadContent</key>
            <dict>
                <key>com.apple.timed</key>
                <dict>
                    <key>Forced</key>
                    <array>
                        <dict>
                            <key>mcx_preference_settings</key>
                            <dict>
                                <key>TMAutomaticTimeOnlyEnabled</key><true/>
                            </dict>
                        </dict>
                    </array>
                </dict>
            </dict>')
    </array>
</dict>
</plist>
EOF
}

harden_profile() {
    if sudo profiles list 2>/dev/null | grep -q "$HARDENING_PROFILE_ID"; then
        log "Configuration profile is already installed"
        return
    fi
    log "Configuration profile with the managed CIS settings"
    local file="$HOME/Downloads/brewed-cis-hardening.mobileconfig"
    [[ "$HARDENING_DRY_RUN" == "1" ]] && file="$(mktemp)"
    hardening_profile > "$file"
    plutil -lint -s "$file" || die "Generated configuration profile is invalid."
    if [[ "$HARDENING_DRY_RUN" == "1" ]]; then
        printf '    [dry-run] open %s\n' "$file"
        return
    fi
    # macOS installs configuration profiles only with the user's consent.
    open "$file"
    open "x-apple.systempreferences:com.apple.Profiles-Settings.extension" 2>/dev/null || true
    echo
    echo "System Settings → General → Device Management:"
    echo "double-click 'CIS macOS hardening (brewed)' → Install, confirm with your password."
    read -rp "Press Enter when the profile is installed (or 's' to skip) " answer < /dev/tty
    [[ "$answer" == "s" ]] && { warn "Profile not installed; the managed CIS settings stay open."; return; }
    sudo profiles list 2>/dev/null | grep -q "$HARDENING_PROFILE_ID" \
        || warn "The profile does not seem to be installed; install $file later."
}

## Hardening: documented deviations

harden_waivers() {
    log "Documented deviations for checkmate: /etc/checkmate/waivers.yml"
    local m
    m="$(sw_vers -productVersion | cut -d. -f1)"
    local p="CIS-MACOS${m}"
    as_root mkdir -p /etc/checkmate
    {
        cat <<EOF
# Accepted deviations from the CIS Apple macOS benchmark, written by brewed
# setup.sh (hardening). Usage:
#   sudo checkmate run cis/macos${m}.yml --waivers /etc/checkmate/waivers.yml
waivers:
  - id: ${p}-5.2.2-pwpolicy_minimum_length_enforce
    reason: Mindestlänge ${HARDENING_PASSWORD_MIN_LENGTH} Zeichen; Ausgleich durch vier Zeichenklassen, Sperre nach ${HARDENING_LOCKOUT_ATTEMPTS} Fehlversuchen, FileVault und Touch ID.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-5.2.7-pwpolicy_max_lifetime_enforce
    reason: Kein erzwungener Passwortwechsel (NIST SP 800-63B, BSI); Wechsel bei Verdacht auf Kompromittierung.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-5.4-os_sudo_timeout_configure
    reason: sudo fragt nach 5 Minuten erneut (macOS-Standard), der Zeitstempel gilt pro Terminal.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-2.10.2-os_power_nap_disable
    reason: Power Nap bleibt an (Mail, iCloud und Backups im Ruhezustand).
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-5.1.7-os_world_writable_library_folder_configure
    reason: Übrig bleiben nur von macOS geschützte Ordner (z. B. /Library/AppStore); alle anderen haben das Sticky-Bit.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-3.*
    reason: Logging und Auditing ausgenommen; auditd ist von Apple abgekündigt, An- und Abmeldungen sowie sudo stehen im Systemprotokoll.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: [${p}-2.3.1.1-os_airdrop_disable, ${p}-2.3.1.2-system_settings_airplay_receiver_disable]
    reason: AirDrop und AirPlay-Empfang bleiben für die eigenen Geräte an.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-2.5.*
    reason: Siri und Apple Intelligence bleiben verfügbar.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-2.1.1.3-icloud_sync_disable
    reason: Schreibtisch und Dokumente werden mit iCloud synchronisiert.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-4.1-os_bonjour_disable
    reason: Bonjour bleibt an (Erreichbarkeit als <name>.local, AirPrint).
    until: ${HARDENING_WAIVER_UNTIL}
  - id: [${p}-2.4.1-system_settings_wifi_menu_enable, ${p}-2.4.2-system_settings_bluetooth_menu_enable, ${p}-2.3.4.1-system_settings_time_machine_auto_backup_enable]
    reason: Menüleisten-Symbole nach eigener Wahl; Time Machine nicht erzwungen.
    until: ${HARDENING_WAIVER_UNTIL}
EOF
        if ssh_enabled; then
            cat <<EOF
  - id: ${p}-2.3.3.4-system_settings_ssh_disable
    reason: SSH bleibt für den Zugriff aus dem lokalen Netz an; nur ausgewählte Benutzer und Netze, kein root.
    until: ${HARDENING_WAIVER_UNTIL}
  - id: ${p}-2.10.3-system_settings_wake_network_access_disable
    reason: Aufwachen bei Netzwerkzugriff bleibt an, damit der Mac im Ruhezustand per SSH erreichbar ist.
    until: ${HARDENING_WAIVER_UNTIL}
EOF
        fi
    } | root_write /etc/checkmate/waivers.yml 644
}

## Hardening: verification

verify_hardening() {
    local answer
    echo
    read -rp "Check the result with a checkmate CIS scan? [y/N] " answer < /dev/tty
    case "$answer" in y|Y|yes|YES) ;; *) return ;; esac
    if ! command -v checkmate >/dev/null 2>&1; then
        log "Installing checkmate"
        brew tap rtulke/checkmate https://github.com/rtulke/checkmate
        brew install checkmate
    fi
    local m policy out
    m="$(sw_vers -productVersion | cut -d. -f1)"
    policy="$(brew --prefix)/share/checkmate/cis/macos${m}.yml"
    [[ -f "$policy" ]] || { warn "checkmate has no CIS policy for macOS ${m}."; return; }
    out="$HOME/checkmate-reports"
    mkdir -p "$out"
    log "CIS scan, reports in $out"
    sudo checkmate run "$policy" --waivers /etc/checkmate/waivers.yml -q \
        --export html,pdf,json -o "$out/cis-macos${m}-$(date +%Y%m%d)" || true
    sudo chown "$USER" "$out"/cis-macos"${m}"-*
    open "$out/cis-macos${m}-$(date +%Y%m%d).html" 2>/dev/null || true
}

## Hardening: main function

hardening() {
    [[ "$HARDENING_DRY_RUN" == "1" ]] && log "Dry run: nothing is changed"
    sudo -v || die "Hardening needs administrator rights."
    harden_root_account
    harden_password_policy
    harden_login_window
    harden_system_preferences
    harden_sharing
    harden_ssh
    harden_firewall
    harden_sudo
    harden_power
    harden_files
    harden_user_defaults
    harden_profile
    harden_waivers
    [[ "$HARDENING_DRY_RUN" == "1" ]] || verify_hardening
    log "Hardening completed."
}

ask_for_hardening() {
    local answer
    echo
    read -rp "Harden macOS (CIS benchmark, see the hardening section of setup.sh)? [y/N] " answer < /dev/tty
    case "$answer" in
        y|Y|yes|YES) hardening ;;
        *) log "Skipping hardening." ;;
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
    ask_for_hardening
    log "Setup completed successfully."
}

main "$@"
