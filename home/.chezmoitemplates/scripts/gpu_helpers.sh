#!/usr/bin/env bash
# GPU detection helpers
# vim: set expandtab ft=bash ts=4 tw=4:

# Print how NVIDIA hardware is used on this machine (reads sysfs, needs no pciutils):
#   display -- an NVIDIA card drives the boot display (boot_vga=1)
#   compute -- NVIDIA card(s) present but the display runs elsewhere (iGPU), e.g. CUDA boxes
#   none    -- no NVIDIA display controller (PCI vendor 0x10de, class 0x03xxxx)
# Usage: [[ "$(nvidia_gpu_mode)" == display ]]
nvidia_gpu_mode() {
  local dev mode=none
  for dev in /sys/bus/pci/devices/*; do
    [[ "$(cat "$dev/vendor" 2>/dev/null)" == 0x10de ]] || continue
    [[ "$(cat "$dev/class" 2>/dev/null)" == 0x03* ]] || continue
    if [[ "$(cat "$dev/boot_vga" 2>/dev/null)" == 1 ]]; then
      echo display
      return
    fi
    mode=compute
  done
  echo "$mode"
}
