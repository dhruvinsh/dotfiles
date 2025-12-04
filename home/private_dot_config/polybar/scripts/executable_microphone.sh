#!/usr/bin/env bash

# Check if default source is muted using amixer
if amixer get Capture | grep -q '\[off\]'; then
    echo "MUTED"
else
    echo ""
fi
