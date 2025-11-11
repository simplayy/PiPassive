#!/bin/bash

################################################################################
# PiPassive - Test Flow Script
# Dimostra il flusso completo: setup -> start -> status
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Funzioni di logging
log_header() {
    echo
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC} $1"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════╝${NC}"
    echo
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Main
main() {
    log_header "PiPassive - Test Flow Completo"
    
    # Step 1: Verifica prerequisiti
    log_step "1. Verifica prerequisiti..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker non è installato!"
        exit 1
    fi
    log_success "Docker è installato"
    
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose non è installato!"
        exit 1
    fi
    log_success "Docker Compose è installato"
    
    if [[ ! -f .env ]]; then
        log_error "File .env non trovato! Esegui prima: ./setup.sh"
        exit 1
    fi
    log_success "File .env trovato"
    
    echo
    
    # Step 2: Status iniziale
    log_step "2. Status iniziale..."
    ./manage.sh status 2>&1 | tail -20
    
    echo
    
    # Step 3: Stop (se già avviato)
    log_step "3. Arresto servizi precedenti..."
    ./manage.sh stop 2>&1 | grep -E "INFO|✓|✗"
    sleep 3
    
    echo
    
    # Step 4: Start
    log_step "4. Avvio tutti i servizi..."
    ./manage.sh start 2>&1 | grep -E "INFO|✓|✗|Creating|Created|Starting|Started"
    sleep 5
    
    echo
    
    # Step 5: Status finale
    log_step "5. Status finale..."
    ./manage.sh status 2>&1 | tail -25
    
    echo
    
    # Summary
    log_header "Test Completato ✓"
    
    log_info "Comandi utili:"
    echo -e "  • Logs:     ${CYAN}./manage.sh logs${NC}"
    echo -e "  • Follow:   ${CYAN}./manage.sh follow <servizio>${NC}"
    echo -e "  • Stats:    ${CYAN}./manage.sh stats${NC}"
    echo -e "  • Dashboard: ${CYAN}./dashboard.sh${NC}"
    echo
}

main "$@"





