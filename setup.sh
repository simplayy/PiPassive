#!/bin/bash

################################################################################
# PiPassive - Script di Setup Configurazione Interattivo
# Guida l'utente nella configurazione di tutti i servizi
################################################################################

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

# Funzione per testare una connessione
test_connectivity() {
    local service_name=$1
    local test_url=$2
    
    if timeout 5 curl -sf "$test_url" >/dev/null 2>&1; then
        log_success "$service_name è raggiungibile!"
        return 0
    else
        log_warning "$service_name non raggiungibile (potrebbe essere normale)"
        return 1
    fi
}

# Chiedi input con valore di default
ask_input() {
    local prompt=$1
    local var_name=$2
    local default_value=$3
    local is_password=$4
    local value=""
    local existing_value=$(get_existing_value "$var_name")
    
    # Se esiste un valore, usalo come default
    if [[ -n "$existing_value" ]]; then
        default_value="$existing_value"
    fi
    
    # Stampa il prompt con i colori (non catturato in ask_input)
    if [[ "$is_password" == "true" ]]; then
        {
            echo -ne "${CYAN}${prompt}${NC}"
            if [[ -n "$default_value" ]]; then
                echo -ne " ${YELLOW}[attuale: ****]${NC}"
            fi
            echo -ne ": "
        } >&2
        read -rs value
        echo "" >&2
    else
        {
            echo -ne "${CYAN}${prompt}${NC}"
            if [[ -n "$default_value" ]]; then
                echo -ne " ${YELLOW}[${default_value}]${NC}"
            fi
            echo -ne ": "
        } >&2
        read -r value
    fi
    
    # Usa default se vuoto
    if [[ -z "$value" && -n "$default_value" ]]; then
        value="$default_value"
    fi
    
    # Stampa solo il valore (senza colori)
    echo "$value"
}

# Configura singolo servizio
configure_service() {
    local service_name=$1
    local service_url=$2
    local response
    
    echo
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${service_name}${NC}"
    echo -e "${BLUE}${service_url}${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo
    
    read -p "Vuoi configurare ${service_name}? (y/n) " -n 1 -r response
    echo
    if [[ ! $response =~ ^[Yy]$ ]]; then
        log_info "Saltato ${service_name}"
        return 1
    fi
    return 0
}

# Setup Honeygain
setup_honeygain() {
    configure_service "Honeygain" "https://join.honeygain.com/SIMNI7E3A1" || return 0
    
    echo -e "${YELLOW}Per registrarti e ottenere bonus:${NC}"
    echo -e "  ${GREEN}https://join.honeygain.com/SIMNI7E3A1${NC}"
    echo
    
    HONEYGAIN_EMAIL=$(ask_input "Email Honeygain" "HONEYGAIN_EMAIL" "" false)
    HONEYGAIN_PASSWORD=$(ask_input "Password Honeygain" "HONEYGAIN_PASSWORD" "" true)
    HONEYGAIN_DEVICE_NAME=$(ask_input "Nome dispositivo" "HONEYGAIN_DEVICE_NAME" "PiPassive-Honeygain" false)
    
    # Test connessione a Honeygain
    log_info "Test connessione a Honeygain..."
    test_connectivity "Honeygain" "https://api.honeygain.com" || true
    
    cat >> "$ENV_FILE" << EOF

# Honeygain
HONEYGAIN_EMAIL=$HONEYGAIN_EMAIL
HONEYGAIN_PASSWORD=$HONEYGAIN_PASSWORD
HONEYGAIN_DEVICE_NAME=$HONEYGAIN_DEVICE_NAME
EOF
    
    log_success "Honeygain configurato e testato!"
}

# Setup EarnApp
setup_earnapp() {
    configure_service "EarnApp" "https://earnapp.com/i/KSj1BgEi" || return 0
    
    echo
    log_info "EarnApp verrà installato come servizio nativo (non Docker)"
    echo -e "${YELLOW}Per registrarti:${NC}"
    echo -e "  ${GREEN}https://earnapp.com/i/KSj1BgEi${NC}"
    echo
    
    EARNAPP_EMAIL=$(ask_input "Email EarnApp" "EARNAPP_EMAIL" "" false)
    EARNAPP_PASSWORD=$(ask_input "Password EarnApp" "EARNAPP_PASSWORD" "" true)
    
    # Test connessione
    log_info "Test connessione a EarnApp..."
    test_connectivity "EarnApp" "https://earnapp.com" || true
    
    cat >> "$ENV_FILE" << EOF

# EarnApp - Servizio nativo (non Docker)
EARNAPP_EMAIL=$EARNAPP_EMAIL
EARNAPP_PASSWORD=$EARNAPP_PASSWORD
EOF
    
    log_success "EarnApp configurato!"
    log_info "Per installare: wget -qO- https://brightdata.com/static/earnapp/install.sh > /tmp/earnapp.sh && sudo bash /tmp/earnapp.sh"
}

