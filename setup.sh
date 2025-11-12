#!/bin/bash
# Wrapper per setup.sh - ora in scripts/
exec "$(dirname "$0")/scripts/setup.sh" "$@"
