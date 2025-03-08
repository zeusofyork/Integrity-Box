#!/bin/sh

# Path to module and JSON files
MODDIR=/data/adb/modules/playintegrityfix
PIF_PATH="$MODDIR/pif.json"
PIF_FORK_PATH="$MODDIR/custom.pif.json"
D="/data/adb/Integrity-Box"
L="$D/Integrity-Box.log"

# meow meow 
MEOW() {
    am start -a android.intent.action.MAIN -e mona "$@" -n meow.helper/.MainActivity &>/dev/null
    sleep 0.5
}

# Logging Function
log() { echo -e "$1" | tee -a "$L"; }

# Function to create backup
create_backup() {
    local json_file=$1
    local backup_file="${json_file}.bak"
    
    cp "$json_file" "$backup_file"
    log "🌟 Backup created"
}

# Function to restore backup
restore_backup() {
    local json_file=$1
    local backup_file="${json_file}.bak"

    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$json_file"
        log "🌟 Backup restored"
    else
        log "🍳 Skipped"
    fi
}

# Function to check and update fingerprint
update_json() {
    local json_file=$1
    local spoof_value=$2

    # Create a backup before making any changes
    create_backup "$json_file"

    if [ ! -f "$json_file" ]; then
        exit 1
    fi

    if [ "$spoof_value" -eq 0 ]; then
        # Remove spoofVendingSdk entry when value is 0
        sed -i '/"spoofVendingSdk":/d' "$json_file"
        sed -i '/\/\/ This key is used to spoof Vending SDK for compatibility purposes./d' "$json_file"
        MEOW "spoofVendingSdk removed from $json_file"
    else
        # If the value is not 0, update the spoofVendingSdk entry
        if grep -q '"spoofVendingSdk":' "$json_file"; then
            current_value=$(grep '"spoofVendingSdk":' "$json_file" | awk -F': ' '{print $2}' | tr -d ',')

            if [ "$current_value" -eq "$spoof_value" ]; then
                return
            else
                sed -i '/"spoofVendingSdk":/d' "$json_file"
            fi
        fi

        if [ "$json_file" == "$PIF_FORK_PATH" ]; then
            sed -i '/}/i \ \n     "spoofVendingSdk": '$spoof_value',' "$json_file"
            sed -i '/}/i \ \n  // This key is used to spoof Vending SDK for compatibility purposes.' "$json_file"
            MEOW "spoofVendingSdk added to custom.pif.json"
        else
            sed -i '/}/i \  "spoofVendingSdk": '$spoof_value',' "$json_file"
            sed -i '/}/i \  // This key is used to spoof Vending SDK for compatibility purposes.' "$json_file"
            MEOW "spoofVendingSdk added to pif.json"
        fi
    fi
}

# Display Options
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "   [➕]  Enable spoofVendingSdk"
log "   [➖]  Disable spoofVendingSdk"
log "   [🔴]  Cancel and exit"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log " "

# Choose the fp file 
if [ -f "$PIF_FORK_PATH" ]; then
    json_file=$PIF_FORK_PATH
else
    json_file=$PIF_PATH
fi

# Key press handling 
key_handler() {
    local result

    while true; do
        keys=$(getevent -lqc1)

        if echo "$keys" | grep -q 'KEY_VOLUMEUP.*DOWN'; then
            result=1
            break
        elif echo "$keys" | grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
            result=0
            break
        elif echo "$keys" | grep -q 'KEY_POWER.*DOWN'; then
            exit 0
        fi
        sleep 1
    done

    return $result
}

# Wait for key input and get the selected value
key_handler
spoofVendingSdk_value=$?

# If Volume Down is pressed, restore the backup
if [ "$spoofVendingSdk_value" -eq 0 ]; then
    restore_backup "$json_file"
else
    # Update the fp with the selected value
    update_json "$json_file" $spoofVendingSdk_value
fi
exit 0