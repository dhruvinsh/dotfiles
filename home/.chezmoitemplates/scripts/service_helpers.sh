#!/usr/bin/env bash
# Service management helper functions
# vim: set expandtab ft=bash ts=4 tw=4:

# Enable and start system services if not already active
# Usage: enable_system_services SERVICE1 SERVICE2 ...
enable_system_services() {
    local services=("$@")
    
    if [ ${#services[@]} -eq 0 ]; then
        return 0
    fi
    
    for service in "${services[@]}"; do
        if ! sudo systemctl is-active --quiet "$service" >/dev/null 2>&1; then
            echo "Enabling system service: $service"
            sudo systemctl enable --now "$service"
        fi
    done
}

# Enable and start user services if not already active
# Usage: enable_user_services SERVICE1 SERVICE2 ...
enable_user_services() {
    local services=("$@")
    
    if [ ${#services[@]} -eq 0 ]; then
        return 0
    fi
    
    for service in "${services[@]}"; do
        if ! systemctl --user is-active --quiet "$service" >/dev/null 2>&1; then
            echo "Enabling user service: $service"
            systemctl --user enable --now "$service"
        fi
    done
}

# Enable services from arrays (compatible with existing script patterns)
# Usage: 
#   system_services=(service1 service2)
#   user_services=(service3 service4)
#   enable_services_from_arrays
enable_services_from_arrays() {
    if declare -p system_services >/dev/null 2>&1 && [ ${#system_services[@]} -gt 0 ]; then
        enable_system_services "${system_services[@]}"
    fi
    
    if declare -p user_services >/dev/null 2>&1 && [ ${#user_services[@]} -gt 0 ]; then
        enable_user_services "${user_services[@]}"
    fi
}
