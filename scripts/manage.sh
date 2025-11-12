#!/bin/bash

################################################################################
# PiPassive - Service Management Script
# Manages start, stop, restart and monitoring of services
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
COMPOSE_FILE="config/docker-compose.yml"
ENV_FILE=".env"

# Docker services list
SERVICES=(
    "honeygain"
    "pawns"
    "packetstream"
    "repocket"
    "earnfm"
    "mystnode"
    "packetshare"
    "traffmonetizer"
)

# Logging functions
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

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed!"
        log_info "Run: ./install.sh"
        exit 1
    fi

    if ! docker ps &> /dev/null; then
        log_error "Docker is not running or you don't have permissions!"
        log_info "Try: sudo usermod -aG docker $USER && newgrp docker"
        exit 1
    fi
}

# Check if .env file exists
check_env() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error ".env file not found!"
        log_info "Run: ./setup.sh"
        exit 1
    fi
}

# Header
print_header() {
    echo -e "${MAGENTA}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════╗
    ║         PiPassive - Service Management                 ║
    ╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Web service is now created during installation (install.sh)
# This function has been removed to avoid conflicts

# Start all services
start_all() {
    log_info "Starting all services..."
    echo

    # Web service is created during installation

    # Start web service
    log_info "Starting web server..."
    if sudo systemctl is-active --quiet pipassive-web.service 2>/dev/null; then
        log_info "Web server already active"
    else
        sudo systemctl start pipassive-web.service
        sleep 2
        if sudo systemctl is-active --quiet pipassive-web.service; then
            log_success "Web server started automatically"
        else
            log_warning "Web server did not start, checking logs..."
            sudo systemctl status pipassive-web.service --no-pager -l || true
        fi
    fi

    docker compose up -d

    echo
    log_success "All Docker containers have been started!"
    echo
    log_info "Web dashboard always active: http://pipassive.local"
    log_info "Configuration: http://pipassive.local/setup"
    log_info ""
    log_info "Use './manage.sh status' to check status"
}

# Start a single service
start_service() {
    local service=$1

    if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
        log_error "Service '$service' not recognized!"
        list_services
        exit 1
    fi

    log_info "Starting $service..."
    docker compose up -d "$service"
    log_success "$service started!"
}

# Stop all services
stop_all() {
    log_info "Stopping all services..."

    # Stop web server
    if sudo systemctl is-active --quiet pipassive-web.service 2>/dev/null; then
        sudo systemctl stop pipassive-web.service
        log_info "Web server stopped"
    fi

    docker compose down

    log_success "All services have been stopped!"
}

# Stop a single service
stop_service() {
    local service=$1

    if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
        log_error "Service '$service' not recognized!"
        list_services
        exit 1
    fi

    log_info "Stopping $service..."
    docker compose stop "$service"
    log_success "$service stopped!"
}

# Restart all services
restart_all() {
    log_info "Restarting all services..."

    # Restart web server
    if sudo systemctl is-active --quiet pipassive-web.service 2>/dev/null; then
        sudo systemctl restart pipassive-web.service
        log_info "Web server restarted"
    fi

    docker compose restart

    log_success "All services have been restarted!"
}

# Restart a single service
restart_service() {
    local service=$1

    if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
        log_error "Service '$service' not recognized!"
        list_services
        exit 1
    fi

    log_info "Restarting $service..."
    docker compose restart "$service"
    log_success "$service restarted!"
}

# Show status of all services
show_status() {
    echo
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}         PiPassive Services Status${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo

    # Show Docker containers
    echo -e "${BLUE}Docker Containers:${NC}"
    docker compose ps

    echo
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo

    # Count active Docker services
    local running=$(docker compose ps --services --filter "status=running" 2>/dev/null | wc -l)
    local total=${#SERVICES[@]}

    if [[ $running -eq $total ]]; then
        log_success "All Docker containers are active ($running/$total)"
    elif [[ $running -gt 0 ]]; then
        log_warning "Some Docker containers are active ($running/$total)"
    else
        log_error "No Docker containers active (0/$total)"
    fi

    echo
    echo -e "${BLUE}System Services (Optional - Non-Docker):${NC}"
    echo

    # Web Server
    if sudo systemctl is-active --quiet pipassive-web.service 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Web Server ${GREEN}(running)${NC} - http://pipassive.local"
    else
        echo -e "  ${YELLOW}○${NC} Web Server (stopped)"
        echo -e "     Start: ${CYAN}./manage.sh start${NC}"
    fi

    # EarnApp
    if systemctl is-active --quiet earnapp 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} EarnApp ${GREEN}(running)${NC}"
    else
        echo -e "  ${YELLOW}○${NC} EarnApp (not installed)"
        echo -e "     Install: ${CYAN}wget -qO- https://brightdata.com/static/earnapp/install.sh > /tmp/earnapp.sh && sudo bash /tmp/earnapp.sh${NC}"
    fi

    echo
}

# Show logs of a service
show_logs() {
    local service=$1
    local follow=${2:-false}

    if [[ -z "$service" ]]; then
        log_info "Logs of all services (last 50 lines)..."
        docker compose logs --tail=50
    else
        if [[ ! " ${SERVICES[@]} " =~ " ${service} " ]]; then
            log_error "Service '$service' not recognized!"
            list_services
            exit 1
        fi

        if [[ "$follow" == "true" ]]; then
            log_info "Logs of $service (follow in real time - CTRL+C to exit)..."
            docker compose logs -f "$service"
        else
            log_info "Logs of $service (last 100 lines)..."
            docker compose logs --tail=100 "$service"
        fi
    fi
}

# Update all containers
update_all() {
    log_info "Updating all containers..."

    # Pull new images
    log_info "Downloading new images..."
    docker compose pull

    # Restart with new images
    log_info "Restarting services with new images..."
    docker compose up -d

    # Remove old images
    log_info "Cleaning old images..."
    docker image prune -f

    log_success "Update completed!"
}

# Clean containers and volumes
clean() {
    log_warning "This operation will remove all containers and data!"
    read -p "Are you sure? (yes/no) " -r
    echo

    if [[ "$REPLY" != "yes" ]]; then
        log_info "Operation cancelled."
        exit 0
    fi

    log_info "Cleaning in progress..."

    # Stop and remove containers
    docker compose down -v

    # Remove data
    read -p "Do you want to remove service data too? (y/n) " -n 1 -r
    echo
    if [[ "$REPLY" == "yes" ]]; then
        rm -rf data/*
        log_success "Data removed!"
    fi

    log_success "Cleaning completed!"
}

# List available services
list_services() {
    echo
    echo -e "${CYAN}Available services:${NC}"
    for service in "${SERVICES[@]}"; do
        echo -e "  • ${GREEN}$service${NC}"
    done
    echo
}

# Show resource statistics
show_stats() {
    log_info "Resource statistics (CTRL+C to exit)..."
    docker stats $(docker compose ps -q)
}

# Help menu
show_help() {
    print_header

    cat << EOF
${CYAN}Usage:${NC}
    ./manage.sh <command> [service]

${CYAN}Commands:${NC}
    ${GREEN}start${NC} [service]       Start all services or a specific one
    ${GREEN}stop${NC} [service]        Stop all services or a specific one
    ${GREEN}restart${NC} [service]     Restart all services or a specific one
    ${GREEN}status${NC}                 Show status of all services
    ${GREEN}logs${NC} [service]        Show logs (last 100 lines)
    ${GREEN}follow${NC} <service>      Follow logs in real time
    ${GREEN}update${NC}                 Update all containers
    ${GREEN}stats${NC}                  Show resource statistics
    ${GREEN}clean${NC}                  Remove all containers and data
    ${GREEN}list${NC}                   List available services
    ${GREEN}help${NC}                   Show this message

${CYAN}Optional services (non-Docker):${NC}
    ${YELLOW}EarnApp${NC}       - Install manually: sudo bash <(wget -qO- https://brightdata.com/static/earnapp/install.sh)
    ${YELLOW}TraffMonetizer${NC} - Install manually: curl -fsSL https://traffmonetizer.com/install.sh | sudo bash

${CYAN}Examples:${NC}
    ./manage.sh start              # Start all services
    ./manage.sh start honeygain    # Start only Honeygain
    ./manage.sh stop earnapp       # Stop only EarnApp
    ./manage.sh logs mystnode      # Show MystNode logs
    ./manage.sh follow pawns       # Follow Pawns logs in real time
    ./manage.sh restart            # Restart all services
    ./manage.sh update             # Update all containers

${CYAN}Available Docker services:${NC}
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

    # Commands that don't require checks
    if [[ "$command" == "help" || "$command" == "-h" || "$command" == "--help" ]]; then
        show_help
        exit 0
    fi

    if [[ "$command" == "list" ]]; then
        list_services
        exit 0
    fi

    # Prerequisites checks
    check_docker
    check_env

    # Execute command
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
                log_error "Specify a service to follow logs!"
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
            log_error "Command '$command' not recognized!"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Execute main
main "$@"
