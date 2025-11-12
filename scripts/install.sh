#!/bin/bash

################################################################################
# PiPassive - Automatic Installation Script
# Installs Docker, Docker Compose and prepares the environment for passive income services
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Logo
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

# Logging functions
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

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run this script as root or with sudo!"
        log_info "The script will request sudo permissions when necessary."
        exit 1
    fi
}

# Check operating system
check_system() {
    log_info "Checking operating system..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        log_success "System detected: $PRETTY_NAME"
    else
        log_error "Unsupported operating system!"
        exit 1
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    log_info "Architecture: $ARCH"
    
    if [[ "$ARCH" != "armv7l" && "$ARCH" != "aarch64" && "$ARCH" != "x86_64" ]]; then
        log_warning "Untested architecture: $ARCH"
        read -p "Do you want to continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Update system
update_system() {
    log_info "Updating system..."
    sudo apt-get update -qq
    sudo apt-get upgrade -y -qq
    log_success "System updated!"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    sudo apt-get install -y -qq \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        git \
        jq \
        htop \
        nano \
        avahi-daemon \
        avahi-utils
    log_success "Dependencies installed!"
}

# Install Docker
install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker already installed ($(docker --version))"
        return
    fi
    
    log_info "Installing Docker..."
    
    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Add Docker repository
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    log_success "Docker installed!"
    log_warning "You will need to logout and login to apply docker group permissions"
}

# Install Docker Compose
install_docker_compose() {
    log_info "Checking Docker Compose..."
    
    # Docker Compose v2 is included in Docker Desktop and recent versions
    if docker compose version &> /dev/null; then
        log_success "Docker Compose v2 already available ($(docker compose version))"
        return
    fi
    
    # Fallback for manual installation
    log_info "Installing Docker Compose v2..."
    
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    
    # Download Docker Compose
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
    
    log_success "Docker Compose installed!"
}

# Create systemd service for web server
setup_web_service() {
    log_info "Setting up web service systemd..."

    # Get current directory and user for dynamic paths
    CURRENT_DIR="$(pwd)"
    CURRENT_USER="$(whoami)"

    sudo tee /etc/systemd/system/pipassive-web.service > /dev/null << EOF
[Unit]
Description=PiPassive Web Dashboard
After=network.target docker.service
Requires=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=${CURRENT_DIR}
ExecStart=/usr/bin/python3 ${CURRENT_DIR}/src/web-server.py
Restart=always
RestartSec=5
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=PYTHONPATH=${CURRENT_DIR}/src

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable pipassive-web.service
    sudo systemctl start pipassive-web.service

    log_success "Web service configured and started automatically!"
}

# Create necessary directories
create_directories() {
    log_info "Creating directories..."
    
    mkdir -p configs/{honeygain,earnapp,pawns,packetstream,traffmonetizer,repocket,earnfm,mystnode,packetshare}
    mkdir -p data/{honeygain,earnapp,pawns,packetstream,traffmonetizer,repocket,earnfm,mystnode,packetshare}
    mkdir -p logs
    mkdir -p backups
    
    log_success "Directories created!"
}

# Copy example files
setup_config_files() {
    log_info "Setting up configuration files..."
    
    if [[ ! -f .env ]]; then
        if [[ -f .env.example ]]; then
            cp .env.example .env
            log_success "File .env created from template"
            log_warning "IMPORTANT: Configure the .env file with your credentials!"
        else
            log_warning "File .env.example not found"
        fi
    else
        log_info "File .env already exists, not overwritten"
    fi
}

# Optimizations for Raspberry Pi
optimize_raspberry_pi() {
    log_info "Applying optimizations for Raspberry Pi..."
    
    # Increase memory available for containers
    if ! grep -q "vm.max_map_count" /etc/sysctl.conf; then
        echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
    fi
    
    # Optimize swap for Raspberry Pi
    if [[ -f /etc/dphys-swapfile ]]; then
        sudo dphys-swapfile swapoff || true
        sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile 2>/dev/null || true
        sudo dphys-swapfile setup || true
        sudo dphys-swapfile swapon || true
    fi
    
    log_success "Optimizations applied!"
}

