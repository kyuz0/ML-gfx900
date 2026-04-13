#!/usr/bin/env bash
# Lightweight banner for MI25 (gfx900) ComfyUI edition

# Only show for interactive shells
case $- in *i*) ;; *) return 0 ;; esac

oem_info() {
  local v="" m="" d lv lm
  for d in /sys/class/dmi/id /sys/devices/virtual/dmi/id; do
    [[ -r "$d/sys_vendor" ]] && v=$(<"$d/sys_vendor")
    [[ -r "$d/product_name" ]] && m=$(<"$d/product_name")
    [[ -n "$v" || -n "$m" ]] && break
  done
  printf '%s %s\n' "${v:-Unknown}" "${m:-Unknown}"
}

gpu_name() {
  local name=""
  if command -v rocm-smi >/dev/null 2>&1; then
    name=$(rocm-smi --showproductname --csv 2>/dev/null | tail -n1 | cut -d, -f2)
    [[ -z "$name" ]] && name=$(rocm-smi --showproductname 2>/dev/null | grep -m1 -E 'Product Name|Card series' | sed 's/.*: //')
  fi
  if [[ -z "$name" ]] && command -v lspci >/dev/null 2>&1; then
    name=$(lspci -nn 2>/dev/null | grep -Ei 'vga|display|gpu|3d' | grep -i amd | head -n1 | cut -d: -f3-)
  fi
  if [[ -z "$name" ]] && command -v amd-smi >/dev/null 2>&1; then
    name=$(amd-smi | grep -Eo 'Instinct MI[0-9]+|Radeon Instinct MI[0-9]+' | head -1)
  fi
  name=$(printf '%s' "$name" | sed -e 's/^[[:space:]]\+//' -e 's/[[:space:]]\+$//' -e 's/[[:space:]]\{2,\}/ /g')
  printf '%s\n' "${name:-Unknown AMD GPU}"
}

rocm_version() {
  cat /opt/rocm/.info/version 2>/dev/null || echo "Unknown"
}

MACHINE="$(oem_info)"
GPU="$(gpu_name)"
ROCM_VER="$(rocm_version)"

echo
cat <<'ASCII'
   ____                  __        _    _ _____ 
  / __ \                / _|      | |  | |_   _|
 | |  | | ___  _ __ ___| |_ _   _ | |  | | | |  
 | |  | |/ _ \| '_ ` _ \  _| | | || |  | | | |  
 | |__| | (_) | | | | | | | | |_| || |__| _| |_ 
  \____/ \___/|_| |_| |_|_|  \__, | \____/_____|
                              __/ |             
                             |___/              
ASCII
echo
printf 'AMD MI25 — ComfyUI Toolbox (gfx900/Vega10 compiled)\n'
[[ -n "$ROCM_VER" ]] && printf 'ROCm Base: %s\n' "$ROCM_VER"
echo
printf 'Machine: %s\n' "$MACHINE"
printf 'GPU    : %s\n\n' "$GPU"
printf 'Repo   : https://github.com/kyuz0/ML-gfx906\n\n'
printf 'Included Utilities:\n'
printf '  - %-20s → %s\n' "start-comfy" "Interactive TUI launcher: Select GPU targets and VRAM tuning"
echo
printf 'Note: PyTorch CUDA Allocator expanded segments enabled for Vega fragmentation mitigations.\n\n'

export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"
export HSA_OVERRIDE_GFX_VERSION="9.0.0"

unset PROMPT_COMMAND
PS1='\u@\h:\w\$ '
