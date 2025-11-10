# 🚀 Quick Start Guide

Guida rapida per iniziare con PiPassive in 5 minuti!

## 📦 Prerequisiti

- Raspberry Pi (3, 4 o 5) con Raspberry Pi OS
- Connessione internet
- Accesso SSH o terminale locale
- 30 minuti per la configurazione iniziale

## 🎯 Installazione in 3 Passi

### 1️⃣ Clona e Installa

```bash
# Clona il repository (o scarica e decomprimi)
git clone https://github.com/tuousername/PiPassive.git
cd PiPassive

# Installa tutto automaticamente
./install.sh
```

Lo script installerà:
- ✅ Docker
- ✅ Docker Compose
- ✅ Tutte le dipendenze
- ✅ Ottimizzazioni per Raspberry Pi

⏱️ Tempo stimato: 10-15 minuti

### 2️⃣ Configura i Servizi

```bash
# Setup guidato interattivo
./setup.sh
```

Ti verrà chiesto di inserire:
- Email e password per ogni servizio
- API keys e token
- Nomi dispositivi

💡 **Tip:** Tieni pronte le credenziali! Consulta [docs/services.md](docs/services.md) per sapere dove ottenerle.

⏱️ Tempo stimato: 10-15 minuti

### 3️⃣ Avvia i Servizi

```bash
# Avvia tutto!
./manage.sh start

# Verifica che tutto funzioni
./manage.sh status
```

✅ Fatto! I servizi sono ora attivi e stanno generando passive income!

## 📊 Monitoraggio

### Dashboard in Tempo Reale

```bash
./dashboard.sh
```

Mostra:
- 📈 Status di ogni servizio
- 💻 Utilizzo CPU e memoria
- 🌐 Traffico di rete
- 📝 Logs recenti

### Comandi Utili

```bash
# Status rapido
./manage.sh status

# Logs di un servizio specifico
./manage.sh logs honeygain

# Segui logs in tempo reale
./manage.sh follow earnapp

# Riavvia tutto
./manage.sh restart

# Riavvia singolo servizio
./manage.sh restart mystnode
```

## 🎛️ Gestione Servizi

### Avvia/Ferma Servizi

```bash
# Avvia tutti
./manage.sh start

# Ferma tutti
./manage.sh stop

# Avvia solo alcuni servizi
./manage.sh start honeygain
./manage.sh start earnapp

# Ferma un servizio
./manage.sh stop packetstream
```

### Aggiorna Servizi

```bash
# Aggiorna tutti i container alle ultime versioni
./manage.sh update
```

## 💾 Backup

### Crea Backup

```bash
./backup.sh
```

Crea un backup completo in `backups/pipassive_backup_YYYYMMDD_HHMMSS.tar.gz`

### Ripristina Backup

```bash
./restore.sh backups/pipassive_backup_20251110_120000.tar.gz
```

## 📱 Controlla i Guadagni

Accedi alle dashboard ufficiali di ogni servizio:

1. **Honeygain:** https://dashboard.honeygain.com/
2. **EarnApp:** https://earnapp.com/dashboard
3. **Pawns:** https://pawns.app/dashboard
4. **PacketStream:** https://packetstream.io/dashboard
5. **TraffMonetizer:** https://traffmonetizer.com/dashboard
6. **Repocket:** https://repocket.co/dashboard
7. **EarnFM:** https://earn.fm/dashboard
8. **MystNode:** http://[IP-RASPBERRY]:4449 (dashboard locale)
9. **PacketShare:** https://packetshare.io/dashboard

## 🔧 Troubleshooting Rapido

### Servizio non si avvia?

```bash
# Controlla i logs
./manage.sh logs <servizio>

# Riavvia il servizio
./manage.sh restart <servizio>
```

### Container si riavviano continuamente?

1. Controlla le credenziali in `.env`
2. Verifica che l'account non sia bloccato
3. Controlla i logs per errori specifici

### Nessun guadagno?

È normale! I servizi richiedono:
- ⏰ 24-48 ore per iniziare
- 📍 Posizione geografica favorevole (US, UK, AU pagano di più)
- 🌐 Connessione stabile
- ⏳ Tempo per costruire reputation

### Raspberry Pi lento?

```bash
# Disattiva servizi non necessari
./manage.sh stop <servizio>

# Controlla temperature
vcgencmd measure_temp

# Controlla risorse
./manage.sh stats
```

## 📚 Documentazione Completa

- **[README.md](README.md)** - Documentazione completa
- **[docs/services.md](docs/services.md)** - Come ottenere API keys
- **[docs/troubleshooting.md](docs/troubleshooting.md)** - Risoluzione problemi
- **[docs/advanced.md](docs/advanced.md)** - Configurazioni avanzate

## 💡 Tips per Massimizzare i Guadagni

1. **Mantieni alta l'uptime** - Più il sistema è online, più guadagni
2. **Usa Ethernet** - Più stabile del WiFi
3. **Connessione veloce** - Più bandwidth = più opportunità
4. **Più dispositivi** - Alcuni servizi permettono multiple istanze
5. **Location** - Posizione geografica influenza molto
6. **Port forwarding** - Per MystNode aumenta i guadagni

## ⚠️ Cose da Sapere

- 💰 Guadagni stimati: $20-50/mese (varia molto!)
- 📍 Location è fondamentale (US, UK, AU meglio)
- ⏱️ Richiede tempo per vedere risultati
- 🔒 Verifica ToS del tuo ISP
- 📊 Monitora consumo dati
- 🔐 Non condividere mai .env o API keys

## 🆘 Aiuto

### Problemi?

1. Consulta [docs/troubleshooting.md](docs/troubleshooting.md)
2. Controlla i logs: `./manage.sh logs`
3. Apri una issue su GitHub
4. Chiedi nella community

### Feature Request

Apri una discussion su GitHub con le tue idee!

## 🎉 Successo!

Se tutto funziona:
- ✅ Dashboard mostra tutti i servizi come "RUNNING"
- ✅ Logs non mostrano errori critici
- ✅ Dispositivi visibili nelle dashboard ufficiali

Ora rilassati e lascia che il Raspberry Pi lavori per te! 🍓💰

---

**Next Steps:**

1. Configura backup automatici (cron)
2. Imposta monitoring notifications
3. Esplora configurazioni avanzate
4. Condividi il progetto se ti piace! ⭐

**Buon passive income!** 🚀
