#!/system/bin/sh

# Paths
LOG="/data/adb/Integrity-Box"
LOGFILE="$LOG/Integrity-Box.log"
TARGET_DIR="/data/adb/tricky_store"
FILE_PATH="$TARGET_DIR/security_patch.txt"
FILE_CONTENT="all=2025-02-02"

# Ensure directories exist
mkdir -p "$LOG"
mkdir -p "$TARGET_DIR"

# Logging function
log() { echo -e "$1" | tee -a "$LOGFILE"; }

# MeowMeow
MEOW() { am start -a android.intent.action.MAIN -e mona "$@" -n meow.helper/.MainActivity >/dev/null 2>&1; sleep 0.5; }

# Function to Detect Key Press
CheckKey() {
  while true; do
    key=$(getevent -qlc 1 | awk '/KEY_/ {print $3; exit}')
    case $key in
      KEY_VOLUMEUP|KEY_VOLUMEDOWN|KEY_POWER) echo "$key"; return ;;
    esac
    sleep 0.1
  done
}

# Select App Type
log "🎯 Choose Target Apps"
log "\n📢 Select target apps:"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "   [➕]  All apps (System + User)"
log "   [➖]  Installed apps only"
log "   [🔴]  Skip this step"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " "

case $(CheckKey) in
  KEY_VOLUMEUP) 
    log "✅ Selected: All apps"
    MEOW "Adding ALL APPS into 🎯 Target list"
    /bin/sh /data/adb/modules/Integrity-Box/systemuser.sh
    ;;
  KEY_VOLUMEDOWN) 
    log "✅ Selected: Installed apps only"
    MEOW "Adding only USER APPS into 🎯 Target list"
    /bin/sh /data/adb/modules/Integrity-Box/user.sh
    ;;
  KEY_POWER) 
    log "⏭️ Skipping app selection..."
    MEOW "⏭️ Skipped Step 1"
    ;;
esac

sleep 1

#: Security Patch Spoofing
log "For A13+ checks only"
log "\n📢 Security Patch Hack Options:"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "   [➕]  Spoof security patch"
log "   [➖]  Remove spoofed patch"
log "   [🔴]  Cancel operation"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " "
log "(Apply only if you were not able to pass A13+ checks)"
log " "
log "This is for old devices only"
log "You can skip & update it later"
log "using action button"
log " "

case $(CheckKey) in
  KEY_VOLUMEUP) 
    echo "$FILE_CONTENT" > "$FILE_PATH"
    log "✅ Security patch spoofed successfully!"
    MEOW "✅ Spoof applied!"
    ;;
  KEY_VOLUMEDOWN) 
    rm -f "$FILE_PATH"
    log "🗑️ Spoof removed!"
    MEOW "🗑️ File removed!"
    ;;
  KEY_POWER) 
    log "❌ Operation canceled!"
    MEOW "❌ Canceled!"
    exit 1 ;;
esac

log " "