#!/bin/bash

################################################################################
# PiPassive - Script di Setup Configurazione Interattivo
# Guida l'utente nella configurazione di tutti i servizi
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# File di configurazione
ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

# Funzioni di logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo -e "${CYAN}▶${NC} $1"
}

# Header
print_header() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════╗
    ║         PiPassive - Setup Configurazione               ║
    ║    Configurazione Guidata Servizi Passive Income       ║
    ╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Controlla se esiste il file .env
check_env_file() {
    if [[ -f "$ENV_FILE" ]]; then
        log_warning "File .env già esistente!"
        echo
        read -p "Vuoi sovrascriverlo? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Manterrò le configurazioni esistenti e aggiornerò solo i valori nuovi."
            return 1
        fi
    fi
    return 0
}

# Crea backup del file .env esistente
backup_env() {
    if [[ -f "$ENV_FILE" ]]; then
        BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$ENV_FILE" "$BACKUP_FILE"
        log_success "Backup creato: $BACKUP_FILE"
    fi
}

# Leggi valore esistente dal .env
get_existing_value() {
    local key=$1
    if [[ -f "$ENV_FILE" ]]; then
        grep "^${key}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2- || echo ""
    fi
}

# Chiedi input con valore di default
ask_input() {
    local prompt=$1
    local var_name=$2
    local default_value=$3
    local is_password=$4
    local existing_value=$(get_existing_value "$var_name")
    
    # Se esiste un valore, usalo come default
    if [[ -n "$existing_value" ]]; then
        default_value="$existing_value"
    fi
    
    if [[ "$is_password" == "true" ]]; then
        echo -ne "${CYAN}${prompt}${NC}"
        if [[ -n "$default_value" ]]; then
            echo -ne " ${YELLOW}[attuale: ****]${NC}"
        fi
        echo -ne ": "
        read -s value
        echo
    else
        echo -ne "${CYAN}${prompt}${NC}"
        if [[ -n "$default_value" ]]; then
            echo -ne " ${YELLOW}[${default_value}]${NC}"
        fi
        echo -ne ": "
        read value
    fi
    
    # Usa default se vuoto
    if [[ -z "$value" && -n "$default_value" ]]; then
        value="$default_value"
    fi
    
    echo "$value"
}

# Configura singolo servizio
configure_service() {
    local service_name=$1
    local service_url=$2
    
    echo
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${service_name}${NC}"
    echo -e "${BLUE}${service_url}${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo
    
    read -p "Vuoi configurare ${service_name}? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Saltato ${service_name}"
        return
    fi
}

# Setup Honeygain
setup_honeygain() {
    configure_service "Honeygain" "https://honeygain.com/"
    
    HONEYGAIN_EMAIL=$(ask_input "Email Honeygain" "HONEYGAIN_EMAIL" "" false)
    HONEYGAIN_PASSWORD=$(ask_input "Password Honeygain" "HONEYGAIN_PASSWORD" "" true)
    HONEYGAIN_DEVICE_NAME=$(ask_input "Nome dispositivo" "HONEYGAIN_DEVICE_NAME" "PiPassive-Honeygain" false)
    
    cat >> "$ENV_FILE" << EOF

# Honeygain
HONEYGAIN_EMAIL=$HONEYGAIN_EMAIL
HONEYGAIN_PASSWORD=$HONEYGAIN_PASSWORD
HONEYGAIN_DEVICE_NAME=$HONEYGAIN_DEVICE_NAME
EOF
    
    log_success "Honeygain configurato!"
}

# Setup EarnApp
setup_earnapp() {
    configure_service "EarnApp" "https://earnapp.com/"
    
    echo -e "${YELLOW}Per ottenere il tuo UUID:${NC}"
    echo "1. Vai su https://earnapp.com/dashboard"
    echo "2. Clicca su 'Installation'"
    echo "3. Copia il Device UUID (formato: sdk-node-xxxxx)"
    echo
    
    EARNAPP_UUID=$(ask_input "UUID EarnApp" "EARNAPP_UUID" "" false)
    
    cat >> "$ENV_FILE" << EOF

# EarnApp
EARNAPP_UUID=$EARNAPP_UUID
EOF
    
    log_success "EarnApp configurato!"
}

