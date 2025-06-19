#!/usr/bin/env bash
# Helper functions for downloading and installing files
# vim: set expandtab ft=bash ts=4 tw=4:

# Download a file with consistent options and progress display
# Usage: download_file URL DESTINATION [QUIET]
download_file() {
    local url="$1"
    local dest="$2"
    local quiet="${3:-}"
    
    if [[ "$quiet" == "quiet" ]]; then
        wget -q "$url" -O "$dest"
    else
        echo "Downloading: $(basename "$dest")"
        wget -q --show-progress --progress=bar:force 2>&1 "$url" -O "$dest"
    fi
}

# Install a .deb package from a URL
# Usage: install_deb URL NAME
install_deb() {
    local url="$1"
    local name="$2"
    local tmp_file="/tmp/${name}.deb"
    
    echo "Setting up $name"
    download_file "$url" "$tmp_file"
    sudo apt install -y "$tmp_file"
    rm -f "$tmp_file"
}

# Install an AppImage from a URL
# Usage: install_appimage URL NAME
install_appimage() {
    local url="$1"
    local name="$2"
    local tmp_file="/tmp/${name}.AppImage"
    local app_dir="$HOME/Applications"
    
    echo "Setting up $name"
    download_file "$url" "$tmp_file"
    
    # Create app directory if it doesn't exist
    mkdir -p "$app_dir"
    
    # Make executable and move to applications directory
    chmod +x "$tmp_file"
    mv "$tmp_file" "$app_dir/"
}

# Extract a tar.gz archive to a destination
# Usage: extract_tar URL DEST [STRIP_COMPONENTS]
extract_tar() {
    local url="$1"
    local dest="$2"
    local strip="${3:-1}"
    local tmp_file="/tmp/$(basename "$url" | sed 's/[?].*$//')"
    
    download_file "$url" "$tmp_file"
    mkdir -p "$dest"
    tar -xf "$tmp_file" -C "$dest" --strip-components="$strip"
    rm -f "$tmp_file"
}

# Extract a tar.xz archive to a destination
# Usage: extract_tar_xz URL DEST [STRIP_COMPONENTS]
extract_tar_xz() {
    local url="$1"
    local dest="$2"
    local strip="${3:-1}"
    local tmp_file="/tmp/$(basename "$url" | sed 's/[?].*$//')"
    
    download_file "$url" "$tmp_file"
    mkdir -p "$dest"
    tar -xf "$tmp_file" -C "$dest" --strip-components="$strip"
    rm -f "$tmp_file"
}

# Extract a zip archive to a destination
# Usage: extract_zip URL DEST
extract_zip() {
    local url="$1"
    local dest="$2"
    local tmp_file="/tmp/$(basename "$url" | sed 's/[?].*$//')"
    
    download_file "$url" "$tmp_file"
    mkdir -p "$dest"
    # {{ if eq .chezmoi.os "linux" }}
    unzip -q "$tmp_file" -d "$dest"
    # {{ else }}
    # on mac I have to use 7zz else I get error "need PK compat. v4.6 (can do v4.5)"
    7zz x "$tmp_file" -o"$dest" >/dev/null
    # {{ end }}
    rm -f "$tmp_file"
}
