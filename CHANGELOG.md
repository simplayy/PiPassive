# Changelog

Tutte le modifiche importanti a questo progetto saranno documentate in questo file.

Il formato è basato su [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e questo progetto aderisce al [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-10

### 🎉 Initial Release

Prima release pubblica di PiPassive - Sistema automatizzato per passive income su Raspberry Pi!

### ✨ Added

#### Core Features
- **One-Click Installation** - Script automatico per installare Docker e tutte le dipendenze
- **Interactive Setup** - Configurazione guidata per tutti i servizi
- **Service Management** - Script completo per gestire avvio, stop, restart dei servizi
- **Real-time Dashboard** - Monitoraggio in tempo reale con statistiche sistema e servizi
- **Backup & Restore** - Sistema completo per backup e ripristino configurazioni

#### Servizi Supportati (9 totali)
- Honeygain - Condivisione banda internet
- EarnApp - Monetizzazione bandwidth
- Pawns.app - Network sharing
- PacketStream - Proxy residenziale
- TraffMonetizer - Traffico sharing
- Repocket - Network platform
- EarnFM - Banda inutilizzata
- MystNode - VPN decentralizzato
- PacketShare - Packet sharing

#### Scripts
- `install.sh` - Installazione automatica completa
- `setup.sh` - Configurazione interattiva servizi
- `manage.sh` - Gestione servizi (start, stop, restart, logs, update)
- `dashboard.sh` - Dashboard monitoraggio real-time
- `backup.sh` - Backup configurazioni
- `restore.sh` - Ripristino backup

#### Docker Configuration
- Docker Compose configuration per tutti i servizi
- Network isolation per sicurezza
- Logging configuration ottimizzato
- Health checks per servizi supportati
- Resource limits configurabili
- Auto-restart policies

#### Documentation
- README.md completo con istruzioni dettagliate
- QUICKSTART.md per iniziare in 5 minuti
- docs/services.md - Guida per ottenere API keys
- docs/troubleshooting.md - Risoluzione problemi comuni
- docs/advanced.md - Configurazioni avanzate
- CONTRIBUTING.md - Guida per contributors
- LICENSE - MIT License

#### Optimizations
- Ottimizzazioni specifiche per Raspberry Pi
- Swap configuration automatica
- Memory management ottimizzato
- Logging con rotazione automatica
- Network performance tuning

#### Developer Experience
- Makefile per comandi semplificati
- .gitignore configurato
- .env.example template completo
- Colored output per migliore UX
- Error handling robusto

### 🔒 Security
- Environment variables per credenziali sensibili
- .env non tracciato in Git
- Backup automatico prima di restore
- Docker socket protection guidelines
- Security hardening documentation

### 📚 Documentation
- Documentazione completa in italiano
- Guide passo-passo per principianti
- Sezione troubleshooting estesa
- Best practices e tips
- Link a risorse ufficiali

### 🎯 Target Platform
- Raspberry Pi 3, 4, 5
- Raspberry Pi OS (Debian-based)
- Docker 20.10+
- Docker Compose v2

---

## [Unreleased]

### Planned Features

#### In Development
- [ ] Web-based dashboard (alternative alla CLI)
- [ ] API REST per controllo remoto
- [ ] Mobile app per monitoring
- [ ] Revenue tracking automatico
- [ ] Telegram bot per notifiche
- [ ] Email alerts per problemi
- [ ] Multi-device management
- [ ] Statistics & analytics
- [ ] Auto-scaling based on performance

#### Considerazioni Future
- [ ] Support per altri SBC (Orange Pi, Rock Pi, etc.)
- [ ] Support per architetture x86_64
- [ ] Docker Swarm mode per multiple Pi
- [ ] Kubernetes deployment option
- [ ] Cloud backup integration
- [ ] Configuration versioning
- [ ] A/B testing per configurazioni
- [ ] Machine learning per ottimizzazioni

#### Community Requests
- [ ] Support per più servizi passive income
- [ ] Integrazione con wallet crypto
- [ ] Dashboard personalizzabile
- [ ] Dark mode per dashboard
- [ ] Export report guadagni (PDF/CSV)
- [ ] Comparazione guadagni tra servizi
- [ ] Recommendations engine
- [ ] Community sharing di configurazioni

---

## Version History

### Version Numbering

Il progetto segue [Semantic Versioning](https://semver.org/):
- **MAJOR** version: Breaking changes
- **MINOR** version: Nuove feature (backward compatible)
- **PATCH** version: Bug fixes (backward compatible)

### Release Schedule

- **Major releases**: Quando necessario per breaking changes
- **Minor releases**: Mensilmente con nuove feature
- **Patch releases**: Settimanalmente per bug fixes

---

## Contributing

Vedi [CONTRIBUTING.md](CONTRIBUTING.md) per dettagli su come contribuire.

Ogni contributor sarà menzionato nelle release notes! 🎉

---

## Links

- **Repository**: https://github.com/tuousername/PiPassive
- **Issues**: https://github.com/tuousername/PiPassive/issues
- **Discussions**: https://github.com/tuousername/PiPassive/discussions
- **Wiki**: https://github.com/tuousername/PiPassive/wiki

---

**Note**: Le date usano il formato YYYY-MM-DD (ISO 8601)
