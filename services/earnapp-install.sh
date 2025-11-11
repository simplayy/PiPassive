#!/bin/bash

################################################################################
# EarnApp Auto-Installation Script
# Installa EarnApp automaticamente con credenziali fornite
################################################################################

set -e

# Source environment variables
if [[ -f "/home/pi/PiPassive/.env" ]]; then
    export $(cat /home/pi/PiPassive/.env | xargs)
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if EarnApp should be auto-installed
if [[ "$EARNAPP_AUTO_INSTALL" != "true" ]]; then
    log_info "EarnApp auto-install non abilitato"
    exit 0
fi

# Check if email and password are provided
if [[ -z "$EARNAPP_EMAIL" ]] || [[ -z "$EARNAPP_PASSWORD" ]]; then
    log_error "Email o password di EarnApp non configurate"
    exit 1
fi

log_info "Installazione di EarnApp..."

# Download and run the official EarnApp installer with credentials
# The installer script supports non-interactive mode via stdin
(
    echo "$EARNAPP_EMAIL"
    echo "$EARNAPP_PASSWORD"
    echo "y"  # Accept terms
) | bash <(wget -qO- https://brightdata.com/static/earnapp/install.sh) 2>&1 || {
    # Se il primo tentativo fallisce, proviamo il metodo alternativo
    log_info "Tentando metodo alternativo di installazione..."
    wget -qO- https://brightdata.com/static/earnapp/install.sh | bash -s - "$EARNAPP_EMAIL" "$EARNAPP_PASSWORD" || true
}

log_success "Installazione di EarnApp completata!"





