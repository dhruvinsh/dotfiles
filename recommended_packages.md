# Recommended Arch Linux Packages for Your Setups

This document highlights the most useful packages from the `omarchy` repository configured for your systems. Since both systems are desktops running (or moving to) **Hyprland** with NVIDIA Turing or newer GPUs, they share a very similar optimized Wayland and graphics stack.

---

## 1. NVIDIA Graphics & Video Acceleration (Both Systems)

Your GPUs (RTX 2060 Super and dual RTX 4500 Ada / RTX 4000) are Turing or newer architectures. They fully support **NVIDIA's GSP (GPU System Processor) firmware**, allowing you to run NVIDIA's open-source kernel modules.

| Package | Purpose | Why It's Useful |
| :--- | :--- | :--- |
| **`nvidia-open-dkms`** | Open-source NVIDIA kernel modules | Performs excellently on Turing+ cards and handles kernel updates reliably. |
| **`nvidia-utils`** & <br>**`lib32-nvidia-utils`** | Userspace drivers and 32-bit compatibility | Required for OpenGL, Vulkan, CUDA, and gaming (Steam, Wine, Proton). |
| **`libva-nvidia-driver`** | VA-API wrapper for NVIDIA (NVDEC) | Enables hardware-accelerated video decoding (VP9, AV1, H.264) in browsers and media players (like MPV). |
| **`gpu-screen-recorder`** | Low-overhead screen recorder | Utilizes NVENC directly to record the screen with 0% CPU overhead and near-zero GPU impact. |
| **`sunshine`** | Game/desktop hosting stream server | Host low-latency game/desktop streams to other devices. On your dual GPU workstation, you can offload streaming to the second GPU. |

> [!TIP]
> Omarchy configures early KMS for NVIDIA by adding these modules to mkinitcpio:
> `MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`
> And registers these environment variables in your Hyprland environment files:
> *   `NVD_BACKEND = "direct"`
> *   `LIBVA_DRIVER_NAME = "nvidia"`
> *   `__GLX_VENDOR_LIBRARY_NAME = "nvidia"`

---

## 2. Intel Integrated Graphics Stack (System 2 Workstation)

Since System 2 is an Intel i7 desktop, it likely has an Intel integrated GPU (e.g. UHD Graphics 770). You can use this for driving the display while reserving your discrete NVIDIA GPUs exclusively for compute or rendering tasks.

| Package | Purpose | Why It's Useful |
| :--- | :--- | :--- |
| **`intel-media-driver`** | Intel media driver for VA-API | QuickSync hardware video decoding/encoding. |
| **`libvpl`** & **`vpl-gpu-rt`** | Intel Video Processing Library | Modern standard API for Intel GPU video processing. |
| **`vulkan-intel`** & <br>**`lib32-vulkan-intel`** | Intel Vulkan driver | Vulkan support for the integrated Intel graphics chip. |

---

## 3. Hyprland & Wayland Desktop Ecosystem (Both Systems)

Since both setups run Hyprland on Arch, the following utilities from Omarchy's base configuration provide a highly polished, unified desktop environment:

| Package | Purpose | Why It's Useful |
| :--- | :--- | :--- |
| **`hyprlock`** | Screen locker | Fast, secure, and native lockscreen for Hyprland. |
| **`hypridle`** | Idle daemon | Coordinates screen dimming, locking, and system suspend timeouts. |
| **`hyprsunset`** | Blue light filter | Official gamma/blue-light filter for night mode. |
| **`satty`** | Screenshot annotation | Modern annotation tool that integrates with `grim` (grabbing images) and `slurp` (selecting regions). |
| **`swayosd`** | On-screen display overlays | Clean animations showing volume and brightness changes. |
| **`waybar`** | Status bar | The modern, customizable status bar for Wayland. |
| **`mako`** | Notification daemon | Lightweight notification manager. |
| **`uwsm`** | Wayland Session Manager | Runs Hyprland in a systemd wrapper, ensuring correct environment variable propagation. |
| **`walker`** (or `quickshell`) | Application launcher | Ultra-fast launcher, clipboard history manager, and runner. |

---

## 4. Virtualization & Windows Integration (System 2 Workstation)

On a powerful 13th-gen i7 desktop with dual RTX GPUs, running a performant Windows environment alongside Linux is highly efficient.

| Package | Purpose | Why It's Useful |
| :--- | :--- | :--- |
| **`dockurr/windows`** *(Docker)* | Windows in Docker/KVM | Automates setting up a Windows 11 VM running inside Docker using QEMU/KVM. |
| **`freerdp`** (or `freerdp3`) | RDP Client | Connect to the Windows container with raw performance, clipboard sync, audio forwarding, and RDP graphics acceleration (`/gfx:AVC444`). |

---

## 5. Command Line & Productivity Utilities (Both Systems)

| Package | Purpose | Why It's Useful |
| :--- | :--- | :--- |
| **`mise`** | Polyglot version manager | Manages runtimes (Node.js, Python, Go, Rust, Bun, Deno, Zig, Java) dynamically in place of multiple different version managers. |
| **`lazygit`** & **`lazydocker`** | Git/Docker Terminal UIs | Beautiful, efficient dashboards for managing repositories and containers. |
| **`btop`** | System resource monitor | A gorgeous resource monitor to track CPU core utilization and multi-GPU telemetry. |
| **`dua-cli`** | Disk usage analyzer | Fast, interactive terminal tool for identifying large files/directories. |
| **`zoxide`** | Smart directory jumper | Replaces `cd` with a learning router (e.g., typing `z docs` jumps to your documents folder). |
| **`bat`, `eza`, `fzf`, `ripgrep`, `fd`** | Modern shell utils | Replacements for standard tools (`cat`, `ls`, fuzzy searching, `grep`, and `find`) designed for speed and clarity. |
| **`plocate`** | Quick file indexing | Extremely fast cached search database. |

---

## 6. Miscellaneous & Hardware Control (Both Systems)

| Package | Purpose | Why It's Useful |
| :--- | :--- | :--- |
| **`libfido2`** & **`pam-u2f`** | Hardware security keys | Secure your lockscreen and sudo prompts using a FIDO2 key (like a YubiKey). |
| **`localsend`** | LAN file sharing | Secure, local file transfer client that works cross-platform without internet dependency. |
| **`tailscale`** | Mesh VPN | Connects both of your computers securely under a private WireGuard mesh. |
| **`xpadneo-dkms`** | Xbox Controller driver | Bluetooth kernel driver for Xbox controllers that fixes connectivity and button mapping issues. |
