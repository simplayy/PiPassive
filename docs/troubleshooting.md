# 🔧 Troubleshooting - Risoluzione Problemi

Questa guida ti aiuterà a risolvere i problemi più comuni con PiPassive.

---

## 📋 Indice

- [Problemi di Installazione](#problemi-di-installazione)
- [Problemi Docker](#problemi-docker)
- [Problemi con i Servizi](#problemi-con-i-servizi)
- [Problemi di Rete](#problemi-di-rete)
- [Problemi di Performance](#problemi-di-performance)
- [Problemi con le Credenziali](#problemi-con-le-credenziali)

---

## 🚀 Problemi di Installazione

### Script install.sh non si avvia

**Sintomi:** Errore "Permission denied"

**Soluzione:**
```bash
chmod +x install.sh
./install.sh
```

### Docker non si installa

**Sintomi:** Errori durante l'installazione di Docker

**Soluzione:**
```bash
# Rimuovi installazioni precedenti
sudo apt-get remove docker docker-engine docker.io containerd runc

# Reinstalla manualmente
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Aggiungi utente al gruppo
sudo usermod -aG docker $USER

# Ricarica i gruppi
newgrp docker
```

### Sistema operativo non supportato

**Sintomi:** "Sistema operativo non supportato"

**Soluzione:**
- Assicurati di usare Raspberry Pi OS (Debian-based)
- Aggiorna il sistema: `sudo apt-get update && sudo apt-get upgrade`
- Verifica la versione: `cat /etc/os-release`

---

## 🐳 Problemi Docker

### "Cannot connect to Docker daemon"

**Sintomi:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Soluzioni:**

1. **Verifica che Docker sia in esecuzione:**
```bash
sudo systemctl status docker
sudo systemctl start docker
```

2. **Verifica i permessi:**
```bash
sudo usermod -aG docker $USER
newgrp docker
# Oppure fai logout e login
```

3. **Riavvia Docker:**
```bash
sudo systemctl restart docker
```

### "permission denied while trying to connect"

**Sintomi:** Non puoi eseguire comandi docker senza sudo

**Soluzione:**
```bash
# Aggiungi utente al gruppo docker
sudo usermod -aG docker $USER

# Applica i cambiamenti
newgrp docker

# Oppure
su - $USER

# Verifica
docker ps
```

### Docker Compose non trovato

**Sintomi:** `docker-compose: command not found`

**Soluzione:**
```bash
# Docker Compose v2 (incluso in Docker)
docker compose version

# Se non funziona, usa l'installazione nel progetto
./install.sh
```

### Container si riavviano continuamente

**Sintomi:** Container in stato "Restarting"

**Diagnosi:**
```bash
# Controlla i logs
./manage.sh logs <servizio>

# O direttamente
docker logs <container_name>
```

**Soluzioni comuni:**
- Credenziali errate nel .env
- Servizio bloccato (IP/account bannato)
- Problemi di rete
- Porta già in uso

---

## 🔌 Problemi con i Servizi

### Servizio non si avvia

**Diagnosi:**
```bash
# Controlla lo stato
./manage.sh status

# Controlla i logs dettagliati
./manage.sh logs <servizio>

# Controlla errori Docker
docker inspect <container_name>
```

**Soluzioni:**

1. **Verifica le credenziali:**
```bash
# Controlla il file .env
cat .env | grep <SERVIZIO>

# Riconfigura se necessario
./setup.sh
```

2. **Riavvia il servizio:**
```bash
./manage.sh restart <servizio>
```

3. **Rimuovi e ricrea:**
```bash
docker compose down
docker compose up -d
```

### Honeygain: "Invalid credentials"

**Cause:**
- Email o password errata
- Account non verificato
- Account sospeso

**Soluzione:**
```bash
# Verifica le credenziali sul sito
# Riconfigura
nano .env
# Modifica HONEYGAIN_EMAIL e HONEYGAIN_PASSWORD

# Riavvia
./manage.sh restart honeygain
```

### EarnApp: "Invalid UUID"

**Cause:**
- UUID formato sbagliato
- Spazi o caratteri extra

**Soluzione:**
```bash
# L'UUID deve essere nel formato: sdk-node-xxxxxxxxxxxxx
# Ottienilo da: https://earnapp.com/dashboard (o usa il referral: https://earnapp.com/i/KSj1BgEi)

nano .env
# Verifica EARNAPP_UUID (no spazi, no newline)

./manage.sh restart earnapp
```

### MystNode: Dashboard non accessibile

**Cause:**
- Porta 4449 bloccata
- Container non running

**Soluzione:**
```bash
# Verifica che il container sia attivo
docker ps | grep mystnode

# Verifica la porta
sudo netstat -tulpn | grep 4449

# Accedi via browser
# http://[IP-RASPBERRY]:4449

# Se non funziona, riavvia
./manage.sh restart mystnode
```

### Servizio bloccato/bannato

**Sintomi:**
- Login fallito ripetutamente
- "Account suspended" nei logs
- Nessun guadagno per giorni

**Soluzioni:**
1. Controlla l'account sul sito ufficiale
2. Contatta il supporto del servizio
3. Verifica di non violare i Terms of Service
4. Considera di usare un altro dispositivo/IP

---

## 🌐 Problemi di Rete

### Container non hanno connessione internet

**Diagnosi:**
```bash
# Test connettività dal container
docker exec honeygain ping -c 4 8.8.8.8
```

**Soluzioni:**

1. **Riavvia Docker networking:**
```bash
sudo systemctl restart docker
```

2. **Riavvia i container:**
```bash
./manage.sh restart
```

3. **Verifica DNS:**
```bash
# Aggiungi DNS al docker-compose.yml
# Sotto ogni servizio:
dns:
  - 8.8.8.8
  - 8.8.4.4
```

### Porte già in uso

**Sintomi:** `port is already allocated`

**Diagnosi:**
```bash
# Trova chi usa la porta
sudo netstat -tulpn | grep <PORTA>
```

**Soluzione:**
```bash
# Ferma il servizio che usa la porta
# O cambia porta nel docker-compose.yml

# Per MystNode (porta 4449)
# Modifica in docker-compose.yml:
ports:
  - "4450:4449"  # Usa 4450 esternamente
```

### Nessun traffico/guadagno

**Cause comuni:**
- Location geografica
- ISP blocca traffic sharing
- IP non residenziale
- Servizio nuovo (serve tempo)

**Verifica:**
```bash
# Controlla che i servizi siano attivi
./manage.sh status

# Controlla i logs per errori
./manage.sh logs

# Verifica dashboard ufficiali dei servizi
# per vedere se il dispositivo è registrato
```

**Soluzioni:**
1. Aspetta 24-48 ore (servizi nuovi)
2. Verifica IP residenziale: https://whoer.net/
3. Controlla firewall/router
4. Considera port forwarding per MystNode

---

## ⚡ Problemi di Performance

### Raspberry Pi lento/si blocca

**Cause:**
- Troppi servizi attivi
- Memoria insufficiente
- SD card lenta
- Temperatura alta

**Diagnosi:**
```bash
# Controlla risorse
./manage.sh stats

# Temperatura
vcgencmd measure_temp

# Memoria
free -h

# CPU
top
```

**Soluzioni:**

1. **Disattiva servizi non necessari:**
```bash
# Ferma alcuni servizi
./manage.sh stop <servizio>
```

2. **Aumenta swap:**
```bash
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Cambia CONF_SWAPSIZE=2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

3. **Aggiungi raffreddamento:**
- Usa un case con ventola
- Aggiungi heatsink

4. **Usa SD card veloce:**
- Classe 10 o superiore
- A1/A2 rating

### Container usano troppa memoria

**Diagnosi:**
```bash
docker stats --no-stream
```

**Soluzione:**
```bash
# Limita memoria nel docker-compose.yml
# Sotto ogni servizio:
deploy:
  resources:
    limits:
      memory: 256M
    reservations:
      memory: 128M
```

### Logs occupano troppo spazio

**Diagnosi:**
```bash
# Controlla dimensione logs
sudo du -sh /var/lib/docker/containers/*/*-json.log
```

**Soluzione:**
```bash
# Pulisci logs manualmente
sudo sh -c 'truncate -s 0 /var/lib/docker/containers/*/*-json.log'

# I logs sono già limitati nel docker-compose.yml:
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

---

## 🔑 Problemi con le Credenziali

### File .env non trovato

**Sintomi:** `Error: .env file not found`

**Soluzione:**
```bash
# Crea da template
cp .env.example .env

# Oppure usa setup interattivo
./setup.sh
```

### Credenziali nel .env non funzionano

**Problemi comuni:**
- Spazi extra
- Newline alla fine
- Caratteri speciali non escaped
- Quote non necessarie

**Formato corretto:**
```bash
# ✅ CORRETTO
HONEYGAIN_EMAIL=email@example.com
HONEYGAIN_PASSWORD=MyPassword123

# ❌ SBAGLIATO
HONEYGAIN_EMAIL = email@example.com
HONEYGAIN_PASSWORD="MyPassword123"
HONEYGAIN_EMAIL=email@example.com 
```

**Verifica:**
```bash
# Controlla spazi/newline nascosti
cat -A .env | grep HONEYGAIN
```

### Password con caratteri speciali

**Problema:** Caratteri come `$`, `!`, `"` possono causare problemi

**Soluzione:**
```bash
# Se la password ha caratteri speciali, usa single quotes
# Ma nel .env NON usare quote, scrivi direttamente

# Se proprio necessario, escape i caratteri:
PASSWORD=My\$pecial\!Pass
```

---

## 🛠️ Comandi Utili per Debug

### Logs e Diagnostica

```bash
# Logs tempo reale
./manage.sh follow <servizio>

# Logs ultimi 100 righe
./manage.sh logs <servizio>

# Inspect container
docker inspect <container_name>

# Events Docker
docker events

# Disk usage
docker system df
```

### Pulizia Sistema

```bash
# Rimuovi container stopped
docker container prune -f

# Rimuovi immagini unused
docker image prune -f

# Rimuovi tutto
docker system prune -af

# Rimuovi volumi
docker volume prune -f
```

### Reset Completo

```bash
# Backup prima!
./backup.sh

# Ferma tutto
./manage.sh stop

# Rimuovi container e volumi
docker compose down -v

# Rimuovi dati
rm -rf data/

# Riconfigura
./setup.sh

# Riavvia
./manage.sh start
```

---

## 📞 Ottenere Aiuto

Se i problemi persistono:

1. **Controlla i logs:**
```bash
./manage.sh logs > debug.log
```

2. **Raccogli info sistema:**
```bash
uname -a > system_info.txt
docker version >> system_info.txt
docker compose version >> system_info.txt
```

3. **Apri una issue su GitHub:**
   - Includi i logs (rimuovi credenziali!)
   - Descrivi il problema
   - Specifica il modello di Raspberry Pi
   - Sistema operativo e versione

4. **Consulta le FAQ ufficiali:**
   - Ogni servizio ha documentazione ufficiale
   - Community forum e Discord

---

## ✅ Checklist Preventiva

Per evitare problemi:

- [ ] Sistema operativo aggiornato
- [ ] Docker e Docker Compose aggiornati
- [ ] Backup regolari (`./backup.sh`)
- [ ] Monitoraggio attivo (`./dashboard.sh`)
- [ ] Credenziali verificate
- [ ] Logs controllati regolarmente
- [ ] Temperatura sotto controllo
- [ ] SD card in buone condizioni
- [ ] Alimentatore adeguato (5V 3A min)
- [ ] Connessione internet stabile

---

**Ultimo aggiornamento:** Novembre 2025

Hai trovato un problema non listato? Apri una issue su GitHub!
