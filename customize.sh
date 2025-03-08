#!/system/bin/sh
#MODDIR=${0%/*}

# Fail immediately on errors and unset variables
set -o errexit
set -o nounset
set -o pipefail

MODDIR=${MODPATH:-/data/adb/modules/Integrity-Box}
URL="https://raw.githubusercontent.com/TempMeow/Integrity-Box/main/keybox"
DEST="/sdcard/keybox"
HASH_FILE="$MODDIR/hashes.txt"
SCRIPT_PATH="$MODDIR/customize.sh"
L="/data/adb/Integrity-Box/Integrity-Box.log"
U="/data/adb/modules_update/Integrity-Box"
T="/data/adb/tricky_store"
V="------------------------------------------"
ENC="$T/keybox.xml.enc"
D="$T/keybox.xml"
B="$T/keybox.xml.bak"
SUS="$U/sus.sh"
SUSF="/data/adb/susfs4ksu"
SUSP="$SUSF/sus_path.txt"
ASS="/system/product/app/MeowAssistant/MeowAssistant.apk"
TT="$T/target.txt"
PIF="/data/adb/modules/playintegrityfix"
PROP_FILE="$PIF/module.prop"
OPENSSL_VERSION="3.0.1" 
OPENSSL_TAR="openssl-$OPENSSL_VERSION.tar.gz" 
OPENSSL_SRC_DIR="/data/local/tmp/openssl-$OPENSSL_VERSION" 
INSTALL_DIR="/data/adb/Integrity-Box/openssl" 
INSTALL_BIN_DIR="$INSTALL_DIR/bin" 
AC="$U/action.sh"
P1="aHR0cHM"
P2="6Ly9yYXcu"
P3="Z2l0aHVid"
P4="XNlcmNvb"
P5="nRlbnQuY2"
P6="9tL1RlbXB"
P7="NZW93L2"
P8="RldmljZV9"
P9="YMDBURC"
P10="9yZWZzL2"
P11="hlYWRzLz"
P12="E1L292ZX"
P13="JsYXkvcG"
P14="Fja2FnZX"
P15="MvYXBwc"
P16="y9TZXR0a"
P17="W5ncy9yZ"
P18="XMvdmFs"
P19="dWVzL2tle"
P20="WJveC54b"
P21="WwuZW5j"

chmod +x "$U/key.sh"
sh "$U/key.sh"

log() {
    echo "$1" | tee -a "$L"
}

MEOW() {
    am start -a android.intent.action.MAIN -e mona "$@" -n meow.helper/.MainActivity &>/dev/null
    sleep 0.5
}

#Clear Cache before proceeding 
CLEAR_CACHE=true

echo "====== Module Installation Started ======" > "$L"
log " "
sleep 1
mkdir -p /data/adb/Integrity-Box
touch /data/adb/Integrity-Box/Integrity-Box.log

# Start Logging
log "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "  📝 Logged on:  $(date '+%A %d/%m/%Y %I:%M:%S %p')"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " "

# Install Assistant
log "Installing Meow Assistant..."
if pm install "$MODPATH/$ASS" &>/dev/null; then
    log "✅ Meow Assistant installed successfully."
else
    log "❌ Error: Meow Assistant installation failed."
fi
echo " "
sleep 1

#Install dependencies silently
pkg update -y >/dev/null 2>&1 pkg install -y wget make clang gcc libssl-dev zlib-dev >/dev/null 2>&1

#Download and extract OpenSSL
cd /data/local/tmp wget -q https://www.openssl.org/source/$OPENSSL_TAR

tar -xzf $OPENSSL_TAR && rm -f $OPENSSL_TAR

#Build and install OpenSSL
cd $OPENSSL_SRC_DIR ./config --prefix=$INSTALL_DIR --openssldir=$INSTALL_DIR >/dev/null make -s -j$(nproc) >/dev/null make install >/dev/null

# Detect PIF & Refresh the fp
log "🔍 Scanning PIF"
if [ -d "$PIF" ] && [ -f "$PROP_FILE" ]; then
    if grep -q "name=Play Integrity Fix" "$PROP_FILE"; then
	    log "$V"
        log "🪐 Detected: PIF by chiteroman"
        log "Refreshing fingerprint using chiteroman's module"
        log "$V"
        log " "
        sh "$PIF/action.sh"
        log " "
    elif grep -q "name=Play Integrity Fork" "$PROP_FILE"; then
	    log "$V"
        log "🥁 Detected: PIF by osm0sis"
        log "Refreshing fingerprint using osm0sis's module"
        log "$V"
        log " "
        sh "$PIF/autopif2.sh"
        echo " "
        echo " "
        echo " "
        
    fi
fi

# Pass Device verdicts (legacy and new) by default without spoofing a valid certificate chain
#sed -i 's/"spoofVendingSdk": 0/"spoofVendingSdk": 1/' /data/adb/modules/playintegrityfix/pif.json
chmod +x "$U/spoof.sh"
sh "$U/spoof.sh"

