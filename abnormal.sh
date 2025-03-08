#!/system/bin/sh

L="/data/adb/Integrity-Box/detection.log"
TIME=$(date "+%Y-%m-%d %H:%M:%S")
Q="------------------------------------------"
R="════════════════════════════"

log() {
    echo -e "$1" | tee -a "$L"
}

# Clear log and start with timestamp
echo -e "$Q" > "$L"
echo -e " 📌 SECURITY CHECK | $TIME " >> "$L"
echo -e "$Q\n" >> "$L"

### ROM SIGN CHECK ###
log "🔹 ROM Verification"
ROM_TYPE="✅ Not Found"
unzip -l /system/etc/security/otacerts.zip | grep -q "testkey" && ROM_TYPE="⚠️ testkey (Unverified)" 
unzip -l /system/etc/security/otacerts.zip | grep -q "releasekey" || ls "/system/etc/fsverity" | grep -q "release" && ROM_TYPE="✅ releasekey (Verified)" 
log "   └─ ROM Sign: $ROM_TYPE"
log "$Q"
log " "

### CUSTOM ROM DETECTION ###
CUSTOM_ROM_COUNT=$(find /system /vendor /product /data -type f -iname "*lineage*" -o -iname "*crdroid*" 2>/dev/null | tee -a "$L" | wc -l)
[ "$CUSTOM_ROM_COUNT" -gt 0 ] && echo "Detected custom ROM"
log "   └─ Detection count: $CUSTOM_ROM_COUNT"
log "$Q"
log " "

### SECURITY STATUS ###
log "🔹 Security Status"
log "   └─ SELinux: $(getenforce | tr '[:upper:]' '[:lower:]')"
log "$Q"
log " "

### ROOT DETECTION ###
echo "🔹 Root & Magisk Checks"
ROOT_STATUS="No root detected"
MAGISK_STATUS="No Magisk detected"
KSU_STATUS="No KernelSU detected"

# Root detection
[ -f "/system/bin/su" ] || [ -f "/system/xbin/su" ] || [ -f "/sbin/su" ] && ROOT_STATUS="Rooted👀"

# Magisk detection
[ -f "/sbin/.magisk" ] || [ -d "/data/adb/magisk" ] || [ -d "/data/adb/modules" ] && MAGISK_STATUS="Found🙉"

# KernelSU detection
[ -d "/data/adb/ksu" ] || [ -f "/data/adb/ksud" ] && KSU_STATUS="Detected💀"

echo "   ├─ Root Access: $ROOT_STATUS"
echo "   ├─ Magisk: $MAGISK_STATUS"
echo "   └─ KernelSU: $KSU_STATUS"
log "$Q"
log " "

### DANGEROUS SYSTEM PROPERTIES ###
log "🔹 Dangerous System Properties"
DANGEROUS_PROPS=$(grep -E "ro.debuggable=1|ro.secure=0" /system/build.prop)
[ -n "$DANGEROUS_PROPS" ] && log "   └─ ⚠️ Found:\n$DANGEROUS_PROPS" || log "   └─ ✅ Not Found"
log "$Q"
log " "

### UNAUTHORIZED REMOTE CONNECTIONS ###
log "🔹 Remote Connection Detection"
REMOTE_CONNECTIONS=$(netstat -antp | grep "ESTABLISHED" | grep -v "127.0.0.1")
if [ -n "$REMOTE_CONNECTIONS" ]; then
    echo "Warning: Remote Connection Detected!"
    log "   └─ ⚠️ Active Remote Connections:\n$REMOTE_CONNECTIONS"
else
    log "   └─ ✅ Not Found"
fi
log "$Q"
log " "

### TAMPERED FILES ###
log "🔹 System File Integrity"
TAMPERED_FILES=""
for file in /system/lib/libc.so /system/bin/sh /system/bin/app_process; do
    [ -f "$file" ] && md5sum "$file" | grep -qv "official_md5sum_here" && TAMPERED_FILES+="$file\n"
done
if [ -n "$TAMPERED_FILES" ]; then
    echo "Detected Tampered Files ($(echo -e "$TAMPERED_FILES" | wc -l))"
    log "   └─ ⚠️ Modified System Files:\n$TAMPERED_FILES"
else
    log "   └─ ✅ Not Found"
fi
log "$Q"
log " "

### VPN/PROXY DETECTION ###
log "🔹 VPN/Proxy Detection"
VPN_STATUS="✅ Not Found"
PROXY_STATUS="✅ Not Found"
ip route | grep -q "tun0" && VPN_STATUS="⚠️ Active"
ps -A | grep -q "proxydroid" && PROXY_STATUS="⚠️ Active"
log "   ├─ VPN: $VPN_STATUS"
log "   └─ Proxy: $PROXY_STATUS"
log "$Q"
log " "

### CLIPBOARD MONITORING ###
log "🔹 Clipboard Monitoring"
dumpsys activity service ClipboardService | grep -q "hasPrimaryClip=true" && log "   └─ ⚠️ Detected!" || log "   └─ ✅ Not Found"
log "$Q"
log " "

### FAKE GPS DETECTION ###
log "🔹 GPS Spoofing"
dumpsys location | grep -q "mock" && log "   └─ ⚠️ Detected!" || log "   └─ ✅ Not Found"
log "$Q"
log " "

### UNTRUSTED CA CERTIFICATES ###
log "🔹 Untrusted CA Certificates"
UNTRUSTED_CA=$(ls /system/etc/security/cacerts | grep -q "untrusted")
[ -n "$UNTRUSTED_CA" ] && log "   └─ ⚠️ Detected!" || log "   └─ ✅ Not Found"
log "$Q"
log " "

### FINAL MESSAGE ###
log "✅ Detection Complete!\n"
echo -e "$R" >> "$L"