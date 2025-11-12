#!/bin/bash
# Wrapper per manage.sh - ora in scripts/
exec "$(dirname "$0")/scripts/manage.sh" "$@"
