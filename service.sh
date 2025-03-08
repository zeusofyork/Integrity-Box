#!/system/bin/sh
# 🐱 Meow Meow
MEOW() {
    am start -a android.intent.action.MAIN -e mona "$@" -n meow.helper/.MainActivity &>/dev/null
    sleep 0.5
}

MCTRL="${0%/*}"; WHITELIST="/data/adb/shamiko/whitelist"
while true; do
 if [ ! -e "${MCTRL}/disable" ] && [ ! -e "${MCTRL}/remove" ]; then
  [ ! -f "$WHITELIST" ] && touch "$WHITELIST" && MEOW "Whitelist Mode Activated.✅"
 else
  [ -f "$WHITELIST" ] && rm "$WHITELIST" && MEOW "Blacklist Mode Activated.❌"
 fi
 sleep 4
done

# Define module path dynamically
export MODPATH="/data/adb/modules/Integrity-Box"

# Remove LineageOS properties
resetprop --delete ro.lineage.build.version
resetprop --delete ro.lineage.build.version.plat.rev
resetprop --delete ro.lineage.build.version.plat.sdk
resetprop --delete ro.lineage.device
resetprop --delete ro.lineage.display.version
resetprop --delete ro.lineage.releasetype
resetprop --delete ro.lineage.version
resetprop --delete ro.lineage.legal.url

# Extract and process relevant properties
getprop | grep "userdebug" >> "$MODPATH/tmp.prop"
getprop | grep "test-keys" >> "$MODPATH/tmp.prop"
getprop | grep "lineage_"  >> "$MODPATH/tmp.prop"

# Format extracted properties
sed -i 's///g'  "$MODPATH/tmp.prop"
sed -i 's///g'  "$MODPATH/tmp.prop"
sed -i 's/: /=/g' "$MODPATH/tmp.prop"

# Modify specific property values
sed -i 's/userdebug/user/g' "$MODPATH/tmp.prop"
sed -i 's/test-keys/release-keys/g' "$MODPATH/tmp.prop"
sed -i 's/lineage_//g' "$MODPATH/tmp.prop"

# Sort and finalize system.prop
sort -u "$MODPATH/tmp.prop" > "$MODPATH/system.prop"
rm -f "$MODPATH/tmp.prop"

# Apply the modified properties
sleep 10 
resetprop -n --file "$MODPATH/system.prop"