# Configure hostname and mDNS
setup_hostname_mdns() {
    log_info "Configuring hostname and mDNS..."

    # Change hostname from 'raspberrypi' to 'pipassive'
    CURRENT_HOSTNAME=$(hostname)
    if [[ "$CURRENT_HOSTNAME" != "pipassive" ]]; then
        log_info "Changing hostname from '$CURRENT_HOSTNAME' to 'pipassive'..."
        sudo hostnamectl set-hostname pipassive
        log_success "Hostname set to 'pipassive'"
    else
        log_success "Hostname already set to 'pipassive'"
    fi

    # Enable and restart Avahi to register the new hostname
    sudo systemctl enable avahi-daemon 2>/dev/null || true
    sudo systemctl restart avahi-daemon
    sleep 2

    log_success "mDNS configured for 'pipassive.local'"
}

# Test Docker installation
test_docker() {
    log_info "Testing Docker installation..."
    
    # Check if we can run docker without sudo
    if docker ps &> /dev/null; then
        log_success "Docker works correctly!"
        docker run --rm hello-world > /dev/null 2>&1
        log_success "Test container completed!"
    else
        log_warning "You cannot run docker without sudo"
        log_info "Run: newgrp docker"
        log_info "Or logout/login to apply permissions"
    fi
}

# Make scripts executable
make_scripts_executable() {
    log_info "Setting script permissions..."
    
    chmod +x setup.sh 2>/dev/null || true
    chmod +x manage.sh 2>/dev/null || true
    chmod +x dashboard.sh 2>/dev/null || true
    chmod +x backup.sh 2>/dev/null || true
    chmod +x restore.sh 2>/dev/null || true
    
    log_success "Permissions set!"
}

# Final summary
print_summary() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Installation Completed Successfully!            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}▶ NEXT STEPS:${NC}"
    echo
    echo -e "  ${YELLOW}Choose how to configure services:${NC}"
    echo
    echo -e "  ${GREEN}OPTION 1 - Via Web (Recommended):${NC}"
    echo -e "    1. Open browser: ${GREEN}http://pipassive.local/setup${NC}"
    echo -e "    2. Fill the form and save"
    echo
    echo -e "  ${GREEN}OPTION 2 - Via Terminal (CLI):${NC}"
    echo -e "    1. ${GREEN}./setup.sh${NC}"
    echo -e "    2. Answer the interactive questions"
    echo
    echo -e "  ${YELLOW}Service management:${NC}"
    echo -e "    • Web Dashboard always active: ${GREEN}http://pipassive.local${NC}"
    echo -e "    • Start Docker containers: ${GREEN}./manage.sh start${NC}"
    echo -e "    • Quick Links: ${GREEN}http://pipassive.local/links${NC}"
    echo
    echo -e "${YELLOW}⚠️  IMPORTANT - MystNode:${NC}"
    echo -e "    Complete configuration at: ${GREEN}http://pipassive.local:4449${NC}"
    echo
    echo -e "${BLUE}Documentation:${NC}"
    echo -e "  • README.md - Read for details"
    echo -e "  • PROJECT_STRUCTURE.md - File structure"
    echo
    echo -e "${YELLOW}Security:${NC}"
    echo -e "  • .env contains credentials (never share)"
    echo -e "  • Monitoring: ${GREEN}./manage.sh status${NC}"
    echo
}

# Main
main() {
    print_logo
    
    log_info "Starting PiPassive installation..."
    echo
    
    check_root
    check_system
    
    echo
    read -p "Proceed with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi
    
    echo
    log_info "=== PHASE 1: System Update ==="
    update_system
    
    echo
    log_info "=== PHASE 2: Dependencies Installation ==="
    install_dependencies
    
    echo
    log_info "=== PHASE 3: Docker Installation ==="
    install_docker
    
    echo
    log_info "=== PHASE 4: Docker Compose Installation ==="
    install_docker_compose
    
    echo
    log_info "=== PHASE 5: Directory Creation ==="
    create_directories
    
    echo
    log_info "=== PHASE 6: Configuration Setup ==="
    setup_config_files
    
    echo
    log_info "=== PHASE 7: System Optimizations ==="
    optimize_raspberry_pi
    
    echo
    log_info "=== PHASE 8: Hostname and mDNS Configuration ==="
    setup_hostname_mdns

    echo
    log_info "=== PHASE 9: Permissions Setup ==="
    make_scripts_executable
    
    echo
    log_info "=== PHASE 10: Web Service Configuration ==="
    setup_web_service

    echo
    log_info "=== PHASE 11: Installation Test ==="
    test_docker
    
    echo
    print_summary
}

# Execute main
main "$@"