# Setup Pawns
setup_pawns() {
    configure_service "Pawns.app" "https://pawns.app/"
    
    PAWNS_EMAIL=$(ask_input "Email Pawns" "PAWNS_EMAIL" "" false)
    PAWNS_PASSWORD=$(ask_input "Password Pawns" "PAWNS_PASSWORD" "" true)
    PAWNS_DEVICE_NAME=$(ask_input "Nome dispositivo" "PAWNS_DEVICE_NAME" "PiPassive-Pawns" false)
    
    cat >> "$ENV_FILE" << EOF

# Pawns.app
PAWNS_EMAIL=$PAWNS_EMAIL
PAWNS_PASSWORD=$PAWNS_PASSWORD
PAWNS_DEVICE_NAME=$PAWNS_DEVICE_NAME
EOF
    
    log_success "Pawns.app configurato!"
}

# Setup PacketStream
setup_packetstream() {
    configure_service "PacketStream" "https://packetstream.io/"
    
    echo -e "${YELLOW}Per ottenere il tuo CID:${NC}"
    echo "1. Vai su https://packetstream.io/dashboard"
    echo "2. Clicca su 'Download' o 'Add Device'"
    echo "3. Copia il CID dalle istruzioni di installazione"
    echo
    
    PACKETSTREAM_CID=$(ask_input "CID PacketStream" "PACKETSTREAM_CID" "" false)
    
    cat >> "$ENV_FILE" << EOF

# PacketStream
PACKETSTREAM_CID=$PACKETSTREAM_CID
EOF
    
    log_success "PacketStream configurato!"
}

# Setup TraffMonetizer
setup_traffmonetizer() {
    configure_service "TraffMonetizer" "https://traffmonetizer.com/"
    
    echo -e "${YELLOW}Per ottenere il token:${NC}"
    echo "1. Vai su https://traffmonetizer.com/dashboard"
    echo "2. Cerca 'Your Application Token'"
    echo "3. Copia il token"
    echo
    
    TRAFFMONETIZER_TOKEN=$(ask_input "Token TraffMonetizer" "TRAFFMONETIZER_TOKEN" "" false)
    
    cat >> "$ENV_FILE" << EOF

# TraffMonetizer
TRAFFMONETIZER_TOKEN=$TRAFFMONETIZER_TOKEN
EOF
    
    log_success "TraffMonetizer configurato!"
}

# Setup Repocket
setup_repocket() {
    configure_service "Repocket" "https://repocket.co/"
    
    echo -e "${YELLOW}Per ottenere l'API key:${NC}"
    echo "1. Vai su https://repocket.co/dashboard"
    echo "2. Cerca la sezione API"
    echo "3. Genera una nuova API key"
    echo
    
    REPOCKET_EMAIL=$(ask_input "Email Repocket" "REPOCKET_EMAIL" "" false)
    REPOCKET_API_KEY=$(ask_input "API Key Repocket" "REPOCKET_API_KEY" "" false)
    
    cat >> "$ENV_FILE" << EOF

# Repocket
REPOCKET_EMAIL=$REPOCKET_EMAIL
REPOCKET_API_KEY=$REPOCKET_API_KEY
EOF
    
    log_success "Repocket configurato!"
}

# Setup EarnFM
setup_earnfm() {
    configure_service "EarnFM" "https://earn.fm/"
    
    echo -e "${YELLOW}Per ottenere il token:${NC}"
    echo "1. Vai su https://earn.fm/dashboard"
    echo "2. Cerca il token di installazione"
    echo "3. Copia il token"
    echo
    
    EARNFM_TOKEN=$(ask_input "Token EarnFM" "EARNFM_TOKEN" "" false)
    
    cat >> "$ENV_FILE" << EOF

# EarnFM
EARNFM_TOKEN=$EARNFM_TOKEN
EOF
    
    log_success "EarnFM configurato!"
}

