#!/system/bin/sh

TARGET_PROCESS="com.google.android.gms.unstable"

PID=$(pidof "$TARGET_PROCESS")

if [ -n "$PID" ]; then
    echo "[+] Found PID(s): $PID"
    kill -9 $PID
    echo "[+] Killed $TARGET_PROCESS"
else
    echo "[-] $TARGET_PROCESS not running"
fi