# Ensure hash file exists
if [ ! -f "$HASH_FILE" ]; then
    log "⚠️ Error: Hash file not found at $HASH_FILE"
    exit 1
fi

# Mystery function
generate_random_values() {
    local _x=$((RANDOM % 9999))
    local _y=$((RANDOM % 9999))
    local _z=$((_x * _y / (_y + 1)))
    return 0
}

# Check integrity
check_integrity() {
    [ -z "$MODDIR" ] && MODDIR=$(dirname "$(realpath "$0")")
    
    local _script_sum _enc_sum
    
    # Calculate script checksum
    _script_sum=$(md5sum "$SCRIPT_PATH" 2>/dev/null | awk '{print $1}') || { log "⚠️ Error calculating script checksum"; exit 1; }

    # Check encrypted keybox
    if [ -f "$ENC_FILE" ]; then
        _enc_sum=$(md5sum "$ENC_FILE" 2>/dev/null | awk '{print $1}') || { log "⚠️ Error calculating keybox checksum"; exit 1; }
    else
        log "⚠️ Warning: Encrypted keybox not found. Skipping integrity check for keybox."
        _enc_sum="MISSING_FILE"
    fi

    # Compare with expected hashes from hash file
    . "$HASH_FILE"
    if [ "$_script_sum" != "$SCRIPT_HASH" ]; then
        log "💀 Tampering detected in script!"
        exit 1
    fi

    if [ "$_enc_sum" != "MISSING_FILE" ] && [ "$_enc_sum" != "$ENC_HASH" ]; then
        log "💀 Tampering detected in encrypted keybox!"
        exit 1
    fi
}

# Check  TrickyStore 
check_trickystore() {
    if [ ! -d "$T" ]; then
        log "⚠️ TrickyStore missing. Investigating..."
        sleep 1
        if [ "$(ls -A "$KEYBOX_DIR" 2>/dev/null | wc -l)" -gt 0 ]; then
            log "🔎 Suspicious: $T contains ghost files!"
        else
            log "❌ TrickyStore Not Found. Terminating."
            exit 1
        fi
    fi
}

# Check network connectivity
check_network() {
    local _hosts="8.8.8.8 1.1.1.1 google.com"
    local _success=0
    for host in $_hosts; do
        if ping -c 1 -W 1 "$host" >/dev/null 2>&1; then
            _success=1
            break
        fi
    done
    if [ $_success -eq 1 ]; then
        log "🌐 Internet connection detected."
        return 0
    else
        log "❌ No internet connection. Please check your network."
        return 1
    fi
}

# Backup existing keybox
backup_keybox() {
    if [ -f "$D" ]; then
        local _timestamp=$(date +%s)
        mv "$D" "$B.bak"
        log "📦 Old keybox archived"
    fi
}

# Download and validate the keybox file
download_keybox() {
    local _url="$1" _dest="$2"
    if ! curl --retry 5 --connect-timeout 10 -fsSL "$_url" -o "$_dest"; then
        log "⚠️ curl failed, trying wget..."
        if ! wget --retry-connrefused --waitretry=3 --timeout=10 -qO "$_dest" "$_url"; then
            log "❌ Download failed: Connection issues or blocked URL."
            exit 1
        fi
    fi

    if [ ! -s "$_dest" ]; then
        log "❌ Download failed: Empty or missing file."
        exit 1
    fi

    log "✅ Keybox Downloaded successfully"
}

