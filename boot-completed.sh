#!/usr/bin/env bash
# Disable LSPosed log spam
tags=("LSPosed" "LSPosed-Bridge")
for tag in "${tags[@]}"; do
  setprop persist.log.tag."${tag}" S
done