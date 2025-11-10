#!/bin/bash

################################################################################
# PiPassive - Script di Gestione Servizi
# Gestisce avvio, stop, restart e monitoring dei servizi
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

# Configurazione
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"

# Lista servizi
SERVICES=(
    "honeygain"
    "earnapp"
    "pawns"
    "packetstream"
    "traffmonetizer"
    "repocket"
    "earnfm"
    "mystnode"
    "packetshare"
)

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

# Controlla se Docker è installato
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker non è installato!"
        log_info "Esegui: ./install.sh"
        exit 1
    fi
    
    if ! docker ps &> /dev/null; then
        log_error "Docker non è in esecuzione o non hai i permessi!"
        log_info "Prova: sudo usermod -aG docker $USER && newgrp docker"
        exit 1
    fi
}

# Controlla se il file .env esiste
check_env() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error "File .env non trovato!"
        log_info "Esegui: ./setup.sh"
        exit 1
    fi
}

# Header
print_header() {
    echo -e "${MAGENTA}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════╗
    ║         PiPassive - Gestione Servizi                   ║
    ╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Avvia tutti i servizi
start_all() {
    log_info "Avvio di tutti i servizi..."
    
    docker compose up -d
    
    echo
    log_success "Tutti i servizi sono stati avviati!"
    echo
    log_info "Usa './manage.sh status' per verificare lo stato"
    log_info "Usa './dashboard.sh' per il monitoraggio in tempo reale"
}

# Avvia un singolo servizio
start_service() {
    local service=$1
    
    if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
        log_error "Servizio '$service' non riconosciuto!"
        list_services
        exit 1
    fi
    
    log_info "Avvio di $service..."
    docker compose up -d "$service"
    log_success "$service avviato!"
}

# Ferma tutti i servizi
stop_all() {
    log_info "Arresto di tutti i servizi..."
    
    docker compose down
    
    log_success "Tutti i servizi sono stati fermati!"
}

# Ferma un singolo servizio
stop_service() {
    local service=$1
    
    if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
        log_error "Servizio '$service' non riconosciuto!"
        list_services
        exit 1
    fi
    
    log_info "Arresto di $service..."
    docker compose stop "$service"
    log_success "$service fermato!"
}

# Riavvia tutti i servizi
restart_all() {
    log_info "Riavvio di tutti i servizi..."
    
    docker compose restart
    
    log_success "Tutti i servizi sono stati riavviati!"
}

# Riavvia un singolo servizio
restart_service() {
    local service=$1
    
    if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
        log_error "Servizio '$service' non riconosciuto!"
        list_services
        exit 1
    fi
    
    log_info "Riavvio di $service..."
    docker compose restart "$service"
    log_success "$service riavviato!"
}

# Mostra status di tutti i servizi
show_status() {
    echo
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}         Status Servizi PiPassive${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo
    
    docker compose ps
    
    echo
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo
    
    # Conta servizi attivi
    local running=$(docker compose ps --services --filter "status=running" | wc -l)
    local total=${#SERVICES[@]}
    
    if [[ $running -eq $total ]]; then
        log_success "Tutti i servizi sono attivi ($running/$total)"
    elif [[ $running -gt 0 ]]; then
        log_warning "Alcuni servizi sono attivi ($running/$total)"
    else
        log_error "Nessun servizio attivo (0/$total)"
    fi
}

# Mostra logs di un servizio
show_logs() {
    local service=$1
    local follow=${2:-false}
    
    if [[ -z "$service" ]]; then
        log_info "Logs di tutti i servizi (ultimi 50 righe)..."
        docker compose logs --tail=50
    else
        if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
            log_error "Servizio '$service' non riconosciuto!"
            list_services
            exit 1
        fi
        
        if [[ "$follow" == "true" ]]; then
            log_info "Logs di $service (segui in tempo reale - CTRL+C per uscire)..."
            docker compose logs -f "$service"
        else
            log_info "Logs di $service (ultimi 100 righe)..."
            docker compose logs --tail=100 "$service"
        fi
    fi
}

# Aggiorna tutti i container
update_all() {
    log_info "Aggiornamento di tutti i container..."
    
    # Pull nuove immagini
    log_info "Download nuove immagini..."
    docker compose pull
    
    # Riavvia con nuove immagini
    log_info "Riavvio servizi con nuove immagini..."
    docker compose up -d
    
    # Rimuovi immagini vecchie
    log_info "Pulizia immagini vecchie..."
    docker image prune -f
    
    log_success "Aggiornamento completato!"
}

# Pulisci container e volumi
clean() {
    log_warning "Questa operazione rimuoverà tutti i container e i dati!"
    read -p "Sei sicuro? (yes/no) " -r
    echo
    
    if [[ "$REPLY" != "yes" ]]; then
        log_info "Operazione annullata."
        exit 0
    fi
    
    log_info "Pulizia in corso..."
    
    # Ferma e rimuovi container
    docker compose down -v
    
    # Rimuovi dati
    read -p "Vuoi rimuovere anche i dati dei servizi? (yes/no) " -r
    echo
    if [[ "$REPLY" == "yes" ]]; then
        rm -rf data/*
        log_success "Dati rimossi!"
    fi
    
    log_success "Pulizia completata!"
}

# Lista servizi disponibili
list_services() {
    echo
    echo -e "${CYAN}Servizi disponibili:${NC}"
    for service in "${SERVICES[@]}"; do
        echo -e "  • ${GREEN}$service${NC}"
    done
    echo
}

# Statistiche risorse
show_stats() {
    log_info "Statistiche risorse (CTRL+C per uscire)..."
    docker stats $(docker compose ps -q)
}

# Menu di aiuto
show_help() {
    print_header
    
    cat << EOF
${CYAN}Uso:${NC}
    ./manage.sh <comando> [servizio]

${CYAN}Comandi:${NC}
    ${GREEN}start${NC} [servizio]       Avvia tutti i servizi o uno specifico
    ${GREEN}stop${NC} [servizio]        Ferma tutti i servizi o uno specifico
    ${GREEN}restart${NC} [servizio]     Riavvia tutti i servizi o uno specifico
    ${GREEN}status${NC}                 Mostra lo status di tutti i servizi
    ${GREEN}logs${NC} [servizio]        Mostra i logs (ultimo 100 righe)
    ${GREEN}follow${NC} <servizio>      Segui i logs in tempo reale
    ${GREEN}update${NC}                 Aggiorna tutti i container
    ${GREEN}stats${NC}                  Mostra statistiche risorse
    ${GREEN}clean${NC}                  Rimuovi tutti i container e dati
    ${GREEN}list${NC}                   Lista servizi disponibili
    ${GREEN}help${NC}                   Mostra questo messaggio

${CYAN}Esempi:${NC}
    ./manage.sh start              # Avvia tutti i servizi
    ./manage.sh start honeygain    # Avvia solo Honeygain
    ./manage.sh stop earnapp       # Ferma solo EarnApp
    ./manage.sh logs mystnode      # Mostra logs di MystNode
    ./manage.sh follow pawns       # Segui logs di Pawns in tempo reale
    ./manage.sh restart            # Riavvia tutti i servizi
    ./manage.sh update             # Aggiorna tutti i container

${CYAN}Servizi disponibili:${NC}
EOF
    
    for service in "${SERVICES[@]}"; do
        echo -e "    • ${GREEN}$service${NC}"
    done
    
    echo
}

# Main
main() {
    local command=${1:-help}
    local service=$2
    
    # Comandi che non richiedono controlli
    if [[ "$command" == "help" || "$command" == "-h" || "$command" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    if [[ "$command" == "list" ]]; then
        list_services
        exit 0
    fi
    
    # Controlli prerequisiti
    check_docker
    check_env
    
    # Esegui comando
    case "$command" in
        start)
            print_header
            if [[ -z "$service" ]]; then
                start_all
            else
                start_service "$service"
            fi
            ;;
        stop)
            print_header
            if [[ -z "$service" ]]; then
                stop_all
            else
                stop_service "$service"
            fi
            ;;
        restart)
            print_header
            if [[ -z "$service" ]]; then
                restart_all
            else
                restart_service "$service"
            fi
            ;;
        status)
            print_header
            show_status
            ;;
        logs)
            show_logs "$service" false
            ;;
        follow)
            if [[ -z "$service" ]]; then
                log_error "Specifica un servizio per seguire i logs!"
                list_services
                exit 1
            fi
            show_logs "$service" true
            ;;
        update)
            print_header
            update_all
            ;;
        stats)
            print_header
            show_stats
            ;;
        clean)
            print_header
            clean
            ;;
        *)
            log_error "Comando '$command' non riconosciuto!"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Esegui main
main "$@"