# Setup Pawns
setup_pawns() {
    configure_service "Pawns.app" "https://pawns.app/?r=4060689" || return 0
    
    echo -e "${YELLOW}Per registrarti e ottenere bonus:${NC}"
    echo -e "  ${GREEN}https://pawns.app/?r=4060689${NC}"
    echo
    
    PAWNS_EMAIL=$(ask_input "Email Pawns" "PAWNS_EMAIL" "" false)
    PAWNS_PASSWORD=$(ask_input "Password Pawns" "PAWNS_PASSWORD" "" true)
    PAWNS_DEVICE_NAME=$(ask_input "Nome dispositivo" "PAWNS_DEVICE_NAME" "PiPassive-Pawns" false)
    
    # Test connessione a Pawns
    log_info "Test connessione a Pawns.app..."
    test_connectivity "Pawns.app" "https://pawns.app" || true
    
    cat >> "$ENV_FILE" << EOF

# Pawns.app
PAWNS_EMAIL=$PAWNS_EMAIL
PAWNS_PASSWORD=$PAWNS_PASSWORD
PAWNS_DEVICE_NAME=$PAWNS_DEVICE_NAME
EOF
    
    log_success "Pawns.app configurato e testato!"
}

# Setup PacketStream
setup_packetstream() {
    configure_service "PacketStream" "https://packetstream.io/?psr=6GQZ" || return 0
    
    echo -e "${YELLOW}Per registrarti e ottenere il CID:${NC}"
    echo -e "  ${GREEN}https://packetstream.io/?psr=6GQZ${NC}"
    echo
    echo "1. Vai su https://packetstream.io/dashboard"
    echo "2. Clicca su 'Download' o 'Add Device'"
    echo "3. Copia il CID dalle istruzioni di installazione"
    echo
    
    PACKETSTREAM_CID=$(ask_input "CID PacketStream" "PACKETSTREAM_CID" "" false)
    
    # Test connessione a PacketStream
    log_info "Test connessione a PacketStream..."
    test_connectivity "PacketStream" "https://packetstream.io" || true
    
    cat >> "$ENV_FILE" << EOF

# PacketStream
PACKETSTREAM_CID=$PACKETSTREAM_CID
EOF
    
    log_success "PacketStream configurato e testato!"
}

# Setup TraffMonetizer
setup_traffmonetizer() {
    configure_service "TraffMonetizer" "https://traffmonetizer.com/?aff=1677252" || return 0
    
    echo -e "${YELLOW}Per registrarti e ottenere il token:${NC}"
    echo -e "  ${GREEN}https://traffmonetizer.com/?aff=1677252${NC}"
    echo
    echo "1. Vai su https://traffmonetizer.com/dashboard"
    echo "2. Cerca 'Your Application Token' o 'API Token'"
    echo "3. Copia il token"
    echo
    
    TRAFFMONETIZER_TOKEN=$(ask_input "Token TraffMonetizer" "TRAFFMONETIZER_TOKEN" "" false)
    
    # Test connessione a TraffMonetizer
    log_info "Test connessione a TraffMonetizer..."
    test_connectivity "TraffMonetizer" "https://traffmonetizer.com" || true
    
    cat >> "$ENV_FILE" << EOF

# TraffMonetizer - Container Docker (immagine ARM64)
TRAFFMONETIZER_TOKEN=$TRAFFMONETIZER_TOKEN
EOF
    
    log_success "TraffMonetizer configurato! (Docker container ARM64)"
}

