#!/bin/bash

################################################################################
# PiPassive - Script di Installazione Automatica
# Installa Docker, Docker Compose e prepara l'ambiente per i servizi di passive income
################################################################################

set -e  # Exit on error

# Colors per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo ASCII
print_logo() {
    echo -e "${BLUE}"
    cat << "EOF"
    ____  _ ____                  _           
   |  _ \(_)  _ \ __ _ ___ ___(_)_   _____  
   | |_) | | |_) / _` / __/ __| \ \ / / _ \ 
   |  __/| |  __/ (_| \__ \__ \ |\ V /  __/ 
   |_|   |_|_|   \__,_|___/___/_| \_/ \___| 
                                             
   Raspberry Pi Passive Income Automator
EOF
    echo -e "${NC}"
}

# Funzioni di logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Controlla se è root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Non eseguire questo script come root o con sudo!"
        log_info "Lo script richiederà i permessi sudo quando necessario."
        exit 1
    fi
}

# Controlla sistema operativo
check_system() {
    log_info "Controllo sistema operativo..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        log_success "Sistema rilevato: $PRETTY_NAME"
    else
        log_error "Sistema operativo non supportato!"
        exit 1
    fi
    
    # Controlla architettura
    ARCH=$(uname -m)
    log_info "Architettura: $ARCH"
    
    if [[ "$ARCH" != "armv7l" && "$ARCH" != "aarch64" && "$ARCH" != "x86_64" ]]; then
        log_warning "Architettura non testata: $ARCH"
        read -p "Vuoi continuare comunque? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Aggiorna sistema
update_system() {
    log_info "Aggiornamento sistema..."
    sudo apt-get update -qq
    sudo apt-get upgrade -y -qq
    log_success "Sistema aggiornato!"
}

# Installa dipendenze
install_dependencies() {
    log_info "Installazione dipendenze..."
    sudo apt-get install -y -qq \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        git \
        jq \
        htop \
        nano
    log_success "Dipendenze installate!"
}

# Installa Docker
install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker già installato ($(docker --version))"
        return
    fi
    
    log_info "Installazione Docker..."
    
    # Rimuovi vecchie versioni
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Aggiungi repository Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    
    # Aggiungi utente al gruppo docker
    sudo usermod -aG docker $USER
    
    log_success "Docker installato!"
    log_warning "Dovrai fare logout e login per applicare i permessi del gruppo docker"
}

# Installa Docker Compose
install_docker_compose() {
    log_info "Controllo Docker Compose..."
    
    # Docker Compose v2 è incluso in Docker Desktop e nelle versioni recenti
    if docker compose version &> /dev/null; then
        log_success "Docker Compose v2 già disponibile ($(docker compose version))"
        return
    fi
    
    # Fallback per installazione manuale
    log_info "Installazione Docker Compose v2..."
    
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    
    # Scarica Docker Compose
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
    
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        COMPOSE_ARCH="aarch64"
    elif [[ "$ARCH" == "armv7l" ]]; then
        COMPOSE_ARCH="armv7"
    elif [[ "$ARCH" == "x86_64" ]]; then
        COMPOSE_ARCH="x86_64"
    else
        COMPOSE_ARCH="x86_64"
    fi
    
    curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${COMPOSE_ARCH}" \
        -o $DOCKER_CONFIG/cli-plugins/docker-compose
    
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
    
    log_success "Docker Compose installato!"
}

# Crea directory necessarie
create_directories() {
    log_info "Creazione directory..."
    
    mkdir -p configs/{honeygain,earnapp,pawns,packetstream,traffmonetizer,repocket,earnfm,mystnode,packetshare}
    mkdir -p data/{honeygain,earnapp,pawns,packetstream,traffmonetizer,repocket,earnfm,mystnode,packetshare}
    mkdir -p logs
    mkdir -p backups
    
    log_success "Directory create!"
}

# Copia file di esempio
setup_config_files() {
    log_info "Setup file di configurazione..."
    
    if [[ ! -f .env ]]; then
        if [[ -f .env.example ]]; then
            cp .env.example .env
            log_success "File .env creato da template"
            log_warning "IMPORTANTE: Configura il file .env con le tue credenziali!"
        else
            log_warning "File .env.example non trovato"
        fi
    else
        log_info "File .env già esistente, non sovrascritto"
    fi
}

# Ottimizzazioni per Raspberry Pi
optimize_raspberry_pi() {
    log_info "Applicazione ottimizzazioni per Raspberry Pi..."
    
    # Aumenta memoria disponibile per containers
    if ! grep -q "vm.max_map_count" /etc/sysctl.conf; then
        echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
    fi
    
    # Ottimizza swap per Raspberry Pi
    if [[ -f /etc/dphys-swapfile ]]; then
        sudo dphys-swapfile swapoff || true
        sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile 2>/dev/null || true
        sudo dphys-swapfile setup || true
        sudo dphys-swapfile swapon || true
    fi
    
    log_success "Ottimizzazioni applicate!"
}

# Test installazione Docker
test_docker() {
    log_info "Test installazione Docker..."
    
    # Controlla se possiamo eseguire docker senza sudo
    if docker ps &> /dev/null; then
        log_success "Docker funziona correttamente!"
        docker run --rm hello-world > /dev/null 2>&1
        log_success "Test container completato!"
    else
        log_warning "Non puoi eseguire docker senza sudo"
        log_info "Esegui: newgrp docker"
        log_info "Oppure fai logout/login per applicare i permessi"
    fi
}

# Rendi eseguibili gli script
make_scripts_executable() {
    log_info "Impostazione permessi script..."
    
    chmod +x setup.sh 2>/dev/null || true
    chmod +x manage.sh 2>/dev/null || true
    chmod +x dashboard.sh 2>/dev/null || true
    chmod +x backup.sh 2>/dev/null || true
    chmod +x restore.sh 2>/dev/null || true
    
    log_success "Permessi impostati!"
}

# Riepilogo finale
print_summary() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Installazione Completata con Successo!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}Prossimi passi:${NC}"
    echo
    echo -e "  1. ${YELLOW}Ricarica i permessi del gruppo docker:${NC}"
    echo -e "     ${GREEN}newgrp docker${NC}"
    echo
    echo -e "  2. ${YELLOW}Configura le tue credenziali:${NC}"
    echo -e "     ${GREEN}./setup.sh${NC}"
    echo
    echo -e "  3. ${YELLOW}Avvia i servizi:${NC}"
    echo -e "     ${GREEN}./manage.sh start${NC}"
    echo
    echo -e "  4. ${YELLOW}Monitora lo stato:${NC}"
    echo -e "     ${GREEN}./dashboard.sh${NC}"
    echo
    echo -e "${BLUE}Documentazione:${NC}"
    echo -e "  • README.md - Guida completa"
    echo -e "  • docs/services.md - Come ottenere API keys"
    echo -e "  • docs/troubleshooting.md - Risoluzione problemi"
    echo
    echo -e "${YELLOW}Note importanti:${NC}"
    echo -e "  • Il file .env contiene le tue credenziali (NON condividerlo!)"
    echo -e "  • Esegui backup regolari: ./backup.sh"
    echo -e "  • Monitora i logs: ./manage.sh logs <servizio>"
    echo
}

# Main
main() {
    print_logo
    
    log_info "Inizio installazione PiPassive..."
    echo
    
    check_root
    check_system
    
    echo
    read -p "Procedere con l'installazione? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installazione annullata."
        exit 0
    fi
    
    echo
    log_info "=== FASE 1: Aggiornamento Sistema ==="
    update_system
    
    echo
    log_info "=== FASE 2: Installazione Dipendenze ==="
    install_dependencies
    
    echo
    log_info "=== FASE 3: Installazione Docker ==="
    install_docker
    
    echo
    log_info "=== FASE 4: Installazione Docker Compose ==="
    install_docker_compose
    
    echo
    log_info "=== FASE 5: Creazione Directory ==="
    create_directories
    
    echo
    log_info "=== FASE 6: Setup Configurazione ==="
    setup_config_files
    
    echo
    log_info "=== FASE 7: Ottimizzazioni Sistema ==="
    optimize_raspberry_pi
    
    echo
    log_info "=== FASE 8: Impostazione Permessi ==="
    make_scripts_executable
    
    echo
    log_info "=== FASE 9: Test Installazione ==="
    test_docker
    
    echo
    print_summary
}

# Esegui main
main "$@"
