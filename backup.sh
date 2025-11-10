#!/bin/bash

################################################################################
# PiPassive - Script di Backup
# Crea backup completo di configurazioni e dati
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
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="pipassive_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

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
    ║         PiPassive - Backup Configurazione              ║
    ╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Crea directory backup
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log_success "Directory backup creata: $BACKUP_DIR"
    fi
    
    mkdir -p "$BACKUP_PATH"
}

# Backup file .env
backup_env() {
    log_info "Backup file .env..."
    
    if [[ -f .env ]]; then
        cp .env "${BACKUP_PATH}/.env"
        log_success "File .env salvato"
    else
        log_warning "File .env non trovato"
    fi
}

# Backup docker-compose.yml
backup_compose() {
    log_info "Backup docker-compose.yml..."
    
    if [[ -f docker-compose.yml ]]; then
        cp docker-compose.yml "${BACKUP_PATH}/docker-compose.yml"
        log_success "File docker-compose.yml salvato"
    else
        log_warning "File docker-compose.yml non trovato"
    fi
}

# Backup configurazioni
backup_configs() {
    log_info "Backup configurazioni servizi..."
    
    if [[ -d configs ]]; then
        cp -r configs "${BACKUP_PATH}/"
        log_success "Configurazioni salvate"
    else
        log_warning "Directory configs non trovata"
    fi
}

# Backup dati (opzionale, può essere grande)
backup_data() {
    echo
    read -p "Vuoi includere i dati dei servizi? Può richiedere molto spazio. (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Backup dati servizi... (può richiedere tempo)"
        
        if [[ -d data ]]; then
            cp -r data "${BACKUP_PATH}/"
            log_success "Dati salvati"
        else
            log_warning "Directory data non trovata"
        fi
    else
        log_info "Dati esclusi dal backup"
    fi
}

# Backup script personalizzati
backup_scripts() {
    log_info "Backup script..."
    
    local scripts=("install.sh" "setup.sh" "manage.sh" "dashboard.sh" "backup.sh" "restore.sh")
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            cp "$script" "${BACKUP_PATH}/"
        fi
    done
    
    log_success "Script salvati"
}

# Backup documentazione
backup_docs() {
    log_info "Backup documentazione..."
    
    if [[ -d docs ]]; then
        cp -r docs "${BACKUP_PATH}/"
        log_success "Documentazione salvata"
    fi
    
    if [[ -f README.md ]]; then
        cp README.md "${BACKUP_PATH}/"
    fi
}

# Crea info backup
create_backup_info() {
    log_info "Creazione file info backup..."
    
    cat > "${BACKUP_PATH}/backup_info.txt" << EOF
PiPassive Backup Information
============================

Backup creato: $(date '+%Y-%m-%d %H:%M:%S')
Hostname: $(hostname)
Sistema: $(uname -a)
Utente: $(whoami)

Contenuto del backup:
- File .env (configurazioni credenziali)
- docker-compose.yml
- Configurazioni servizi (configs/)
- Script di gestione
- Documentazione

Versioni:
- Docker: $(docker --version 2>/dev/null || echo "N/A")
- Docker Compose: $(docker compose version 2>/dev/null || echo "N/A")

Note:
$(if [[ -d "${BACKUP_PATH}/data" ]]; then echo "- Dati servizi inclusi"; else echo "- Dati servizi NON inclusi"; fi)

Per ripristinare questo backup:
./restore.sh ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz
EOF
    
    log_success "File info creato"
}

# Comprimi backup
compress_backup() {
    log_info "Compressione backup..."
    
    cd "$BACKUP_DIR"
    tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
    cd ..
    
    # Rimuovi directory temporanea
    rm -rf "$BACKUP_PATH"
    
    local size=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)
    log_success "Backup compresso: ${BACKUP_NAME}.tar.gz ($size)"
}

# Pulisci vecchi backup
cleanup_old_backups() {
    echo
    read -p "Vuoi mantenere solo gli ultimi 5 backup? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Pulizia vecchi backup..."
        
        cd "$BACKUP_DIR"
        ls -t pipassive_backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm
        cd ..
        
        log_success "Vecchi backup rimossi"
    fi
}

# Lista backup esistenti
list_backups() {
    if [[ -d "$BACKUP_DIR" ]] && [[ $(ls -A "$BACKUP_DIR" 2>/dev/null) ]]; then
        echo
        echo -e "${CYAN}Backup esistenti:${NC}"
        echo "────────────────────────────────────────────────────────"
        
        for backup in "$BACKUP_DIR"/*.tar.gz; do
            if [[ -f "$backup" ]]; then
                local filename=$(basename "$backup")
                local size=$(du -h "$backup" | cut -f1)
                local date=$(echo "$filename" | sed 's/pipassive_backup_//' | sed 's/.tar.gz//' | sed 's/_/ /')
                echo -e "${GREEN}•${NC} $filename ${YELLOW}($size)${NC} - $date"
            fi
        done
        
        echo "────────────────────────────────────────────────────────"
    fi
}

# Riepilogo
print_summary() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Backup Completato con Successo!                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}Backup salvato in:${NC}"
    echo -e "  ${GREEN}${BACKUP_DIR}/${BACKUP_NAME}.tar.gz${NC}"
    echo
    echo -e "${CYAN}Per ripristinare:${NC}"
    echo -e "  ${YELLOW}./restore.sh ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz${NC}"
    echo
    echo -e "${CYAN}Consiglio:${NC}"
    echo -e "  • Copia il backup in un luogo sicuro (USB, cloud, ecc.)"
    echo -e "  • Esegui backup regolari delle configurazioni"
    echo -e "  • Testa periodicamente il ripristino"
    echo
}

# Main
main() {
    print_header
    
    log_info "Inizio processo di backup..."
    echo
    
    create_backup_dir
    backup_env
    backup_compose
    backup_configs
    backup_scripts
    backup_docs
    backup_data
    create_backup_info
    compress_backup
    cleanup_old_backups
    
    print_summary
    list_backups
}

# Esegui main
main "$@"