# Setup Repocket
setup_repocket() {
    configure_service "Repocket" "https://link.repocket.com/mnGO" || return 0
    
    echo -e "${YELLOW}Per registrarti e ottenere l'API key:${NC}"
    echo -e "  ${GREEN}https://link.repocket.com/mnGO${NC}"
    echo
    echo "1. Vai su https://repocket.co/dashboard"
    echo "2. Cerca la sezione API"
    echo "3. Genera una nuova API key"
    echo
    
    REPOCKET_EMAIL=$(ask_input "Email Repocket" "REPOCKET_EMAIL" "" false)
    REPOCKET_API_KEY=$(ask_input "API Key Repocket" "REPOCKET_API_KEY" "" false)
    
    # Test connessione a Repocket
    log_info "Test connessione a Repocket..."
    test_connectivity "Repocket" "https://repocket.co" || true
    
    cat >> "$ENV_FILE" << EOF

# Repocket
REPOCKET_EMAIL=$REPOCKET_EMAIL
REPOCKET_API_KEY=$REPOCKET_API_KEY
EOF
    
    log_success "Repocket configurato e testato!"
}

# Setup EarnFM
setup_earnfm() {
    configure_service "EarnFM" "https://earn.fm/ref/SIMO7N4P" || return 0
    
    echo -e "${YELLOW}Per registrarti e ottenere la API key:${NC}"
    echo -e "  ${GREEN}https://earn.fm/ref/SIMO7N4P${NC}"
    echo
    echo "1. Vai su https://app.earn.fm/#/login"
    echo "2. Fai login al tuo account"
    echo "3. Cerca la 'API key' (o 'Pair Key')"
    echo "4. Copia la tua API key"
    echo
    
    EARNFM_TOKEN=$(ask_input "API Key EarnFM" "EARNFM_TOKEN" "" false)
    
    # Test connessione a EarnFM
    log_info "Test connessione a EarnFM..."
    test_connectivity "EarnFM" "https://earn.fm" || true
    
    cat >> "$ENV_FILE" << EOF

# EarnFM
EARNFM_TOKEN=$EARNFM_TOKEN
EOF
    
    log_success "EarnFM configurato e testato!"
}

# Setup MystNode
setup_mystnode() {
    configure_service "MystNode" "https://mystnodes.co/?referral_code=Z2MtvYCSj92pngdiqavF51ZLxs1ZQtWHY6ap0Lsi" || return 0
    
    echo -e "${YELLOW}📌 Istruzioni MystNode:${NC}"
    echo -e "Per registrarti: ${GREEN}https://mystnodes.co/?referral_code=Z2MtvYCSj92pngdiqavF51ZLxs1ZQtWHY6ap0Lsi${NC}"
    echo
    echo "- Il nodo genererà automaticamente un'identità al primo avvio"
    echo "- Dopo l'avvio del Docker, DEVI completare la configurazione manuale:"
    echo "  ${CYAN}1. Vai su: http://pipassive.local:4449${NC} (o http://[IP-RASPBERRY]:4449)"
    echo "  ${CYAN}2. Segui la procedura di setup della dashboard${NC}"
    echo "  ${CYAN}3. Completa la verifica dell'identità${NC}"
    echo "- L'API key è opzionale per il monitoraggio remoto"
    echo
    
    MYSTNODE_API_KEY=$(ask_input "API Key MystNode (opzionale)" "MYSTNODE_API_KEY" "" false)
    
    # Test connessione a MystNode
    log_info "Test connessione a MystNode..."
    test_connectivity "MystNode" "https://mystnodes.com" || true
    
    cat >> "$ENV_FILE" << EOF

# MystNode - RICHIEDE SETUP MANUALE VIA WEB!
# Dopo l'avvio, visita: http://pipassive.local:4449
MYSTNODE_API_KEY=$MYSTNODE_API_KEY
EOF
    
    log_success "MystNode configurato!"
    echo -e "${YELLOW}⚠️  Ricorda: devi completare il setup su http://pipassive.local:4449${NC}"
}

# Setup PacketShare
setup_packetshare() {
    configure_service "PacketShare" "https://www.packetshare.io/?code=F5AF0C1F37B0D827" || return 0
    
    echo -e "${YELLOW}Per registrarti:${NC}"
    echo -e "  ${GREEN}https://www.packetshare.io/?code=F5AF0C1F37B0D827${NC}"
    echo
    
    PACKETSHARE_EMAIL=$(ask_input "Email PacketShare" "PACKETSHARE_EMAIL" "" false)
    PACKETSHARE_PASSWORD=$(ask_input "Password PacketShare" "PACKETSHARE_PASSWORD" "" true)
    
    # Test connessione a PacketShare
    log_info "Test connessione a PacketShare..."
    test_connectivity "PacketShare" "https://packetshare.io" || true
    
    cat >> "$ENV_FILE" << EOF

# PacketShare
PACKETSHARE_EMAIL=$PACKETSHARE_EMAIL
PACKETSHARE_PASSWORD=$PACKETSHARE_PASSWORD
EOF
    
    log_success "PacketShare configurato e testato!"
}

