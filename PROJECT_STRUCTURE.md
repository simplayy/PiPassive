# 📁 PiPassive - Struttura Progetto

```
PiPassive/
│
├── 📄 README.md                      # Documentazione principale del progetto
├── 📄 QUICKSTART.md                  # Guida rapida per iniziare in 5 minuti
├── 📄 CHANGELOG.md                   # Storia delle versioni e modifiche
├── 📄 CONTRIBUTING.md                # Guida per contributors
├── 📄 LICENSE                        # Licenza MIT
├── 📄 Makefile                       # Comandi semplificati (make start, make stop, etc.)
│
├── 🐳 docker-compose.yml             # Configurazione Docker Compose con tutti i 9 servizi
├── 📋 .env.example                   # Template per variabili d'ambiente (credenziali)
├── 🚫 .gitignore                     # File da ignorare in Git (include .env)
│
├── 🔧 Scripts Principali
│   ├── install.sh                    # ⚙️  Installazione completa (Docker, dipendenze, setup)
│   ├── setup.sh                      # 📝 Configurazione interattiva (credenziali, API keys)
│   ├── manage.sh                     # 🎮 Gestione servizi (start, stop, restart, logs, etc.)
│   ├── dashboard.sh                  # 📊 Dashboard monitoraggio real-time
│   ├── backup.sh                     # 💾 Backup configurazioni
│   └── restore.sh                    # ♻️  Ripristino da backup
│
├── 📚 docs/                          # Documentazione dettagliata
│   ├── README.md                     # Indice documentazione
│   ├── services.md                   # Come ottenere API keys per ogni servizio
│   ├── troubleshooting.md            # Risoluzione problemi comuni
│   └── advanced.md                   # Configurazioni avanzate
│
├── 📁 configs/                       # Configurazioni servizi (creata da install.sh)
│   ├── honeygain/
│   ├── earnapp/
│   ├── pawns/
│   ├── packetstream/
│   ├── traffmonetizer/
│   ├── repocket/
│   ├── earnfm/
│   ├── mystnode/
│   └── packetshare/
│
├── 📁 data/                          # Dati persistenti servizi (creata da install.sh)
│   ├── honeygain/
│   ├── earnapp/
│   ├── pawns/
│   ├── packetstream/
│   ├── traffmonetizer/
│   ├── repocket/
│   ├── earnfm/
│   ├── mystnode/
│   └── packetshare/
│
├── 📁 logs/                          # Logs centralizzati (creata da install.sh)
│
└── 📁 backups/                       # Backup configurazioni (creata da backup.sh)
    └── pipassive_backup_YYYYMMDD_HHMMSS.tar.gz
```

## 📝 Descrizione File

### File Principali

| File | Scopo | Quando Usarlo |
|------|-------|---------------|
| `README.md` | Documentazione completa | Per capire il progetto |
| `QUICKSTART.md` | Guida rapida | Per iniziare velocemente |
| `install.sh` | Installazione sistema | Prima volta sul Raspberry Pi |
| `setup.sh` | Configurazione servizi | Per inserire credenziali |
| `manage.sh` | Gestione quotidiana | Per controllare i servizi |
| `dashboard.sh` | Monitoring | Per vedere status real-time |
| `backup.sh` | Backup | Regolarmente per sicurezza |
| `restore.sh` | Ripristino | In caso di problemi |

### Directory

| Directory | Contenuto | Gestione |
|-----------|-----------|----------|
| `docs/` | Documentazione | Git tracked |
| `configs/` | Configurazioni servizi | Backup required |
| `data/` | Dati runtime servizi | Backup optional |
| `logs/` | File di log | .gitignore |
| `backups/` | Backup compressi | .gitignore |

## 🔒 File Sensibili

**MAI committare in Git:**
- `.env` - Contiene credenziali e API keys
- `data/` - Dati runtime dei servizi
- `backups/` - Potrebbero contenere credenziali
- `logs/` - Potrebbero contenere info sensibili

**Già protetti da `.gitignore`** ✅

## 🚀 Workflow Tipico

