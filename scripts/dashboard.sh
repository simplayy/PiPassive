#!/bin/bash

################################################################################
# PiPassive - Dashboard di Monitoraggio
# Visualizza in tempo reale lo stato di tutti i servizi
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m'
BOLD='\033[1m'

# Refresh rate in secondi
REFRESH_RATE=5

# Lista servizi Docker
SERVICES=(
    "honeygain:Honeygain"
    "pawns:Pawns.app"
    "packetstream:PacketStream"
    "repocket:Repocket"
    "earnfm:EarnFM"
    "mystnode:MystNode"
    "packetshare:PacketShare"
    "traffmonetizer:TraffMonetizer"
)

# Funzione per ottenere lo stato di un container
get_container_status() {
    local container=$1
    local status=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null || echo "not_found")
    echo "$status"
}

# Funzione per ottenere l'uptime di un container
get_container_uptime() {
    local container=$1
    local started=$(docker inspect -f '{{.State.StartedAt}}' "$container" 2>/dev/null)
    
    if [[ -z "$started" || "$started" == "<no value>" ]]; then
        echo "N/A"
        return
    fi
    
    local started_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$(echo $started | cut -d'.' -f1)" "+%s" 2>/dev/null || echo "0")
    local current_epoch=$(date "+%s")
    local uptime=$((current_epoch - started_epoch))
    
    if [[ $uptime -lt 60 ]]; then
        echo "${uptime}s"
    elif [[ $uptime -lt 3600 ]]; then
        echo "$((uptime / 60))m"
    elif [[ $uptime -lt 86400 ]]; then
        echo "$((uptime / 3600))h $((uptime % 3600 / 60))m"
    else
        echo "$((uptime / 86400))d $((uptime % 86400 / 3600))h"
    fi
}

# Funzione per ottenere CPU e memoria
get_container_resources() {
    local container=$1
    local stats=$(docker stats "$container" --no-stream --format "{{.CPUPerc}}|{{.MemUsage}}" 2>/dev/null || echo "N/A|N/A")
    echo "$stats"
}

# Funzione per disegnare una barra di progresso
draw_progress_bar() {
    local percentage=$1
    local width=20
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "]"
}

# Header della dashboard
print_dashboard_header() {
    clear
    
    echo -e "${BOLD}${MAGENTA}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🍓 PiPassive - Dashboard Monitoraggio                    ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Info sistema
    local uptime=$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
    local load=$(uptime | awk -F'load average: ' '{print $2}')
    local ip=$(hostname -I | awk '{print $1}')
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${CYAN}Sistema:${NC} Raspberry Pi | ${CYAN}IP:${NC} $ip | ${CYAN}Uptime:${NC} $uptime"
    echo -e "${CYAN}Load:${NC} $load | ${CYAN}Aggiornato:${NC} $timestamp"
    echo
}

