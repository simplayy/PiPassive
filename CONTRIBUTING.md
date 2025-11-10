# 🤝 Contributing to PiPassive

Grazie per l'interesse nel contribuire a PiPassive! Questo documento ti guiderà nel processo di contribuzione.

## 📋 Indice

- [Come Contribuire](#come-contribuire)
- [Segnalare Bug](#segnalare-bug)
- [Proporre Feature](#proporre-feature)
- [Pull Request](#pull-request)
- [Coding Guidelines](#coding-guidelines)
- [Testing](#testing)

---

## 🚀 Come Contribuire

Ci sono molti modi per contribuire a PiPassive:

1. **🐛 Segnalare bug** - Hai trovato un problema? Apri una issue!
2. **💡 Suggerire feature** - Hai un'idea? Condividila!
3. **📝 Migliorare documentazione** - Correzioni, traduzioni, esempi
4. **🔧 Scrivere codice** - Bug fix, nuove feature, ottimizzazioni
5. **🧪 Testing** - Testa su diversi hardware e configurazioni
6. **⭐ Supportare** - Metti una stella, condividi il progetto!

---

## 🐛 Segnalare Bug

### Prima di segnalare

1. **Cerca nelle issue esistenti** - Il problema potrebbe essere già noto
2. **Verifica la documentazione** - Consulta [troubleshooting.md](docs/troubleshooting.md)
3. **Testa con configurazione pulita** - Verifica che non sia un problema locale

### Come segnalare

Apri una **GitHub Issue** con:

**Template Bug Report:**

```markdown
## Descrizione del Bug
[Descrizione chiara e concisa del problema]

## Steps to Reproduce
1. 
2. 
3. 

## Comportamento Atteso
[Cosa ti aspettavi che succedesse]

## Comportamento Attuale
[Cosa succede invece]

## Logs
```
[Incolla i logs rilevanti - RIMUOVI le credenziali!]
```

## Environment
- Raspberry Pi Model: [es. Raspberry Pi 4 Model B 4GB]
- OS: [es. Raspberry Pi OS Bullseye 64-bit]
- Docker Version: [output di `docker --version`]
- Docker Compose Version: [output di `docker compose version`]

## File di Configurazione
[Condividi docker-compose.yml o .env.example se rilevante - MAI .env con credenziali!]

## Screenshot
[Se applicabile]

## Note Aggiuntive
[Altre informazioni utili]
```

---

## 💡 Proporre Feature

### Prima di proporre

1. **Verifica che non esista già** - Cerca nelle issue e discussions
2. **Valuta se è in-scope** - La feature ha senso per il progetto?
3. **Considera alternative** - Ci sono modi diversi per raggiungere lo stesso obiettivo?

### Come proporre

Apri una **GitHub Discussion** o **Issue** con:

**Template Feature Request:**

```markdown
## Feature Description
[Descrizione chiara della feature proposta]

## Problem it Solves
[Quale problema risolve? Perché è utile?]

## Proposed Solution
[Come pensi dovrebbe funzionare?]

## Alternatives Considered
[Hai considerato altre soluzioni?]

## Additional Context
[Screenshot, esempi, link, etc.]

## Implementation Ideas
[Se hai idee su come implementarla]
```

---

## 🔀 Pull Request

### Setup Ambiente

```bash
# Fork il repository su GitHub
# Poi clona il tuo fork
git clone https://github.com/TUO_USERNAME/PiPassive.git
cd PiPassive

# Aggiungi upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/PiPassive.git

# Crea un branch per la tua feature
git checkout -b feature/nome-feature
```

### Workflow

1. **Crea un branch** per la tua modifica
2. **Fai le tue modifiche** seguendo le guidelines
3. **Testa accuratamente** su Raspberry Pi se possibile
4. **Commit con messaggi chiari**
5. **Push al tuo fork**
6. **Apri una Pull Request**

### Commit Messages

Usa commit messages descrittivi:

```bash
# ✅ GOOD
git commit -m "Add health check for EarnApp container"
git commit -m "Fix: Correct password escaping in setup.sh"
git commit -m "Docs: Add troubleshooting for MystNode port forwarding"

# ❌ BAD
git commit -m "fix bug"
git commit -m "update"
git commit -m "changes"
```

### Format Commit Messages

```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

**Types:**
- `feat`: Nuova feature
- `fix`: Bug fix
- `docs`: Documentazione
- `style`: Formatting, manca semicolon, etc (no code change)
- `refactor`: Refactoring del codice
- `test`: Aggiunta o modifica test
- `chore`: Manutenzione, dipendenze, etc

### Pull Request Template

```markdown
## Description
[Descrizione chiara delle modifiche]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
[Come hai testato le modifiche?]

- [ ] Testato su Raspberry Pi 3
- [ ] Testato su Raspberry Pi 4
- [ ] Testato su Raspberry Pi 5
- [ ] Scripts eseguiti con successo
- [ ] Documentazione aggiornata

## Checklist
- [ ] Il mio codice segue lo stile del progetto
- [ ] Ho commentato il codice dove necessario
- [ ] Ho aggiornato la documentazione
- [ ] Le mie modifiche non generano nuovi warning
- [ ] Ho testato localmente le modifiche
- [ ] Ho aggiunto test se applicabile

## Screenshots
[Se applicabile]

## Related Issues
Fixes #123
Related to #456
```

---

## 📝 Coding Guidelines

### Bash Scripts

```bash
# Use strict mode
set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# Functions naming
function_name() {  # lowercase with underscore
    local var_name="value"  # use local for function variables
}

# Variables
CONSTANT_NAME="value"  # UPPERCASE for constants
variable_name="value"   # lowercase for variables

# Comments
# Single line comment for brief explanations

################################################################################
# Multi-line comment block for important sections
################################################################################

# Error handling
if [[ condition ]]; then
    # code
else
    log_error "Clear error message"
    exit 1
fi
```

### Docker Compose

```yaml
# Indentation: 2 spaces
# Order: image, container_name, restart, environment, volumes, ports, networks

services:
  service_name:
    image: image:tag
    container_name: service_name
    restart: unless-stopped
    environment:
      - VAR_NAME=value
    volumes:
      - ./path:/container/path
    ports:
      - "host:container"
    networks:
      - network_name
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Markdown Documentation

```markdown
# Use Clear Headers
## With Hierarchy
### As Needed

Use **bold** for emphasis and `code` for commands/files.

## Code Blocks with Language

```bash
# Always specify language
command --with-flags
```

## Lists

- Use bullet points
- For unordered lists
- Keep items concise

1. Numbered lists
2. For sequential steps
3. With clear actions
```

---

## 🧪 Testing

### Test Checklist

Prima di fare PR, testa:

- [ ] Scripts eseguono senza errori
- [ ] Permessi corretti (chmod +x per .sh)
- [ ] Variabili nel .env funzionano
- [ ] Container si avviano correttamente
- [ ] Logs non mostrano errori
- [ ] Dashboard mostra info corrette
- [ ] Backup e restore funzionano
- [ ] Documentazione è aggiornata

### Test su Hardware

Se possibile, testa su:
- Raspberry Pi 3 (architettura ARMv7)
- Raspberry Pi 4 (architettura ARM64)
- Raspberry Pi 5 (architettura ARM64)

### Test Manual Flow

```bash
# Clone fresh
git clone [your-fork]
cd PiPassive

# Test installation
./install.sh

# Test setup
./setup.sh

# Test management
./manage.sh start
./manage.sh status
./manage.sh logs
./manage.sh stop

# Test backup/restore
./backup.sh
./restore.sh backups/[latest]

# Test dashboard
./dashboard.sh
```

---

## 📚 Documentation

### Quando Aggiornare la Documentazione

Aggiorna la documentazione quando:
- Aggiungi nuova feature
- Cambi comportamento esistente
- Aggiungi nuove dipendenze
- Modifichi configurazione
- Aggiungi nuovi comandi

### File da Aggiornare

- `README.md` - Per feature principali
- `QUICKSTART.md` - Se cambi workflow base
- `docs/services.md` - Per nuovi servizi
- `docs/troubleshooting.md` - Per nuovi problemi comuni
- `docs/advanced.md` - Per configurazioni avanzate
- `CHANGELOG.md` - Per ogni modifica rilevante

---

## 🌍 Translations

Contributi per traduzioni sono benvenuti!

Crea una directory `docs/translations/[lang]/` e traduci:
- README.md
- QUICKSTART.md
- docs/services.md
- docs/troubleshooting.md

---

## ❓ Domande?

- **General Questions:** Apri una Discussion su GitHub
- **Bug Reports:** Apri una Issue
- **Feature Requests:** Apri una Discussion o Issue
- **Security Issues:** Vedi SECURITY.md (se disponibile)

---

## 📜 Code of Conduct

### Nostri Standard

- ✅ Essere rispettosi e inclusivi
- ✅ Accettare feedback costruttivo
- ✅ Focalizzarsi su cosa è meglio per la community
- ✅ Mostrare empatia verso altri membri

- ❌ Trolling, insulti o attacchi personali
- ❌ Harrassment pubblico o privato
- ❌ Pubblicare informazioni private altrui
- ❌ Condotta non professionale

### Enforcement

Comportamenti inaccettabili possono essere segnalati aprendo una issue.
I maintainer si riservano il diritto di rimuovere commenti e ban utenti.

---

## 🎉 Riconoscimenti

Tutti i contributors saranno menzionati nel README!

Per contributi significativi:
- Menzione nella release notes
- Badge "Contributor" sul profilo
- Eternal gratitude! 🙏

---

## 📄 License

Contribuendo a PiPassive, accetti che i tuoi contributi saranno rilasciati sotto la MIT License.

---

**Grazie per contribuire a PiPassive!** 🍓

Ogni contribuzione, grande o piccola, è apprezzata! 💚
