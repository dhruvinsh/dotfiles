# `apollo` — dmesg audit & remediation

Boot log audit of **apollo** (MSI B450 Gaming Pro Carbon AC, Ryzen 5 3600X, 32 GB,
RTX 2060 SUPER, Linux 6.18.55-1-lts). Source: `dmesg.txt`, captured 2026-10-08.
Line references point into that capture.

Status legend: **DONE** · **SCRIPTED** (fixed in this repo, applies on next
`chezmoi apply`) · **ACTION** (yours) · **WATCH** (monitor, no fix yet) · **WONTFIX**.

---

## Summary

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | `regulatory.db` missing → WiFi on world regdomain | Medium | **DONE** |
| 2 | `options bluetooth power_save=0` is not a real parameter | Medium | **SCRIPTED** |
| 2b | `options usbcore autosuspend=-1` is dead code (usbcore is builtin) | Medium | **SCRIPTED** |
| 2c | WiFi/BT coexistence on the combo AC 9260 radio | Medium | **SCRIPTED** |
| 2d | Wi-Fi pinned to 5 GHz to clear Bluetooth's band | Medium | **SCRIPTED** |
| 3 | BIOS 1.H4 (09/2024) — several firmware bugs | Medium | **ACTION** |
| 4 | Kernel tainted: out-of-tree + unsigned NVIDIA module | Low | **ACTION** (decide) |
| 4b | `nvidia-suspend/resume.service` disabled w/ VRAM preservation on | Medium | **ACTION** |
| 5 | `ucsi_ccg` probe fails `-110` on the GPU USB-C port | Low | **SCRIPTED** |
| 6 | ALC1220 codec: no board fixup (null SSID `1462:0000`) | Low | **WONTFIX** (for now) |
| 7 | Razer Seiren V3 Mini dropped off the bus at runtime | Low | **WATCH** |
| 8 | IOMMU group 15 lumps chipset + NIC + WiFi together | Low | **WONTFIX** |
| 9 | ACPI/firmware bugs (`_OSI`, ECAM, `_DSM`, x2apic) | Low | **ACTION** (same as #3) |
| 10 | `ata2.00: Invalid log directory version 0x0000` | Info | **RESOLVED** — no impact; drive healthy |
| 11 | Staggered spin-up, MSI off on HDMI audio, NVMe NGUID | Info | **WONTFIX** |
| — | GPU PCIe link at 2.5 GT/s | None | **Not a bug** |

---

## 1. Missing wireless regulatory database — DONE

```text
dmesg.txt:1041  faux_driver regulatory: Direct firmware load for regulatory.db failed with error -2
dmesg.txt:1042  cfg80211: failed to load regulatory.db
```

`-2` = `ENOENT`. The signing certs are compiled into the kernel but
`/lib/firmware/regulatory.db` was absent — `wireless-regdb` wasn't installed. WiFi fell
back to the world regdomain: reduced TX power, no high/DFS 5 GHz channels.

**Fix:** `pacman -S wireless-regdb` — *installed.*

> Also added to the package list in
> `home/.chezmoiscripts/arch/run_onchange_before_11_install-arch-packages.sh.tmpl:106`
> so a fresh install doesn't regress. Takes effect on next boot — `cfg80211` reads the
> DB once at module init, and this boot already failed that read.

---

## 2. Bluetooth stability — SCRIPTED

### 2a. The `power_save` option never existed

```text
dmesg.txt:1031  bluetooth: unknown parameter 'power_save' ignored
```

`run_once_after_bluetooth-setup.sh.tmpl` wrote `options bluetooth power_save=0`. Verified
against the running kernel:

| Module | Actual parameters |
|--------|-------------------|
| `bluetooth` | `disable_esco`, `disable_ertm`, `enable_ecred` |
| `btusb` | `disable_scofix`, `force_scofix`, `enable_autosuspend`, `reset` |

Neither has `power_save`, so the line was silently discarded for the life of the config.
`disable_ertm=1` **was** working (`/sys/module/bluetooth/parameters/disable_ertm` = `Y`).

The real knob is on `btusb`, and it was at its permissive default:

```console
$ cat /sys/module/btusb/parameters/enable_autosuspend
Y
$ # Intel BT radio at usb 5-4 (8087:0025):
$ cat /sys/bus/usb/devices/5-4/power/control
auto          # ← radio allowed to sleep
```

**Fix** (`/etc/modprobe.d/bluetooth.conf`, written by the script):

```text
options btusb enable_autosuspend=0
options bluetooth disable_ertm=1
```

### 2b. `usbcore autosuspend=-1` was dead code

`run_onchange_before_11_install-arch-packages.sh.tmpl` created
`/etc/modprobe.d/disable-usb-autosuspend.conf` with `options usbcore autosuspend=-1`.
But:

```console
$ modinfo usbcore | head -2
name:     usbcore
filename: (builtin)
$ cat /sys/module/usbcore/parameters/autosuspend
2             # ← still the 2s default, drop-in ignored
```

`usbcore` is compiled into the Arch kernel, so `modprobe.d` is never consulted for it.
Built-in modules only accept parameters from the **kernel command line**.

**Fix:** the script now removes the useless drop-in and appends
`usbcore.autosuspend=-1` to `GRUB_CMDLINE_LINUX` in `/etc/default/grub`, then runs
`grub-mkconfig`. Verified on a copy:

```text
before: GRUB_CMDLINE_LINUX="zswap.enabled=0 rootfstype=btrfs"
after:  GRUB_CMDLINE_LINUX="zswap.enabled=0 rootfstype=btrfs usbcore.autosuspend=-1"
```

Takes effect **on next boot**. `GRUB_CMDLINE_LINUX_DEFAULT` is left untouched.

### 2c. WiFi/Bluetooth coexistence — the "headphones + WiFi" symptom

This is the root cause of *"sometimes just connecting headphone with wifi causes issues."*

The Intel Wireless-AC 9260 is a **combo radio**. Its two halves appear as separate
devices but share one 2.4 GHz front end and time-slice it:

| Half | Device | dmesg |
|------|--------|-------|
| WiFi | PCIe `8086:2526` @ `0000:21:00.0` | `dmesg.txt:1064` |
| Bluetooth | USB `8087:0025` @ `usb 5-4` | `dmesg.txt:847` |

When the WiFi side enters power save, coexistence scheduling becomes bursty and A2DP
stutters. `iwlmvm` was on the balanced scheme:

```console
$ cat /sys/module/iwlmvm/parameters/power_scheme
2             # 1=active, 2=balanced (default), 3=low power
```

**Fix** (`/etc/modprobe.d/iwlwifi.conf`, new, written by the script):

```text
options iwlmvm power_scheme=1
options iwlwifi power_save=0
```

> `bt_coex_active` must stay at its default (`Y`). Guides that say to set
> `bt_coex_active=0` assume *separate* radios; on a combo card it makes audio worse.

**Also worth doing (your call):**

- apollo is on wired gigabit (`enp34s0`, `dmesg.txt:1140`) and `wlan0` is currently
  `DOWN`. If you don't need WiFi, `rfkill block wifi` gives Bluetooth the whole 2.4 GHz
  front end — the single most effective fix available.
- If you do use WiFi, **put it on 5 GHz**. That takes it out of Bluetooth's band
  entirely. The 9260 is 160 MHz capable.
- For the *multi-device* case (headphones + controller): both compete for the same
  Bluetooth airtime. `disable_ertm=1` is already the right setting for Xbox-style
  controllers. If stutter persists with both connected, pin the headset to SBC rather
  than LDAC/aptX-HD via a WirePlumber drop-in — no `~/.config/wireplumber/` exists yet,
  so defaults are in use. Say the word and I'll add it as a managed dotfile.

### 2d. Pinning Wi-Fi to 5 GHz

The cleanest fix for the coexistence problem is to vacate the band entirely. Done at the
**iwd** layer rather than NetworkManager's, and the distinction matters:

| Lever | Effect | Still scans 2.4 GHz? |
|---|---|---|
| NM `802-11-wireless.band a` | filters which AP it *associates* with | **yes** |
| iwd `BandModifier2_4GHz=0.0` | disables the band outright | **no** |

A periodic 2.4 GHz scan steals airtime from Bluetooth exactly like an association does,
so it shows up as a recurring blip in A2DP audio. Only the iwd setting stops that.
Quoting `iwd.config(5)` directly:

> A value of 0.0 will disable the 2.4GHz band and prevent scanning or connecting on
> those frequencies.

**Fix** (`/etc/iwd/main.conf`, new, written by
`run_once_after_networking-setup.sh.tmpl` — which already owns the iwd backend config):

```ini
[Rank]
BandModifier2_4GHz=0.0
```

Desktop-only, same reasoning as the rest: a laptop wants 2.4 GHz as a range and
compatibility fallback. Raise the value to ~`0.3` to demote the band instead of killing
it — but note it will resume scanning at any non-zero value.

The script bounces `iwd` after writing, since iwd reads `main.conf` only at startup and
restarting NetworkManager does not restart an already-running iwd.

**Per-network alternative**, if you ever want this for one SSID rather than globally
(`802-11-wireless.band` is exposed by NM even on the iwd backend — verified):

```console
nmcli connection modify <name> 802-11-wireless.band a
```

There are currently **no saved Wi-Fi connections** on this machine, so nothing needed
migrating.

### Hardware gate on the networking script

`run_once_after_networking-setup.sh.tmpl` is scoped to machines actually carrying the
Intel Wireless-AC 9260 (PCI `8086:2526`). Everything in it is tuned around that card
being a *combo* radio, so it shouldn't leak onto a machine with different wireless
hardware.

```gotemplate
{{- $hasAc9260 := "" -}}
{{- if eq .chezmoi.os "linux" -}}
{{-   $hasAc9260 = output "sh" "-c" "for d in /sys/bus/pci/devices/*/; do [ \"$(cat $d/vendor 2>/dev/null)\" = 0x8086 ] && [ \"$(cat $d/device 2>/dev/null)\" = 0x2526 ] && echo yes; done; true" -}}
{{- end -}}

# {{- if and (eq .archlinux true) (contains "yes" $hasAc9260) }}
```

Design notes:

- **Follows the card, not the hostname.** Move the AC 9260 into another box and the
  config moves with it; swap a different card into apollo and the script stops applying.
- **sysfs, not `lspci`** — no `pciutils` dependency.
- **Trailing `true`** is load-bearing: `output` aborts the entire render on a non-zero
  exit, and a `for` loop that matches nothing would otherwise exit non-zero.
- **`.chezmoi.os` check** keeps `sh` off the path on Windows, where `/sys` doesn't exist.
  (`.chezmoiignore.tmpl` already skips `arch/**` there, but the guard costs nothing.)
- The inner `chassisType == "desktop"` guard on the 5 GHz pin **stays** — the AC 9260
  shipped in a great many laptops, where a hard 2.4 GHz disable would be wrong.

Verified across all four combinations:

| arch | AC 9260 | chassis | Result |
|------|---------|---------|--------|
| ✓ | ✓ | desktop | full script, 90 lines — iwd backend **+** 5 GHz pin |
| ✓ | ✓ | laptop | iwd backend only, 5 GHz pin dropped |
| ✓ | ✗ | — | 5-line no-op stub |
| ✗ | ✓ | — | 5-line no-op stub |

Rendered output passes `shellcheck -S warning` clean and the repo's own
`scripts/chezmoi-template-check.bash`.

### Script bugs fixed along the way

`run_once_after_bluetooth-setup.sh.tmpl` also had a **latent section bug**: when a key
wasn't already present in `main.conf`, the fallback inserted it under `[General]`. That's
correct for `Experimental` but wrong for `AutoEnable`, which BlueZ reads from
`[Policy]`. It happened to work on this machine only because BlueZ ships
`#AutoEnable=true` already commented out in the right section. Rewritten as a
section-aware `set_key()`; verified against the live file (no-op), a pristine packaged
`main.conf` (correct placement), and a file with no `[Policy]` section at all — all
idempotent.

---

## 3 & 9. BIOS / ACPI firmware bugs — ACTION

BIOS is **1.H4, dated 09/03/2024** (`dmesg.txt:58`). Complaints in the log:

```text
dmesg.txt:313   ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
dmesg.txt:324   acpi PNP0A08:00: [Firmware Info]: ECAM ... only partially covers this bridge
dmesg.txt:214   x2apic: IRQ remapping doesn't support X2APIC mode
dmesg.txt:213   AMD-Vi: Using global IVHD EFR:0x0, EFR2:0x0
dmesg.txt:1060  ACPI: failed to evaluate _DSM 2c176672-... (0x1001)
dmesg.txt:1061  ACPI: failed to evaluate _DSM 2c176672-... (0x1001)
dmesg.txt:1139  ACPI: failed to evaluate _DSM bf0212f2-... (0x1001)
dmesg.txt:1023  ccp 0000:28:00.1: unable to access the device: you might be running a broken BIOS.
```

The `ccp` one has a real consequence — the AMD PSP crypto co-processor is unreachable,
so there is **no hardware RNG registered at all** (the TPM's is deliberately off in
modern kernels, `dmesg.txt:662`):

```console
$ cat /sys/class/misc/hw_random/rng_available
none
```

Not dangerous — the CRNG seeded fine from the EFI RNG protocol at `dmesg.txt:38` — but
you also lose CCP crypto offload.

**ACTION:** flash the latest BIOS/AGESA. Re-capture `dmesg` afterwards and diff; several
of the above may clear. Note MSI resets CMOS on flash, so re-check: XMP/DOCP profile,
SVM (for KVM), IOMMU, Above-4G decoding, and the boot order.

---

## 4. Kernel taint & NVIDIA — ACTION (decide)

```text
dmesg.txt:869  nvidia: loading out-of-tree module taints kernel.
dmesg.txt:870  nvidia: module verification failed: signature and/or required key missing
dmesg.txt:74   Secure boot disabled
```

`/proc/sys/kernel/tainted` = `12288` = bit 12 (`OOT_MODULE`) + bit 13
(`UNSIGNED_MODULE`). This is **cosmetic and completely expected** for `nvidia-open-dkms`.
It only matters if you file a kernel bug upstream — maintainers will ask you to reproduce
untainted.

You have two honest options:

1. **Do nothing.** The taint is informational. This is what the overwhelming majority of
   Arch + NVIDIA desktops run. ← recommended unless you want Secure Boot
2. **Enable Secure Boot and sign the modules.** You already have the infrastructure —
   five valid db certs loaded at `dmesg.txt:789-797`, including `MSI SHIP DB`. The path
   is `sbctl` for the kernel/bootloader plus a DKMS MOK signing hook so rebuilt NVIDIA
   modules get signed automatically. Bit 12 (`OOT_MODULE`) stays set either way; only
   bit 13 clears. Worth doing **after** the BIOS flash, not before — flashing resets
   Secure Boot state.

### 4b. Suspend/resume gap — worth fixing

The driver has VRAM preservation on, but the units that use it are all disabled:

```console
$ cat /sys/module/nvidia/parameters/NVreg_PreserveVideoMemoryAllocations
1
$ systemctl is-enabled nvidia-suspend nvidia-resume nvidia-hibernate
disabled
disabled
disabled
```

With preservation enabled and no service to save/restore the VRAM image, suspend/resume
can come back with a corrupted or black display. **ACTION** (left for you, since it
changes system state rather than dotfiles):

```console
sudo systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
```

If you never suspend this desktop, skip it.

---

## 5. GPU USB-C port controller probe failure — SCRIPTED

```text
dmesg.txt:1129  nvidia-gpu 0000:26:00.3: i2c timeout error e0000000
dmesg.txt:1130  ucsi_ccg 6-0008: i2c_transfer failed -110
dmesg.txt:1131  ucsi_ccg 6-0008: ucsi_ccg_init failed - -110
dmesg.txt:1132  ucsi_ccg 6-0008: probe with driver ucsi_ccg failed with error -110
```

`-110` = `ETIMEDOUT`. Turing cards expose a USB-C/VirtualLink port behind an
i2c-attached Cypress PD controller; where it isn't wired up, the probe times out every
boot and burns ~700 ms.

**Fix:** `blacklist i2c_nvidia_gpu` added to `/etc/modprobe.d/nvidia.conf` via
`run_onchange_before_13_install-arch-nvidia.sh.tmpl`. Blocking the i2c shim means the
`ucsi_ccg` device is never created in the first place. Remove the line if a USB-C
display or dock is ever plugged into the GPU itself.

> That script had its own bug: it used `tee` rather than `tee -a`, so
> `/etc/modprobe.d/nvidia.conf` could only ever hold the single line it grepped for —
> any second line would be clobbered on the next run. It now manages the file as a whole,
> idempotently.

---

## 6. Onboard audio codec has no board quirk — WONTFIX (for now)

```text
dmesg.txt:1106  snd_hda_codec_alc882 hdaudioC2D0: ALC1220: picked fixup  for PCI SSID 1462:0000
```

Note the **empty fixup name** and subdevice `0x0000` — the board reports a null SSID, so
no MSI-specific quirk matched. Front-panel jack detection, mic boost and the headphone
amp may misbehave.

Not using the front panel jacks, so deferred. If it ever matters: override with
`options snd_hda_intel model=...` or patch the SSID quirk table.

---

## 7. Razer Seiren V3 Mini runtime disconnect — WATCH

```text
dmesg.txt:1147  [ 3895.651490] usb 1-9: USB disconnect, device number 6
dmesg.txt:1148  [ 3899.622481] usb 1-9: new full-speed USB device number 7
```

Dropped ~65 minutes in and re-enumerated 4 s later. The **only** post-boot event in the
whole log.

Ruled out: autosuspend. The device already sits at `power/control = on`, and no TLP or
power-profiles-daemon is installed. So this is electrical or firmware, not power policy.

**No clean kernel fix exists for a single event.** Ranked next steps:

1. Move it to a **rear port on a different controller.** It's currently on the chipset
   xHCI (`0000:03:00.0`) sharing a hub with the Corsair Lighting Node, the H100i and the
   Glove80 — four always-on devices on one bus. The CPU-attached controller
   (`0000:28:00.3`, where the CM310 and the board itself live) has spare capacity.
2. Try a different/shorter cable, and avoid hubs — it enumerates at **full speed**
   (12 Mbit/s), which is marginal and cable-sensitive.
3. If it recurs on another port, add a quirk and see whether it settles:
   `usbcore.quirks=1532:056a:gk` on the kernel cmdline (`g` = delay init, `k` = no LPM).

The `usbcore.autosuspend=-1` fix from §2b also lands here — it won't hurt, and removes
one variable.

**Watch for:** repeat `usb 1-9: USB disconnect` lines. One event isn't a pattern yet.

---

## 8. IOMMU grouping — WONTFIX

```text
dmesg.txt:607-614   iommu group 15 ← 03:00.0 (chipset USB), 03:00.1 (SATA),
                       03:00.2 (switch), 20:00.0, 20:01.0, 20:04.0,
                       21:00.0 (WiFi), 22:00.0 (i210 NIC)
```

The B450 chipset doesn't implement ACS, so everything behind it collapses into one
group. **This is a hardware limitation — there is no software fix** short of running an
ACS-override-patched kernel (not in mainline; `linux-vfio` in the AUR), which is
explicitly unsafe for isolation and not worth it unless you're actually doing passthrough.

**Good news for "you never know":** the parts that matter for passthrough are *already*
cleanly isolated, because they hang off the CPU's own PCIe lanes rather than the chipset:

| Group | Contents | Passthrough-ready? |
|-------|----------|--------------------|
| 14 | `01:00.0` NVMe | ✅ clean |
| 16 | `26:00.0` GPU + `.1` audio + `.2` USB + `.3` UCSI | ✅ clean, textbook GPU group |
| 15 | everything chipset-side | ❌ all-or-nothing |

So a single-GPU-passthrough or NVMe-passthrough VM would work today without any changes.
What you can't do is pass through the onboard NIC or WiFi individually — use a USB NIC or
virtio networking instead. `kvm_amd` already reports nested paging, nested virt and LBR
virtualisation available (`dmesg.txt:1089-1096`).

---

## 10. SATA SSD log directory — RESOLVED, no impact

```text
dmesg.txt:821  ata2.00: Invalid log directory version 0x0000
```

Samsung MZ7LM960HMJP (PM863a), firmware `GXT5104Q`.

**Correction to the original assessment.** I expected this might make `smartctl -l
selftest` unreadable while `-a` still worked. It does not — `smartctl -a` reports:

```text
Error logging capability:  (0x01) Error logging supported.
                                  General Purpose Logging supported.
SMART Error Log Version: 1          -> No Errors Logged
Self-test log structure revision 1  -> No self-tests have been logged.
Selective self-test log ... 255  0  65535  Read_scanning was completed without error
```

GPL is supported and every log reads cleanly. The self-test log is empty because no
self-test has ever been run, not because it can't be read. The kernel message is a
cosmetic libata probe quirk with **no functional consequence**. Nothing to fix.

### Drive health (2026-10-08) — excellent

`SMART overall-health self-assessment test result: PASSED`

| Attribute | Raw | Read |
|---|---|---|
| `Wear_Leveling_Count` | 13 | 13 average P/E cycles. Normalized **99**/100, threshold 5 |
| `Power_On_Hours` | 19,456 | 2.22 years powered |
| `Power_Cycle_Count` | 1,364 | — |
| `Total_LBAs_Written` | 16,208,437,657 | **8.30 TB** host writes (~3.7 TB/yr) |
| `Total_LBAs_Read` | 15,537,271,072 | 7.96 TB |
| `Temperature_Celsius` | 39 | min/max 19/56 °C — fine for a 2.5" enterprise SSD |
| `Unused_Rsvd_Blk_Cnt_Tot` | 3,258 | spare blocks still in hand |

Every failure-mode counter is **zero**: `Reallocated_Sector_Ct`,
`Used_Rsvd_Blk_Cnt_Tot`, `Program_Fail_Cnt_Total`, `Erase_Fail_Count_Total`,
`Runtime_Bad_Block`, `End-to-End_Error`, `Uncorrectable_Error_Cnt`,
`Current_Pending_Sector`, `CRC_Error_Count`, `SATA_Downshift_Ct`,
`Thermal_Throttle_St`.

Two of those are worth calling out:

- **`CRC_Error_Count = 0`** — the SATA cable and link are clean. Relevant because this
  is the root filesystem.
- **`SATA_Downshift_Ct = 0`** — the link has never dropped below its negotiated
  6.0 Gb/s.

At 8.3 TB written across 2.2 years, this drive is at roughly 1% of its wear budget. It
will be obsolete long before it wears out.

`Timed_Workld_*` attributes reading `65535` are uninitialised placeholders, not errors.

`POR_Recovery_Count = 69` — 69 unclean power-offs out of 1,364 cycles (~5%). Normal
range for a desktop, and this drive has power-loss protection, so no action. Worth a
glance if it starts climbing fast.

**Recommended, since no self-test has ever run:**

```console
sudo smartctl -t short /dev/sda     # 2 minutes
sudo smartctl -l selftest /dev/sda  # read the result afterwards
```

Consider `smartd` for ongoing monitoring — it will mail/log on any attribute change.

> Worth noting: root (`sda2`, btrfs) lives on this SATA SSD, while the NVMe
> (`nvme0n1`, 5 partitions, `dmesg.txt:905`) isn't mounted at boot at all.

---

## 11. Cosmetic log noise — WONTFIX

Nothing to do for any of these; listed so they're not re-investigated later.

| Line | Message | Why it's fine |
|------|---------|---------------|
| `664` | `ahci: SSS flag set, parallel bus scan disabled` | Staggered spin-up is a firmware/AHCI capability bit. Costs ~0.5 s with one disk. Not settable from Linux. |
| `1086` | `snd_hda_intel 0000:26:00.1: Disabling MSI` | Deliberate kernel quirk for NVIDIA HDMI audio. Leave it. |
| `1142` | `block nvme0n1: No UUID available providing old NGUID` | Drive reports NGUID but not UUID. Purely informational. |
| `697,718,739` | `We don't know the algorithms for LPM for this host` | Standard for AMD xHCI. Link power management off — fine on a desktop, and helpful for #7. |
| `756,846,849` | `ata1/5/6: SATA link down` | Empty SATA ports. |
| `1101` | `hci0: HCI LE Coded PHY feature bit is set, but its usage is not supported` | Intel firmware advertising a PHY the stack won't use. Harmless. |

---

## GPU PCIe link at 2.5 GT/s — not a bug

```text
dmesg.txt:426  pci 0000:26:00.0: 32.000 Gb/s available PCIe bandwidth, limited by
               2.5 GT/s PCIe x16 link at 0000:00:03.1 (capable of 126.016 Gb/s
               with 8.0 GT/s PCIe x16 link)
```

This reads alarmingly but is **normal NVIDIA idle behaviour** — the card downshifts the
link to Gen1 when there's nothing to do and ramps back up under load. The kernel prints
this message at enumeration time, when the GPU is by definition idle. Confirmed the link
negotiated correctly:

```console
$ nvidia-smi --query-gpu=pcie.link.gen.current,pcie.link.gen.max,pcie.link.width.current,pcie.link.width.max --format=csv
1, 3, 16, 16
```

`gen.max = 3` at `width = 16` means the link trained to **Gen3 x16**, which is the
card's ceiling (Turing is Gen3; the board is Gen3 too). There is nothing to fix and no
setting to change — `NVreg_EnablePCIeGen3` is a long-deprecated knob that does nothing on
modern drivers.

**To confirm for yourself under load:** run anything GPU-heavy and watch it climb —

```console
nvidia-smi --query-gpu=pcie.link.gen.current --format=csv -l 1
# or stress the link directly:
nvidia-smi -q -d PERFORMANCE
```

The same applies to `dmesg.txt:383` (the chipset uplink is Gen2 x4 **by design** on B450)
and to the `SATA link down` lines, which are just empty ports.

---

## Files changed in this repo

| File | Change | Scope |
|------|--------|-------|
| `home/.chezmoiscripts/arch/run_once_after_bluetooth-setup.sh.tmpl` | `power_save` → `btusb enable_autosuspend=0`; section-aware `main.conf` editing; reload `btusb` on change | Arch, all chassis |
| ↳ same file | new `/etc/modprobe.d/iwlwifi.conf` for WiFi/BT coexistence | Arch **desktop only** |
| `home/.chezmoiscripts/arch/run_onchange_before_13_install-arch-nvidia.sh.tmpl` | `blacklist i2c_nvidia_gpu`; manage `nvidia.conf` as a whole file (fixes `tee` clobber); added the missing `.archlinux` guard | Arch, all chassis |
| `home/.chezmoiscripts/arch/run_onchange_before_11_install-arch-packages.sh.tmpl` | Drop the dead `usbcore` modprobe drop-in | Arch, all chassis |
| ↳ same file | add `usbcore.autosuspend=-1` to the GRUB cmdline | Arch **desktop only** |
| `home/.chezmoiscripts/arch/run_once_after_networking-setup.sh.tmpl` | new `/etc/iwd/main.conf` pinning Wi-Fi to 5 GHz; restart `iwd` on change | Arch + **PCI 8086:2526** (whole script); 5 GHz pin also **desktop only** |

### Scoping

All three scripts live under `.chezmoiscripts/arch/`, which `.chezmoiignore.tmpl`
excludes wholesale on non-Arch machines:

```gotemplate
{{ if not .archlinux -}}
.chezmoiscripts/arch/**
{{ end -}}
```

Within Arch, the two changes that *disable power management* are gated on
`{{ if eq .chassisType "desktop" }}` — keeping WiFi awake and disabling USB runtime PM
across the board are both real battery regressions on a laptop, and this repo already
has an Arch laptop profile (`run_once_after_arch-privileged-setup.sh.tmpl` has
laptop-only touchpad setup). `btusb enable_autosuspend=0` is deliberately left
unscoped: the BT controller's own power draw is negligible next to the dropouts it
causes, so it's the right default on a laptop too. Flip it if a laptop ever needs the
milliwatts back.

Verified by rendering each script with `chassisType` forced to both `desktop` and
`laptop`, and the NVIDIA script with `archlinux` forced to `false` (body strips to a
4-line no-op). The GRUB block is additionally a no-op on systemd-boot machines — it
tests `[[ -f /etc/default/grub ]]` first.

All three render clean under `chezmoi execute-template` and pass `bash -n`.
`shellcheck -S warning` reports only pre-existing `SC2155` warnings in the download
helpers of script 11, untouched by these changes.

Apply with:

```console
chezmoi diff     # review first — script 11 touches /etc/default/grub and runs grub-mkconfig
chezmoi apply
```

`run_once_` scripts re-run when their contents change, so the Bluetooth script will fire
again despite having run before.

---

## Your checklist

- [x] `pacman -S wireless-regdb` (+ added to the tracked package list)
- [x] `chezmoi apply` — config files written, `grub.cfg` regenerated
- [x] `sudo mkinitcpio -P` — image rebuilt 13:00, now carries the blacklist
- [x] `sudo smartctl -a /dev/sda` — PASSED, 99% life left, all error counters zero
- [ ] `chezmoi apply` again — picks up the new 5 GHz pin in `networking-setup.sh`
- [ ] **Reboot** — required for `usbcore.autosuspend=-1`, the `i2c_nvidia_gpu`
      blacklist, `iwlmvm power_scheme=1`, and `regulatory.db`
- [ ] Flash the latest BIOS; re-check XMP/DOCP, SVM, IOMMU, Above-4G, boot order
- [ ] Re-capture `dmesg` post-reboot and post-flash, diff against this audit
- [ ] Decide on #4: live with the taint, or `sbctl` + DKMS signing (do it *after* the flash)
- [ ] `systemctl enable nvidia-{suspend,resume,hibernate}.service` — if you ever suspend
- [ ] Move the Seiren to a rear CPU-attached port; watch for repeat disconnects
- [ ] `sudo smartctl -t short /dev/sda` — no self-test has ever been run on this drive

## Post-apply verification (2026-10-08)

Config files all landed; `grub.cfg` carries the new parameter twice (main + fallback
entry). Live kernel state, though, is still partly the old boot:

| Knob | Now | Want | Gate |
|------|-----|------|------|
| `btusb enable_autosuspend` | `N` | `N` | ✓ active |
| `bluetooth disable_ertm` | `Y` | `Y` | ✓ active |
| BT radio `5-4` runtime status | `suspended`, delay 2000 ms | never suspends | reboot |
| `iwlmvm power_scheme` | `2` | `1` | module reload / reboot |
| `usbcore autosuspend` | `2` | `-1` | reboot (cmdline) |
| `i2c_nvidia_gpu` loaded | yes | no | reboot |

The BT radio is the instructive one: `enable_autosuspend` already reads `N`, but the
*device* was probed at boot with a 2000 ms delay and is sitting suspended right now.
Module parameters only bind at probe time, so the already-enumerated device keeps its
old setting until it re-probes.

### Stale initramfs

`mkinitcpio` bakes a copy of `/etc/modprobe.d/` into the image. The current image
predates the apply:

```text
initramfs built   : 2026-10-08 12:06:14
modprobe.d changed: 2026-10-08 12:53:30
```

Extracted from the live image, it still holds the pre-blacklist nvidia.conf and the
drop-in we deleted:

```console
$ lsinitcpio -x /boot/initramfs-linux-lts.img etc/modprobe.d/nvidia.conf && cat etc/modprobe.d/nvidia.conf
options nvidia_drm modeset=1          # no `blacklist i2c_nvidia_gpu`

$ lsinitcpio /boot/initramfs-linux-lts.img | grep disable-usb-autosuspend
etc/modprobe.d/disable-usb-autosuspend.conf     # deleted from the real root
```

**Cause:** script 13 rebuilt the initramfs only when `mkinitcpio.conf` itself changed.
`MODULES=` was already correct, so it printed "No changes needed" and the nvidia.conf
edit never reached the image. **Fixed** — the script now tracks a `REBUILD_INITRAMFS`
flag set by *either* input.

**Resolved on this machine** at 13:00:58 — the rebuilt image now carries the
`blacklist i2c_nvidia_gpu` line and no longer contains the deleted
`disable-usb-autosuspend.conf`. Verified with `lsinitcpio -x`.

---

# Post-BIOS-flash verification (2026-10-08, `dmesg_new.txt`)

BIOS **1.H4 (2024-09-03) → 1.H9 (2026-08-13)**, cold boot, all chezmoi changes applied.

## Resolved

| # | Issue | Evidence |
|---|-------|----------|
| 1 | `regulatory.db` load failure | message gone (1 → 0) |
| 2a | `bluetooth: unknown parameter 'power_save'` | gone (1 → 0) |
| 2b | `usbcore` autosuspend | `/sys/module/usbcore/parameters/autosuspend` = **-1** |
| 2b | BT radio sleeping | `5-4` now `runtime_status=active`, `autosuspend_delay_ms=-1000` (was `suspended`, 2000) |
| 2c | WiFi power save | `iwlmvm power_scheme` = **1** |
| 2d | 5 GHz pin | `/etc/iwd/main.conf` in place |
| 5 | `ucsi_ccg` / `i2c timeout` | **4 messages → 0**; `i2c_nvidia_gpu` and `ucsi_ccg` not loaded |

Plus one the BIOS fixed on its own:

| CPU microcode | `0x08701034` → **`0x08701035`** |
|---|---|

The old boot logged `Updated early from: 0x08701034` (kernel applying its bundled
revision); the new one logs only `Current revision: 0x08701035` — the BIOS now ships
microcode newer than the kernel's bundle, so no early update is needed.

## Not fixed by the flash

Everything else survived 1.H9 unchanged:

- `ccp: unable to access the device: you might be running a broken BIOS` — still there,
  so `hw_random/rng_available` is still `none`. This one looks baked into MSI's
  B450 PSP configuration rather than being an AGESA-version bug. Treat as permanent.
- `_OSI(Linux) query ignored`, ECAM partial coverage, 3× `_DSM` eval failures,
  `x2apic: IRQ remapping doesn't support X2APIC mode`, `AMD-Vi ... EFR:0x0`
- `ata2.00: Invalid log directory version` (already established as cosmetic — see §10)
- ALC1220 null SSID `1462:0000`
- NVIDIA taint (expected for `nvidia-open-dkms`)
- **IOMMU group 15 still holds 8 devices.** Expected — chipset ACS is a silicon
  limitation, not something firmware can grant.

## New since the flash

### Bluetooth firmware now downloads in two phases — benign

```text
dmesg_new.txt:1103  Bluetooth: hci0: Found device firmware: intel/ibt-18-16-1.sfi
dmesg_new.txt:1112  Bluetooth: hci0: FW download error recovery failed (-19)
dmesg_new.txt:1113  Bluetooth: hci0: sending frame failed (-19)
dmesg_new.txt:1114  Bluetooth: hci0: Reading supported features failed (-19)
dmesg_new.txt:1159  usb 5-4: New USB device found, idVendor=8087 ...   <- re-enumerated
dmesg_new.txt:1161  Bluetooth: hci0: Bootloader revision 0.1 build 42 week 52 2015
dmesg_new.txt:1177  Bluetooth: hci0: Firmware loaded in 1131849 usecs
dmesg_new.txt:1179  Bluetooth: hci0: Device booted in 14633 usecs
dmesg_new.txt:1182  Bluetooth: hci0: Firmware revision 0.1 build 201 week 12 2024
```

`-19` is `ENODEV`. The old boot said `Firmware already loaded` because the controller
still held firmware in RAM from a previous warm boot; flashing the BIOS cut standby
power and cleared it, so this cold boot needed a full download.

The error block is the controller transitioning from *operational* to *bootloader*
mode. That transition tears down and re-creates the USB device, so the driver's
in-flight handle goes stale — hence `ENODEV` — and the retry after re-enumeration
succeeds. End state is correct: `bluetoothctl show` reports the controller `Powered:
yes`, firmware revision `0.1 build 201 week 12 2024`.

Cost is ~1.8 s of boot (7.45 s → 9.25 s) and it should only recur on **cold** boots.

**Confirm on the next warm reboot:** if it goes back to a single
`Firmware already loaded` line, this is settled. If the `-19` block appears on every
boot including warm ones, that's worth a second look.

### `sdb` appeared

Kingston `DataTraveler 3.0`, 14.4 GB, mounted at `/run/media/ds/DCC3-B133` — the BIOS
flash stick, still plugged in. Nothing to do beyond unplugging it.

## Boot time — worth a look

```console
$ systemd-analyze
Startup finished in 17.285s (firmware) + 10.976s (loader) + 5.101s (kernel)
                     + 3.299s (userspace) = 36.663s
```

Userspace is fine (3.3 s). The 28 s spent before the kernel even starts is not:

- **firmware 17.3 s** — BIOS POST. A first boot after a flash usually re-trains memory,
  and 4 populated DIMMs with XMP/DOCP is slow anyway. Re-measure after another boot or
  two before concluding anything. MSI's *Fast Boot* setting also lives here.
- **loader 11.0 s** — GRUB. `/etc/default/grub` has `GRUB_TIMEOUT=5` with
  `GRUB_TIMEOUT_STYLE=menu`, so 5 s of that is the menu simply waiting. Setting
  `GRUB_TIMEOUT=0`, or `GRUB_TIMEOUT_STYLE=hidden` to keep the menu reachable by
  holding Shift, reclaims it. The remaining ~6 s is GRUB's own btrfs/font work.

Neither is a fault — just the cheapest remaining wins if boot time matters to you.