# Sezione status servizi
print_services_status() {
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}                              STATUS SERVIZI${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    printf "${BOLD}%-20s %-12s %-15s %-10s %-20s${NC}\n" "SERVIZIO" "STATUS" "UPTIME" "CPU" "MEMORIA"
    echo "───────────────────────────────────────────────────────────────────────────────"
    
    local running_count=0
    local total_count=${#SERVICES[@]}
    
    for service_entry in "${SERVICES[@]}"; do
        local container=$(echo "$service_entry" | cut -d':' -f1)
        local name=$(echo "$service_entry" | cut -d':' -f2)
        
        local status=$(get_container_status "$container")
        local uptime=$(get_container_uptime "$container")
        local resources=$(get_container_resources "$container")
        local cpu=$(echo "$resources" | cut -d'|' -f1)
        local mem=$(echo "$resources" | cut -d'|' -f2 | awk '{print $1}')
        
        # Colore status
        local status_color=$RED
        local status_icon="✗"
        local status_text="OFFLINE"
        
        if [[ "$status" == "running" ]]; then
            status_color=$GREEN
            status_icon="✓"
            status_text="RUNNING"
            ((running_count++))
        elif [[ "$status" == "restarting" ]]; then
            status_color=$YELLOW
            status_icon="↻"
            status_text="RESTART"
        elif [[ "$status" == "paused" ]]; then
            status_color=$YELLOW
            status_icon="⏸"
            status_text="PAUSED"
        fi
        
        printf "%-20s ${status_color}${status_icon} %-10s${NC} %-15s %-10s %-20s\n" \
            "$name" "$status_text" "$uptime" "$cpu" "$mem"
    done
    
    echo "───────────────────────────────────────────────────────────────────────────────"
    
    # Riepilogo
    local percentage=$((running_count * 100 / total_count))
    echo -e "\n${BOLD}Servizi Attivi:${NC} $running_count/$total_count $(draw_progress_bar $percentage) ${percentage}%"
    echo
}

# Sezione risorse sistema
print_system_resources() {
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}                            RISORSE SISTEMA${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    # CPU
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' || echo "0")
    echo -e "${CYAN}CPU Usage:${NC}"
    draw_progress_bar ${cpu_usage%.*}
    echo -e " ${cpu_usage}%"
    echo
    
    # Memoria
    local mem_info=$(vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("$1:$2\n");' | awk -F: '
        /free/ {free=$2} 
        /active/ {active=$2} 
        /inactive/ {inactive=$2} 
        /speculative/ {speculative=$2}
        /wired/ {wired=$2}
        END {
            total=(free+active+inactive+speculative+wired)*4096/1024/1024/1024;
            used=(active+wired)*4096/1024/1024/1024;
            printf "%.1f %.1f", used, total
        }')
    
    local mem_used=$(echo $mem_info | cut -d' ' -f1)
    local mem_total=$(echo $mem_info | cut -d' ' -f2)
    local mem_percentage=$(echo "scale=0; $mem_used * 100 / $mem_total" | bc)
    
    echo -e "${CYAN}Memoria:${NC}"
    draw_progress_bar $mem_percentage
    echo -e " ${mem_used}GB / ${mem_total}GB (${mem_percentage}%)"
    echo
    
    # Disco
    local disk_info=$(df -h / | tail -1)
    local disk_used=$(echo $disk_info | awk '{print $3}')
    local disk_total=$(echo $disk_info | awk '{print $2}')
    local disk_percentage=$(echo $disk_info | awk '{print $5}' | sed 's/%//')
    
    echo -e "${CYAN}Disco /:${NC}"
    draw_progress_bar $disk_percentage
    echo -e " ${disk_used} / ${disk_total} (${disk_percentage}%)"
    echo
    
    # Network
    local network_rx=$(netstat -ibn | awk '/en0/{getline; print $7}' | head -1)
    local network_tx=$(netstat -ibn | awk '/en0/{getline; print $10}' | head -1)
    
    if [[ -n "$network_rx" ]]; then
        local network_rx_gb=$(echo "scale=2; $network_rx / 1024 / 1024 / 1024" | bc)
        local network_tx_gb=$(echo "scale=2; $network_tx / 1024 / 1024 / 1024" | bc)
        echo -e "${CYAN}Network:${NC} ↓ ${network_rx_gb}GB | ↑ ${network_tx_gb}GB"
    fi
    
    echo
}

# Sezione logs recenti
print_recent_logs() {
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}                            LOGS RECENTI${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Prendi ultimi 5 logs da tutti i container
    docker compose logs --tail=5 --no-log-prefix 2>/dev/null | tail -10 || echo "Nessun log disponibile"
    
    echo
}

# Footer
print_footer() {
    echo -e "${GRAY}───────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}Comandi:${NC} [q] Esci | [r] Aggiorna ora | [l] Logs | [s] Stats"
    echo -e "${CYAN}Auto-refresh:${NC} ogni ${REFRESH_RATE} secondi"
}

# Main loop
main() {
    # Controlla Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker non installato!${NC}"
        exit 1
    fi
    
    if ! docker ps &> /dev/null; then
        echo -e "${RED}Docker non in esecuzione o permessi insufficienti!${NC}"
        exit 1
    fi
    
    # Loop principale
    while true; do
        print_dashboard_header
        print_services_status
        print_system_resources
        print_recent_logs
        print_footer
        
        # Wait con timeout per permettere input
        read -t $REFRESH_RATE -n 1 key 2>/dev/null || true
        
        case "$key" in
            q|Q)
                clear
                echo -e "${GREEN}Dashboard chiusa. Arrivederci!${NC}"
                exit 0
                ;;
            r|R)
                continue
                ;;
            l|L)
                clear
                echo -e "${CYAN}Mostra logs completi...${NC}"
                docker compose logs --tail=50
                echo
                read -p "Premi INVIO per tornare alla dashboard..."
                ;;
            s|S)
                clear
                echo -e "${CYAN}Statistiche dettagliate (CTRL+C per uscire)...${NC}"
                docker stats
                ;;
        esac
    done
}

# Trap per pulizia
trap 'clear; echo -e "${GREEN}Dashboard chiusa.${NC}"; exit 0' INT TERM

# Esegui main
main "$@"
