#!/system/bin/sh

D="/data/adb/Integrity-Box"
L="$D/Integrity-Box.log"
MODPATH="${0%/*}"
NOTDIR="/data/adb/modules_update/Integrity-Box"
R="════════════════════════════"
Q="--------------------------------------------"

mkdir -p "$D"

log() { echo -e "$1" | tee -a "$L"; }

# Check for the correct directory
if [ ! -d "$MODPATH" ] && [ ! -f "$MODPATH/abnormal.sh" ]; then
    log "MODPATH not found or abnormal.sh not found in $MODPATH. Trying NOTDIR instead."
    MODPATH="$NOTDIR"
fi

# If MODPATH is invalid, exit the script
if [ ! -d "$MODPATH" ] || [ ! -f "$MODPATH/abnormal.sh" ]; then
    log "Error: Neither MODPATH ($MODPATH) nor NOTDIR ($NOTDIR) contains abnormal.sh!"
    exit 1
fi

log "Found module in: $MODPATH"

# Ensure the scripts are executable
for script in abnormal.sh prop.sh app.sh; do
    chmod +x "$MODPATH/$script"
    if [ ! -x "$MODPATH/$script" ]; then
        log "Error: $script is not executable or not found in $MODPATH!"
        exit 1
    fi
done

# Detect Key Press
CheckKey() {
    key=$(timeout 10s getevent -qlc 1 | awk '/KEY_/ {print $3; exit}')
    echo "${key:-AUTO}"
}

ask_execute() {
    log "$R"
    log "$1"
    log "🔹(Volume Up = Yes | Volume Down = No)"
    log "$R"
    log " "
#    log " "
#    log " "

    case $(CheckKey) in
        KEY_VOLUMEUP) 
            log "   ✅ Running..."; 
            "$MODPATH/$2" ;; 
        KEY_VOLUMEDOWN) 
            log "   ❌ Skipped" ;;
        *) 
            log "   ⏳ No response! Auto-executing..."; 
            "$MODPATH/$2" ;;  
    esac
}

# run scripts in sequence
ask_execute "🔍 Abnormal Activity Detection" "abnormal.sh"
ask_execute "🛠️ System Property Detection" "prop.sh"
ask_execute "⚠️ Risky App Detection" "app.sh"

log "$Q"
log "✅ Scanning Complete!"
log "Check $L for logs"
log "$Q"
log " "