### Prima Installazione
```
1. git clone / download
2. cd PiPassive
3. ./install.sh          # Installa Docker e dipendenze
4. ./setup.sh            # Configura credenziali
5. ./manage.sh start     # Avvia servizi
6. ./dashboard.sh        # Monitora
```

### Uso Quotidiano
```
./manage.sh status       # Check status
./dashboard.sh           # Monitoring
./manage.sh logs         # Se problemi
./backup.sh              # Backup regolare
```

### Manutenzione
```
./manage.sh update       # Aggiorna containers
./manage.sh restart      # Riavvio servizi
./backup.sh              # Backup prima modifiche
```

## 📊 Statistiche Progetto

- **Linee di codice**: ~5000
- **Script Bash**: 6
- **File documentazione**: 8
- **Servizi gestiti**: 9
- **Raspberry Pi supportati**: 3, 4, 5

## 🎯 Componenti Chiave

### Docker Compose Services

1. **Honeygain** - Port: none, Network: bridge
2. **EarnApp** - Port: none, Network: bridge
3. **Pawns** - Port: none, Network: bridge
4. **PacketStream** - Port: none, Network: bridge
5. **TraffMonetizer** - Port: none, Network: bridge
6. **Repocket** - Port: none, Network: bridge
7. **EarnFM** - Port: none, Network: bridge
8. **MystNode** - Port: 4449, Network: bridge
9. **PacketShare** - Port: none, Network: bridge
10. **Watchtower** (optional) - Auto-update containers

### Network Configuration

```yaml
networks:
  pipassive:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

### Volume Mounts

Ogni servizio monta:
- Configuration: `./configs/<service>/`
- Data: `./data/<service>/`
- Logs: gestiti da Docker logging driver

## 🔄 Data Flow

```
User
  ↓
manage.sh / dashboard.sh
  ↓
Docker Compose
  ↓
Docker Engine
  ↓
Containers (9 services)
  ↓
Internet (passive income!)
```

## 🛠️ Dependency Tree

```
PiPassive
├── Docker Engine (20.10+)
│   └── Docker Compose (v2+)
│       └── Container Images
│           ├── honeygain/honeygain:latest
│           ├── fazalfarhan01/earnapp:lite
│           ├── iproyal/pawns-cli:latest
│           ├── packetstream/psclient:latest
│           ├── traffmonetizer/cli:latest
│           ├── repocket/repocket:latest
│           ├── earnfm/earnfm-client:latest
│           ├── mysteriumnetwork/myst:latest
│           └── packetshare/packetshare:latest
│
└── System Dependencies
    ├── bash
    ├── curl
    ├── git
    ├── jq
    └── basic unix tools
```

## 📦 Installer Actions

`./install.sh` esegue:

1. ✅ Verifica sistema operativo
2. ✅ Aggiorna pacchetti sistema
3. ✅ Installa dipendenze (curl, git, jq, etc.)
4. ✅ Installa Docker Engine
5. ✅ Installa Docker Compose
6. ✅ Configura permessi utente
7. ✅ Crea directory necessarie
8. ✅ Ottimizza per Raspberry Pi
9. ✅ Copia template .env
10. ✅ Rende eseguibili gli script

## 🎨 Color Coding

Scripts usano colori per output:
- 🔵 **BLUE** - Info
- 🟢 **GREEN** - Success
- 🟡 **YELLOW** - Warning
- 🔴 **RED** - Error
- 🟣 **MAGENTA** - Headers
- 🔷 **CYAN** - Prompts

## 📏 Code Metrics

| Metric | Value |
|--------|-------|
| Total Files | ~20 |
| Shell Scripts | 6 |
| Markdown Docs | 8 |
| YAML Config | 1 |
| Total Lines | ~5000 |
| Documentation | ~60% |
| Code | ~40% |

## 🔐 Security Features

- ✅ Environment variables per credenziali
- ✅ .env excluded da Git
- ✅ Network isolation per containers
- ✅ No root requirement (dopo setup)
- ✅ Docker socket protection guidelines
- ✅ Backup encryption ready
- ✅ Logs sanitization

## 🎯 Next Steps

Vedi [CHANGELOG.md](CHANGELOG.md) per planned features!

---

**Versione**: 1.0.0
**Ultima modifica**: Novembre 2025
