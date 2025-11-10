# ⚙️ Configurazioni Avanzate

Questa guida copre configurazioni avanzate e ottimizzazioni per utenti esperti.

---

## 📋 Indice

- [Configurazione Docker Avanzata](#configurazione-docker-avanzata)
- [Network Configuration](#network-configuration)
- [Ottimizzazioni Performance](#ottimizzazioni-performance)
- [Security Hardening](#security-hardening)
- [Monitoring Avanzato](#monitoring-avanzato)
- [Automazione](#automazione)

---

## 🐳 Configurazione Docker Avanzata

### Custom Docker Compose Override

Crea un file `docker-compose.override.yml` per personalizzazioni locali:

```yaml
version: '3.8'

services:
  honeygain:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          memory: 128M
    restart: always
    
  # Aggiungi configurazioni custom per altri servizi
```

Il file override viene automaticamente applicato senza modificare il docker-compose.yml principale.

### Limiti di Risorse Personalizzati

Per limitare CPU e memoria di tutti i servizi:

```yaml
# Aggiungi a ogni servizio nel docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '0.50'      # Massimo 50% di 1 CPU
      memory: 512M       # Massimo 512MB RAM
    reservations:
      cpus: '0.25'      # Minimo garantito
      memory: 256M       # Minimo garantito
```

### Health Checks Personalizzati

Esempio health check avanzato:

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Logging Drivers Alternativi

Invece di json-file, puoi usare altri driver:

```yaml
logging:
  driver: "syslog"
  options:
    syslog-address: "tcp://192.168.1.100:514"
    tag: "{{.Name}}"
```

O disabilita completamente i logs:

```yaml
logging:
  driver: "none"
```

---

## 🌐 Network Configuration

### Custom Network Settings

Modifica la subnet della network:

```yaml
networks:
  pipassive:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.30.0.0/16
          gateway: 172.30.0.1
```

### IP Statici per Container

Assegna IP fissi ai container:

```yaml
services:
  honeygain:
    networks:
      pipassive:
        ipv4_address: 172.28.0.10
        
  earnapp:
    networks:
      pipassive:
        ipv4_address: 172.28.0.11
```

### Port Forwarding per MystNode

Per massimizzare i guadagni di MystNode, configura port forwarding sul router:

**Porte da aprire:**
- TCP/UDP: 4449 (Dashboard)
- TCP/UDP: 59850-59990 (Mysterium traffic)

**Procedura generale:**
1. Trova l'IP del Raspberry: `hostname -I`
2. Accedi al router (di solito 192.168.1.1 o 192.168.0.1)
3. Cerca "Port Forwarding" o "Virtual Server"
4. Aggiungi le regole:
   - External Port: 59850-59990
   - Internal IP: [IP-Raspberry]
   - Internal Port: 59850-59990
   - Protocol: Both (TCP/UDP)

### DNS Personalizzati

Aggiungi DNS custom a tutti i servizi:

```yaml
services:
  honeygain:
    dns:
      - 8.8.8.8          # Google DNS
      - 8.8.4.4
      - 1.1.1.1          # Cloudflare DNS
```

### Host Network Mode (Sconsigliato)

Solo per troubleshooting avanzato:

```yaml
services:
  mystnode:
    network_mode: "host"
```

⚠️ **Attenzione:** Rimuove l'isolamento di rete del container.

---

## ⚡ Ottimizzazioni Performance

### Raspberry Pi Overclocking

**⚠️ Attenzione:** Aumenta temperatura e consumo. Richiede raffreddamento adeguato.

```bash
# Backup config
sudo cp /boot/config.txt /boot/config.txt.backup

# Modifica config
sudo nano /boot/config.txt
```

**Raspberry Pi 4:**
```
# Aggiungi queste righe
over_voltage=6
arm_freq=2000
gpu_freq=750
```

**Raspberry Pi 3:**
```
arm_freq=1400
gpu_freq=500
over_voltage=4
```

Riavvia: `sudo reboot`

### Ottimizzazione Memoria

```bash
# Aumenta swap permanentemente
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Modifica:
CONF_SWAPSIZE=4096

sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

### Ottimizzazione I/O

```bash
# Riduci swappiness
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Ottimizza dirty_ratio
echo "vm.dirty_ratio=15" | sudo tee -a /etc/sysctl.conf
echo "vm.dirty_background_ratio=5" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### CPU Governor

```bash
# Imposta performance mode
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Per rendere permanente
sudo apt-get install cpufrequtils
sudo nano /etc/default/cpufrequtils
# Aggiungi:
GOVERNOR="performance"
```

### Docker Storage Driver

Ottimizza per SD card:

```bash
sudo nano /etc/docker/daemon.json
```

```json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

Riavvia Docker: `sudo systemctl restart docker`

---

## 🔒 Security Hardening

### Firewall Configuration

```bash
# Installa UFW
sudo apt-get install ufw

# Regole base
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH
sudo ufw allow 22/tcp

# MystNode dashboard (solo da rete locale)
sudo ufw allow from 192.168.1.0/24 to any port 4449

# Abilita
sudo ufw enable
```

### Docker Socket Protection

Non esporre mai il Docker socket! Se necessario:

```bash
# Crea gruppo specifico
sudo groupadd docker-safe
sudo usermod -aG docker-safe $USER

# Limita permessi
sudo chmod 660 /var/run/docker.sock
sudo chown root:docker-safe /var/run/docker.sock
```

### Environment Variables Security

Encrypta il file .env:

```bash
# Installa GPG
sudo apt-get install gnupg

# Encrypta
gpg -c .env
# Crea .env.gpg

# Decripta quando serve
gpg .env.gpg
```

### Fail2Ban per SSH

```bash
# Installa
sudo apt-get install fail2ban

# Configura
sudo nano /etc/fail2ban/jail.local
```

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Automatic Security Updates

```bash
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

---

## 📊 Monitoring Avanzato

### Prometheus + Grafana

Aggiungi al docker-compose.yml:

```yaml
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./configs/prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    ports:
      - "9090:9090"
    networks:
      - pipassive
      
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - pipassive

volumes:
  prometheus_data:
  grafana_data:
```

### Node Exporter

```yaml
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    ports:
      - "9100:9100"
    networks:
      - pipassive
```

### Custom Health Check Script

Crea `health-check.sh`:

```bash
#!/bin/bash

SERVICES=("honeygain" "earnapp" "pawns" "packetstream" "traffmonetizer" "repocket" "earnfm" "mystnode" "packetshare")
WEBHOOK_URL="https://hooks.slack.com/YOUR/WEBHOOK/URL"

for service in "${SERVICES[@]}"; do
    status=$(docker inspect -f '{{.State.Status}}' "$service" 2>/dev/null)
    
    if [[ "$status" != "running" ]]; then
        message="⚠️ Alert: Service $service is $status"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$WEBHOOK_URL"
    fi
done
```

### Cron Job per Monitoring

```bash
# Aggiungi a crontab
crontab -e

# Controlla ogni 5 minuti
*/5 * * * * /path/to/health-check.sh

# Backup giornaliero
0 3 * * * /path/to/backup.sh

# Restart settimanale
0 4 * * 0 cd /path/to/PiPassive && ./manage.sh restart
```

---

## 🤖 Automazione

### Systemd Service

Crea `/etc/systemd/system/pipassive.service`:

```ini
[Unit]
Description=PiPassive Passive Income Services
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/pi/PiPassive
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Abilita:
```bash
sudo systemctl enable pipassive.service
sudo systemctl start pipassive.service
```

### Auto-start al Boot

```bash
# Crea script di avvio
sudo nano /etc/rc.local
```

```bash
#!/bin/sh -e
cd /home/pi/PiPassive
/usr/bin/docker compose up -d
exit 0
```

```bash
sudo chmod +x /etc/rc.local
```

### Auto-update con Watchtower

Già incluso nel docker-compose.yml! Per abilitare:

```bash
# Avvia con profilo autoupdate
docker compose --profile autoupdate up -d
```

O modifica docker-compose.yml rimuovendo `profiles:` da watchtower.

### Notifications via Telegram

Crea `telegram-notify.sh`:

```bash
#!/bin/bash

BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
MESSAGE="$1"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="${CHAT_ID}" \
    -d text="${MESSAGE}"
```

Usa negli script:
```bash
./telegram-notify.sh "✅ PiPassive: Tutti i servizi avviati"
```

### Backup Automatico su Cloud

```bash
# Installa rclone
curl https://rclone.org/install.sh | sudo bash

# Configura cloud storage
rclone config

# Modifica backup.sh per includere upload
# Alla fine di backup.sh:
rclone copy backups/ mycloud:pipassive-backups/ --include "*.tar.gz"
```

---

## 🔄 Multiple Instances

### Più Raspberry Pi

Se hai più Raspberry Pi, usa nomi dispositivi univoci:

```bash
# Nel .env di ogni dispositivo
HONEYGAIN_DEVICE_NAME=PiPassive-Living-Room
PAWNS_DEVICE_NAME=PiPassive-Bedroom
# etc...
```

### Docker Stack Mode (Swarm)

Per deployment avanzato:

```bash
# Inizializza swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml pipassive

# Scala servizi
docker service scale pipassive_honeygain=2
```

---

## 📝 Custom Scripts

### Revenue Tracker

Crea `revenue-tracker.sh`:

```bash
#!/bin/bash

# Esempio di tracking guadagni
# Implementa API calls ai servizi per ottenere balance

echo "=== PiPassive Revenue Report ==="
echo "Date: $(date)"
echo
echo "Honeygain: [implementa API call]"
echo "EarnApp: [implementa API call]"
# etc...
```

### Alert System

```bash
#!/bin/bash

THRESHOLD_CPU=80
THRESHOLD_MEM=90

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
mem_usage=$(free | grep Mem | awk '{print ($3/$2) * 100}' | cut -d'.' -f1)

if (( $(echo "$cpu_usage > $THRESHOLD_CPU" | bc -l) )); then
    ./telegram-notify.sh "⚠️ CPU usage high: ${cpu_usage}%"
fi

if (( $mem_usage > $THRESHOLD_MEM )); then
    ./telegram-notify.sh "⚠️ Memory usage high: ${mem_usage}%"
fi
```

---

## 🎯 Best Practices

1. **Backup regolari:** Automatizza con cron
2. **Monitor logs:** Controlla giornalmente
3. **Update system:** Almeno mensile
4. **Test restore:** Verifica i backup funzionino
5. **Document changes:** Tieni traccia delle modifiche
6. **Network stability:** Usa cavo Ethernet se possibile
7. **Power supply:** UPS per evitare corruption
8. **Temperature:** Mantieni sotto 70°C
9. **SD card quality:** Usa classe A2 o superiore
10. **Separate data:** Considera USB storage per dati

---

## 🔬 Esperimenti Avanzati

### Multi-Architecture Build

Se vuoi buildare immagini custom:

```dockerfile
# Dockerfile.custom
FROM --platform=$BUILDPLATFORM alpine:latest
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building for $TARGETPLATFORM on $BUILDPLATFORM"
```

### Custom Network Plugin

```bash
docker plugin install weave/net-plugin:latest
```

### GPU Acceleration (Pi 4)

```yaml
services:
  myservice:
    devices:
      - /dev/vchiq:/dev/vchiq
    environment:
      - LD_LIBRARY_PATH=/opt/vc/lib
```

---

## ⚠️ Warning

Le configurazioni avanzate possono:
- Ridurre la stabilità del sistema
- Aumentare la complessità
- Richiedere manutenzione maggiore
- Invalidare la garanzia (overclocking)

Testa sempre in ambiente non-produzione prima!

---

**Ultimo aggiornamento:** Novembre 2025

Per domande avanzate, apri una discussion su GitHub!