# Installa EarnApp come servizio nativo (interattivo)
install_earnapp_interactive() {
    echo
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}EarnApp - Servizio di Sistema (Opzionale)${NC}"
    echo
    
    read -p "Vuoi installare EarnApp ORA? (s/n) " -r
    
    if [[ ! "$REPLY" =~ ^[Ss]$ ]]; then
        return 0
    fi
    
    echo
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
    
    # Esegui il comando di installazione direttamente (foreground, interattivo)
    wget -qO- https://brightdata.com/static/earnapp/install.sh > /tmp/earnapp.sh && sudo bash /tmp/earnapp.sh
    
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
    echo
    
    # Verifica se è stato installato
    if command -v earnapp >/dev/null 2>&1; then
        log_success "✓ EarnApp installato con successo!"
        sudo systemctl enable earnapp 2>/dev/null || true
        sudo systemctl start earnapp 2>/dev/null || true
    else
        log_warning "EarnApp: verifica con: systemctl status earnapp"
    fi
}

# Installa TraffMonetizer come servizio nativo (interattivo)
install_traffmonetizer_interactive() {
    echo
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}TraffMonetizer - Servizio di Sistema (Opzionale)${NC}"
    echo
    
    read -p "Vuoi installare TraffMonetizer ORA? (s/n) " -r
    
    if [[ ! "$REPLY" =~ ^[Ss]$ ]]; then
        log_info "TraffMonetizer non configurato. Puoi installarlo in seguito con:"
        echo
        echo -e "  ${CYAN}curl -fsSL https://traffmonetizer.com/install.sh | sudo bash${NC}"
        echo
        return 0
    fi
    
    echo
    log_info "Avvio installer di TraffMonetizer..."
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
    echo "L'installer verrà eseguito in background."
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
    echo
    
    # Esegui l'installer in background
    sudo bash <(curl -fsSL https://traffmonetizer.com/install.sh 2>/dev/null) >/dev/null 2>&1 &
    
    local pid=$!
    local count=0
    
    # Attendi massimo 120 secondi
    while [[ $count -lt 120 ]] && kill -0 $pid 2>/dev/null; do
        sleep 1
        ((count++))
        if [[ $((count % 10)) -eq 0 ]]; then
            echo -ne "\r[...] Installazione in corso ($count s)"
        fi
    done
    
    echo
    echo
    
    # Verifica se è stato installato
    sleep 2
    if command -v tm >/dev/null 2>&1; then
        log_success "✓ TraffMonetizer installato con successo!"
        sudo systemctl enable traffmonetizer 2>/dev/null || true
        sudo systemctl start traffmonetizer 2>/dev/null || true
    else
        log_warning "TraffMonetizer: installazione in background"
        log_info "Verifica con: systemctl status traffmonetizer"
    fi
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
    
    # Installazione interattiva servizi di sistema
    echo
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Installazione Servizi di Sistema (Opzionale)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo
    
    install_earnapp_interactive
    
    # Riepilogo
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Configurazione Completata!                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo
    log_success "File .env creato con successo!"
    echo
    echo -e "${BLUE}Prossimi passi:${NC}"
    echo -e "  1. Avvia i servizi: ${GREEN}./manage.sh start${NC}"
    echo -e "  2. Accedi a: ${CYAN}http://pipassive.local:8888${NC}"
    echo -e "  3. Configura da web: ${CYAN}http://pipassive.local:8888/setup${NC}"
    echo
    echo -e "${CYAN}Servizi disponibili:${NC}"
    echo -e "  • 8 servizi Docker (Honeygain, Pawns, PacketStream, Repocket, EarnFM, MystNode, PacketShare, TraffMonetizer)"
    if command -v earnapp >/dev/null 2>&1; then
        echo -e "  • ${GREEN}✓${NC} EarnApp (servizio di sistema - installato)"
    else
        echo -e "  • ○ EarnApp (opzionale - non installato)"
    fi
    echo
    echo -e "${YELLOW}⚠️  IMPORTANTE - LEGGI:${NC}"
    echo -e "  🔴 ${RED}MystNode richiede configurazione manuale!${NC}"
    echo -e "     Dopo 'manage.sh start', vai su: ${CYAN}http://pipassive.local:4449${NC}"
    echo -e "     e completa la procedura di setup sulla dashboard."
    echo
    log_warning "Non condividere mai il file .env!"
    echo
}

# Esegui main
main "$@"
