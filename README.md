# 🍓 PiPassive - Raspberry Pi Passive Income Automator

Sistema automatizzato per installare e gestire multiple applicazioni di passive income sul tuo Raspberry Pi con un solo click!

## 📋 Servizi Supportati

Questo progetto gestisce automaticamente i seguenti servizi:

1. **Honeygain** - Condividi la tua connessione internet
2. **EarnApp** - Guadagna condividendo banda internet
3. **Pawns.app** - Monetizza la tua connessione
4. **PacketStream** - Condivisione di banda per ricerche di mercato
5. **TraffMonetizer** - Condivisione traffico internet
6. **Repocket** - Network sharing platform
7. **EarnFM** - Guadagna dalla tua banda inutilizzata
8. **MystNode** - Nodo decentralizzato VPN
9. **PacketShare** - Condivisione pacchetti per passive income

## 🚀 Installazione Rapida (One-Click)

### Prerequisiti
- Raspberry Pi (3, 4 o 5) con Raspberry Pi OS
- Connessione internet
- Accesso SSH o terminale locale

### Installazione Automatica

```bash
# Clona il repository
git clone https://github.com/tuousername/PiPassive.git
cd PiPassive

# Rendi eseguibile lo script di installazione
chmod +x install.sh

# Esegui l'installazione automatica
./install.sh
```

Lo script installerà automaticamente:
- Docker e Docker Compose
- Tutte le dipendenze necessarie
- Configurerà tutti i servizi di passive income

## ⚙️ Configurazione

### 1. Configurazione API Keys

Dopo l'installazione, configura le tue API keys e credenziali:

```bash
./setup.sh
```

Lo script ti guiderà passo-passo nella configurazione di ogni servizio.

### 2. Configurazione Manuale (Opzionale)

Puoi anche configurare manualmente copiando il file template:

```bash
cp .env.example .env
nano .env
```

Inserisci le tue credenziali per ogni servizio nel file `.env`.

## 🎮 Gestione Servizi

### Comandi Principali

```bash
# Avvia tutti i servizi
./manage.sh start

# Ferma tutti i servizi
./manage.sh stop

# Riavvia tutti i servizi
./manage.sh restart

# Visualizza stato dei servizi
./manage.sh status

# Visualizza logs di un servizio specifico
./manage.sh logs honeygain

# Aggiorna tutti i container
./manage.sh update
```

### Dashboard di Monitoraggio

Visualizza lo stato in tempo reale di tutti i servizi:

```bash
./dashboard.sh
```

## 📊 Monitoraggio

Il sistema include:
- Dashboard testuale in tempo reale
- Logs centralizzati per ogni servizio
- Status check automatici
- Alert per servizi non funzionanti

## 🔧 Struttura del Progetto

```
PiPassive/
├── README.md                 # Questo file
├── install.sh               # Script di installazione principale
├── setup.sh                 # Script di configurazione interattiva
├── manage.sh                # Script di gestione servizi
├── dashboard.sh             # Dashboard di monitoraggio
├── docker-compose.yml       # Configurazione Docker Compose
├── .env.example             # Template variabili d'ambiente
├── backup.sh                # Script di backup
├── restore.sh               # Script di ripristino
├── docs/                    # Documentazione dettagliata
│   ├── services.md          # Guida per ottenere API keys
│   ├── troubleshooting.md   # Risoluzione problemi
│   └── advanced.md          # Configurazioni avanzate
└── configs/                 # Configurazioni servizi
    └── [servizio]/          # Config per ogni servizio
```

## 📱 Ottenere le API Keys

Ogni servizio richiede una registrazione. Segui la [guida dettagliata](docs/services.md) per ottenere:

1. **Honeygain**: https://r.honeygain.me/YOURCODE
2. **EarnApp**: https://earnapp.com/i/YOURCODE
3. **Pawns**: https://pawns.app/
4. **PacketStream**: https://packetstream.io/
5. **TraffMonetizer**: https://traffmonetizer.com/
6. **Repocket**: https://repocket.co/
7. **EarnFM**: https://earn.fm/
8. **MystNode**: https://mystnodes.com/
9. **PacketShare**: https://packetshare.io/

## 🔒 Sicurezza

- Non committare mai il file `.env` con le tue credenziali
- Usa password forti per ogni servizio
- Mantieni aggiornato il sistema operativo
- Monitora regolarmente i servizi

## 🔄 Backup e Ripristino

### Backup

```bash
./backup.sh
```

Crea un backup di tutte le configurazioni in `backups/backup_YYYYMMDD_HHMMSS.tar.gz`

### Ripristino

```bash
./restore.sh backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

## 🐛 Troubleshooting

### Servizio non si avvia
```bash
# Controlla i logs del servizio
./manage.sh logs nome-servizio

# Riavvia il servizio specifico
docker-compose restart nome-servizio
```

### Problemi di rete
```bash
# Verifica la connettività
ping 8.8.8.8

# Riavvia il networking
sudo systemctl restart networking
```

Per altri problemi, consulta la [guida troubleshooting](docs/troubleshooting.md).

## 📈 Performance e Guadagni

I guadagni variano in base a:
- Qualità della connessione internet
- Posizione geografica
- Numero di servizi attivi
- Tempo di uptime

**Media stimata**: $20-50 al mese (dipende molto dai fattori sopra)

## 🤝 Contribuire

Contributi sono benvenuti! Per favore:
1. Fai fork del progetto
2. Crea un branch per la tua feature
3. Commit le tue modifiche
4. Push al branch
5. Apri una Pull Request

## 📝 License

MIT License - vedi [LICENSE](LICENSE) per dettagli

## ⚠️ Disclaimer

- Usa questi servizi a tuo rischio
- Verifica le leggi locali sulla condivisione di banda internet
- Leggi attentamente i ToS di ogni servizio
- Non garantiamo guadagni specifici
- Monitora il consumo di banda del tuo ISP

## 📞 Supporto

- Issues: [GitHub Issues](https://github.com/tuousername/PiPassive/issues)
- Discussioni: [GitHub Discussions](https://github.com/tuousername/PiPassive/discussions)

## 🙏 Crediti

Creato con ❤️ per la community Raspberry Pi

---

**Note**: Questo progetto è fornito "as-is". Assicurati di comprendere cosa fa ogni servizio prima di utilizzarlo.
