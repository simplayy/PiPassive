#!/bin/bash
# Wrapper per install.sh - ora in scripts/
exec "$(dirname "$0")/scripts/install.sh" "$@"
