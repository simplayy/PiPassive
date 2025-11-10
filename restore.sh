#!/bin/bash

################################################################################
# PiPassive - Script di Ripristino
# Ripristina configurazioni e dati da backup
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configurazione
BACKUP_FILE=$1
TEMP_DIR="temp_restore_$$"

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

# Header
print_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════╗
    ║         PiPassive - Ripristino Configurazione          ║
    ╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Controlla argomenti
check_arguments() {
    if [[ -z "$BACKUP_FILE" ]]; then
        log_error "Specifica il file di backup da ripristinare!"
        echo
        echo -e "${CYAN}Uso:${NC}"
        echo -e "  ./restore.sh <file_backup.tar.gz>"
        echo
        list_available_backups
        exit 1
    fi
    
    if [[ ! -f "$BACKUP_FILE" ]]; then
        log_error "File di backup non trovato: $BACKUP_FILE"
        echo
        list_available_backups
        exit 1
    fi
}

# Lista backup disponibili
list_available_backups() {
    if [[ -d "backups" ]] && [[ $(ls -A backups/*.tar.gz 2>/dev/null) ]]; then
        echo -e "${CYAN}Backup disponibili:${NC}"
        echo "────────────────────────────────────────────────────────"
        
        for backup in backups/*.tar.gz; do
            if [[ -f "$backup" ]]; then
                local filename=$(basename "$backup")
                local size=$(du -h "$backup" | cut -f1)
                echo -e "${GREEN}•${NC} $backup ${YELLOW}($size)${NC}"
            fi
        done
        
        echo "────────────────────────────────────────────────────────"
        echo
    else
        log_warning "Nessun backup trovato nella directory backups/"
    fi
}

# Mostra info backup
show_backup_info() {
    log_info "Informazioni sul backup:"
    echo
    
    mkdir -p "$TEMP_DIR"
    tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"
    
    local backup_name=$(ls "$TEMP_DIR")
    
    if [[ -f "$TEMP_DIR/$backup_name/backup_info.txt" ]]; then
        cat "$TEMP_DIR/$backup_name/backup_info.txt"
        echo
    else
        log_warning "File info backup non trovato"
    fi
}

# Conferma ripristino
confirm_restore() {
    echo
    log_warning "ATTENZIONE: Questa operazione sovrascriverà le configurazioni attuali!"
    echo
    read -p "Vuoi creare un backup delle configurazioni attuali prima di procedere? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Creazione backup di sicurezza..."
        ./backup.sh
        echo
    fi
    
    echo
    read -p "Procedere con il ripristino? (yes/no) " -r
    echo
    
    if [[ "$REPLY" != "yes" ]]; then
        log_info "Ripristino annullato."
        cleanup_temp
        exit 0
    fi
}

# Ferma servizi
stop_services() {
    log_info "Arresto servizi in esecuzione..."
    
    if docker compose ps -q 2>/dev/null | grep -q .; then
        docker compose down
        log_success "Servizi fermati"
    else
        log_info "Nessun servizio in esecuzione"
    fi
}

# Ripristina file
restore_files() {
    log_info "Ripristino file di configurazione..."
    
    local backup_name=$(ls "$TEMP_DIR")
    local source="$TEMP_DIR/$backup_name"
    
    # Ripristina .env
    if [[ -f "$source/.env" ]]; then
        cp "$source/.env" .env
        log_success "File .env ripristinato"
    fi
    
    # Ripristina docker-compose.yml
    if [[ -f "$source/docker-compose.yml" ]]; then
        cp "$source/docker-compose.yml" docker-compose.yml
        log_success "File docker-compose.yml ripristinato"
    fi
    
    # Ripristina configurazioni
    if [[ -d "$source/configs" ]]; then
        rm -rf configs
        cp -r "$source/configs" .
        log_success "Configurazioni ripristinate"
    fi
    
    # Ripristina dati (se presenti)
    if [[ -d "$source/data" ]]; then
        echo
        read -p "Ripristinare anche i dati dei servizi? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf data
            cp -r "$source/data" .
            log_success "Dati ripristinati"
        fi
    fi
    
    # Ripristina script
    if [[ -f "$source/install.sh" ]]; then
        cp "$source"/*.sh . 2>/dev/null || true
        chmod +x *.sh 2>/dev/null || true
        log_success "Script ripristinati"
    fi
    
    # Ripristina documentazione
    if [[ -d "$source/docs" ]]; then
        rm -rf docs
        cp -r "$source/docs" . 2>/dev/null || true
    fi
    
    if [[ -f "$source/README.md" ]]; then
        cp "$source/README.md" . 2>/dev/null || true
    fi
}

# Cleanup temporary files
cleanup_temp() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Avvia servizi
start_services() {
    echo
    read -p "Vuoi avviare i servizi ora? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Avvio servizi..."
        docker compose up -d
        log_success "Servizi avviati!"
    else
        log_info "Servizi non avviati. Usa './manage.sh start' per avviarli."
    fi
}

# Riepilogo
print_summary() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Ripristino Completato con Successo!             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}Configurazioni ripristinate da:${NC}"
    echo -e "  ${GREEN}$BACKUP_FILE${NC}"
    echo
    echo -e "${CYAN}Prossimi passi:${NC}"
    echo -e "  1. Verifica le configurazioni: ${YELLOW}cat .env${NC}"
    echo -e "  2. Avvia i servizi: ${GREEN}./manage.sh start${NC}"
    echo -e "  3. Controlla lo stato: ${GREEN}./manage.sh status${NC}"
    echo -e "  4. Monitora: ${GREEN}./dashboard.sh${NC}"
    echo
}

# Main
main() {
    print_header
    
    check_arguments
    show_backup_info
    confirm_restore
    stop_services
    restore_files
    cleanup_temp
    start_services
    print_summary
}

# Trap per cleanup
trap cleanup_temp EXIT

# Esegui main
main "$@"