# Setup MystNode
setup_mystnode() {
    configure_service "MystNode" "https://mystnodes.com/"
    
    echo -e "${YELLOW}Info MystNode:${NC}"
    echo "- Il nodo genererà automaticamente un'identità al primo avvio"
    echo "- Dashboard disponibile su: http://[IP-RASPBERRY]:4449"
    echo "- L'API key è opzionale per il monitoraggio remoto"
    echo
    
    MYSTNODE_API_KEY=$(ask_input "API Key MystNode (opzionale)" "MYSTNODE_API_KEY" "" false)
    
    cat >> "$ENV_FILE" << EOF

# MystNode
MYSTNODE_API_KEY=$MYSTNODE_API_KEY
EOF
    
    log_success "MystNode configurato!"
}

# Setup PacketShare
setup_packetshare() {
    configure_service "PacketShare" "https://packetshare.io/"
    
    PACKETSHARE_EMAIL=$(ask_input "Email PacketShare" "PACKETSHARE_EMAIL" "" false)
    PACKETSHARE_PASSWORD=$(ask_input "Password PacketShare" "PACKETSHARE_PASSWORD" "" true)
    
    cat >> "$ENV_FILE" << EOF

# PacketShare
PACKETSHARE_EMAIL=$PACKETSHARE_EMAIL
PACKETSHARE_PASSWORD=$PACKETSHARE_PASSWORD
EOF
    
    log_success "PacketShare configurato!"
}

# Setup generale
setup_general() {
    echo
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Configurazioni Generali${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo
    
    TZ=$(ask_input "Timezone" "TZ" "Europe/Rome" false)
    LOG_LEVEL=$(ask_input "Log Level (debug/info/warn/error)" "LOG_LEVEL" "info" false)
    AUTO_UPDATE=$(ask_input "Auto-update containers? (true/false)" "AUTO_UPDATE" "false" false)
    
    cat >> "$ENV_FILE" << EOF

# Configurazioni Generali
TZ=$TZ
LOG_LEVEL=$LOG_LEVEL
AUTO_UPDATE=$AUTO_UPDATE
EOF
    
    log_success "Configurazioni generali completate!"
}

# Main setup
main() {
    print_header
    
    log_info "Setup Configurazione Guidato"
    echo
    log_info "Questo script ti guiderà nella configurazione di tutti i servizi."
    log_info "Premi INVIO per usare il valore di default [tra parentesi]"
    echo
    
    read -p "Premi INVIO per continuare..."
    
    # Backup se necessario
    if [[ -f "$ENV_FILE" ]]; then
        backup_env
    fi
    
    # Crea nuovo file .env
    if check_env_file; then
        echo "# PiPassive Environment Configuration" > "$ENV_FILE"
        echo "# Generato il: $(date)" >> "$ENV_FILE"
    fi
    
    # Setup servizi
    setup_honeygain
    setup_earnapp
    setup_pawns
    setup_packetstream
    setup_traffmonetizer
    setup_repocket
    setup_earnfm
    setup_mystnode
    setup_packetshare
    setup_general
    
    # Riepilogo
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Configurazione Completata!                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo
    log_success "File .env creato con successo!"
    echo
    echo -e "${BLUE}Prossimi passi:${NC}"
    echo -e "  1. Verifica il file .env: ${CYAN}nano .env${NC}"
    echo -e "  2. Avvia i servizi: ${GREEN}./manage.sh start${NC}"
    echo -e "  3. Monitora lo stato: ${GREEN}./dashboard.sh${NC}"
    echo
    log_warning "IMPORTANTE: Non condividere mai il file .env!"
    echo
}

# Esegui main
main "$@"