# Handle the keybox downloading process
handle_keybox() {
    X=$(echo "$P1$P2$P3$P4$P5$P6$P7$P8$P9$P10$P11$P12$P13$P14$P15$P16$P17$P18$P19$P20$P21" | base64 -d 2>/dev/null)

    # Validate URL
    if [[ ! "$X" =~ ^https?:// ]]; then
        log "❌ Error: Invalid URL in keybox parameters"
        exit 1
    fi

    # Fetch and validate keybox file
    download_keybox "$X" "$ENC_FILE"
}

# Main execution
generate_random_values
check_trickystore
check_network
backup_keybox
handle_keybox
# check_integrity

log "🛠️ Script execution completed successfully."

# Ensure OpenSSL binary is executable
chmod +x "$INSTALL_BIN_DIR/openssl"

#Set CORE to OpenSSL binary
CORE="$INSTALL_BIN_DIR/openssl"
log "🚦 Status 1: Positive" [ -f "$ENC" ] || exit 1 log "🚦 Status 2: Positive"
"$CORE" enc -aes-256-cbc -d -pbkdf2 -in "$ENC" -out "$D" -k "$CLEAR_CACHE" 2>>"$L"
log "🚦 Status 3: Positive" cat "$L" rm -f "$ENC"
}

if [ -f "$D" ]; then
    {
        echo " "

        echo " ------------------------------------------------------------------- "
        echo "           Integrity🛡Box KEYBOX RETRIEVER      "
        echo " ------------------------------------------------------------------- "
        echo " "
        echo " |    🔑 Key Type  : Public Leak "
#       echo " |    🔐 Algorithm  :        "
        echo " |    🪐 Date       : Last updated on 04/03/2025 "
        echo " |    🤖 Retriever   : Integrity Box by MEOWna "
        echo " |    🌐 Update    : https://t.me/MeowRedirect/210 "
        echo " "
        echo " ------------------------------------------------------------------- "
        echo " ------------------------------------------------------------------- "
        echo " 👀 Retrieved by module on $(date '+%A %d/%m/%Y %I:%M:%S%p') (GMT: $(date -u '+%I:%M:%S%p')) "
        echo " "
    } >> "$D"

    echo "✅ Keybox injected successfully"
    chmod 644 "$D"
else
    echo "Error: $D does not exist."
fi
echo " "
sleep 1

if pm list packages | grep -q "meow.helper"; then
    MEOW "😼 Meow Assistant is online."
else
    log "⚠️ Meow Assistant is offline. Update it."
fi
echo " "
sleep 2

# Check if action.sh exists
if [ ! -f "$AC" ]; then
    log "⚠️ action.sh not found. Skipping step."
    exit 0
fi

log "🚀 Running builder..."
chmod +x "$AC"
sh "$AC"
chmod 644 "$TT"
echo " "
sleep 1

log "🍁 Wiping PlayStore data "
su -c "pm clear com.android.vending"
log "🍁 Wiping PlayService Data "
su -c "pm clear com.google.android.gms"

log "🧰 Performing internal checks"
log " "

# Check if the package exists before disabling it
if su -c pm list packages | grep -q "eu.xiaomi.module.inject"; then
    log "🦄 Disabling spoofing for EU ROMs"
    su -c pm disable eu.xiaomi.module.inject &>/dev/null
fi

# Check if the properties exist before setting them
if getprop persist.sys.pihooks.disable.gms_props >/dev/null 2>&1; then
    log "🎲 Disabling GMS props spoofing"
    setprop persist.sys.pihooks.disable.gms_props true
fi

if getprop persist.sys.pihooks.disable.gms_key_attestation_block >/dev/null 2>&1; then
    log "🎲 Disabling GMS key attestation block"
    setprop persist.sys.pihooks.disable.gms_key_attestation_block true
    su -c setprop persist.sys.pihooks.disable.gms_key_attestation_block true
fi
echo " "
sleep 1

echo "🔍 Checking if $SUSP exists..."
if [ -f "$SUSP" ]; then
    log " "
    log "✅ SusFS is installed"
    chmod +x "$SUS"
    sh -x "$SUS"
else
    log "⚠️ SusFS not found. Skipping file generation."
fi

# Remove Old Config File If Exists
if [ -f "$SUSF/config.sh" ]; then
    log "🚮 Removing old config file..."
    rm "$SUSF/config.sh"
    log "🦩 Old config file removed."
fi

# Update Config File
log "🔮 Updating config..."
{
    echo "# set SUS_SU & ACTIVE_SU"
    echo "# according to your preferences"
    echo "#"
    echo "sus_su=7"
    echo "sus_su_active=7"
    echo "hide_cusrom=1"
    echo "hide_vendor_sepolicy=1"
    echo "hide_compat_matrix=1"
    echo "hide_gapps=1"
    echo "hide_revanced=1"
    echo "spoof_cmdline=1"
    echo "hide_loops=1"
    echo "force_hide_lsposed=1"
    echo "spoof_uname=2"
    echo "fake_service_list=0"
    echo "susfs_log=0"
} > "$SUSF/config.sh"
echo "#" >> $SUSF/config.sh
echo "#" >> $SUSF/config.sh
echo "# Last updated on $(date '+%A %d/%m/%Y %I:%M:%S%p')" >> $SUSF/config.sh
log "✅ Config file generated."
chmod 644 "$SUSF/config.sh"
echo " "
sleep 1

echo "▬▬▬.◙.▬▬▬"
echo "═▂▄▄▓▄▄▂"
echo "◢◤ █▀▀████▄▄▄▄◢◤"
echo "█▄ █ █▄ ███▀▀▀▀▀▀▀╬"
echo "◥█████◤"
echo "══╩══╩═"
echo "╬═╬"
echo "╬═╬"
echo "╬═╬"
echo "╬═╬"
echo "╬═╬☻/ Finishing installation"
echo "╬═╬/▌ 👋 Bye - Bye "
echo "╬═╬/ \ "
echo " "
sleep 1

# Final User Prompt
log "💥 Reboot your device to apply changes!"
log "💥 Smash The Action Button After Rebooting"
echo " "
echo " "
log "====== Installation Completed ======"
log " "
log " " 

# Redirect Module Release Source and Finish Installation
nohup am start -a android.intent.action.VIEW -d https://t.me/MeowRedirect/210 >/dev/null 2>&1 &
MEOW "This module was released by 𝗠𝗘𝗢𝗪 𝗗𝗨𝗠𝗣"
exit 0
# End Of File