#!/usr/bin/env bash
# Docker network helper functions
# vim: set expandtab ft=bash ts=4 tw=4:

# Merge the bridge subnets from .chezmoidata.yaml (docker.*) into /etc/docker/daemon.json,
# keeping any other keys (e.g. runtimes added by nvidia-ctk). Restarts docker if it's running.
# Usage: configure_docker_network
configure_docker_network() {
    local daemon="/etc/docker/daemon.json"
    local current="{}"

    sudo mkdir -p "${daemon%/*}"
    if [ -s "$daemon" ]; then
        current="$(sudo cat "$daemon")"
    fi

    echo "Setting docker bridge subnets in $daemon"
    jq --indent 2 \
        '.bip = "{{ .docker.bip }}"
        | ."default-address-pools" = [{"base": "{{ .docker.poolBase }}", "size": {{ .docker.poolSize }}}]' \
        <<<"$current" | sudo tee "$daemon" >/dev/null

    sudo systemctl try-restart docker.service
}
