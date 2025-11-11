#!/bin/bash

################################################################################
# PiPassive - Configurazione Sudoers per Installazione Automatica
# Permette l'esecuzione di script di installazione senza password
# ESEGUIRE UNA SOLA VOLTA
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}"
cat << "EOF"
    ╔════════════════════════════════════════════════════════╗
    ║     PiPassive - Configurazione Sudoers                 ║
    ║  Permette installazione automatica senza password      ║
    ╚════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}⚠️  ATTENZIONE:${NC}"
echo "Questo script configurerà sudo per permettere al tuo utente"
echo "di eseguire script di installazione senza digitare la password."
echo
echo "Questo è sicuro SOLO se il tuo Raspberry Pi è fisicamente protetto!"
echo

# Verifica che sia eseguito con sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[✗]${NC} Questo script deve essere eseguito con sudo!"
    echo "Esegui: sudo ./setup-sudo.sh"
    exit 1
fi

# Ottieni il nome utente
CURRENT_USER=$(logname || echo $SUDO_USER || whoami)

echo -e "${BLUE}[INFO]${NC} Utente: $CURRENT_USER"
echo

# Crea il file sudoers
echo -e "${BLUE}[INFO]${NC} Configurazione sudoers..."

# Backup di sudoers
cp /etc/sudoers /etc/sudoers.backup.$(date +%s)
echo -e "${GREEN}[✓]${NC} Backup sudoers creato"

# Aggiungi le nuove linee a sudoers.d (metodo più sicuro)
cat > /etc/sudoers.d/pipassive << EOF
# PiPassive - Permessi per installazione servizi di sistema
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/bash
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/sh
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/wget
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/curl
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/sbin/systemctl
EOF

chmod 0440 /etc/sudoers.d/pipassive
echo -e "${GREEN}[✓]${NC} File /etc/sudoers.d/pipassive creato"

# Verifica la sintassi
if visudo -c -f /etc/sudoers.d/pipassive >/dev/null 2>&1; then
    echo -e "${GREEN}[✓]${NC} Sintassi sudoers corretta"
else
    echo -e "${RED}[✗]${NC} Errore nella sintassi sudoers!"
    rm /etc/sudoers.d/pipassive
    exit 1
fi

echo
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Configurazione Completata!                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo

echo -e "${BLUE}Adesso puoi:${NC}"
echo "  1. Eseguire ./setup.sh per configurare i servizi"
echo "  2. Rispondere 's' durante il setup per installare EarnApp/TraffMonetizer"
echo "  3. L'installazione avverrà SENZA richiedere password"
echo

echo -e "${YELLOW}[⚠]  Permessi configurati:${NC}"
echo "  • bash - esecuzione script"
echo "  • wget - download file"
echo "  • curl - download file"
echo "  • systemctl - gestione servizi"
echo

echo -e "${CYAN}Verifica della configurazione:${NC}"
sudo -l -U $CURRENT_USER
echo

echo -e "${YELLOW}[!]${NC} Se qualcosa non funziona, ripristina con:"
echo "    sudo cp /etc/sudoers.backup.* /etc/sudoers"
echo "    sudo rm /etc/sudoers.d/pipassive"





