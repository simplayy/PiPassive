# Makefile per PiPassive
# Semplifica i comandi comuni

.PHONY: help install setup start stop restart status logs dashboard backup restore update clean

# Colori per output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m

help: ## Mostra questo messaggio di aiuto
	@echo "$(BLUE)PiPassive - Comandi Disponibili$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

install: ## Installa Docker e dipendenze
	@echo "$(BLUE)Installazione PiPassive...$(NC)"
	@./install.sh

setup: ## Configura i servizi (interattivo)
	@echo "$(BLUE)Setup configurazione...$(NC)"
	@./setup.sh

start: ## Avvia tutti i servizi
	@echo "$(GREEN)Avvio servizi...$(NC)"
	@./manage.sh start

stop: ## Ferma tutti i servizi
	@echo "$(YELLOW)Arresto servizi...$(NC)"
	@./manage.sh stop

restart: ## Riavvia tutti i servizi
	@echo "$(YELLOW)Riavvio servizi...$(NC)"
	@./manage.sh restart

status: ## Mostra status servizi
	@./manage.sh status

logs: ## Mostra logs (usa: make logs SERVICE=honeygain)
	@./manage.sh logs $(SERVICE)

dashboard: ## Apri dashboard di monitoraggio
	@./dashboard.sh

backup: ## Crea backup configurazione
	@echo "$(BLUE)Creazione backup...$(NC)"
	@./backup.sh

restore: ## Ripristina backup (usa: make restore BACKUP=file.tar.gz)
	@./restore.sh $(BACKUP)

update: ## Aggiorna tutti i container
	@echo "$(BLUE)Aggiornamento container...$(NC)"
	@./manage.sh update

stats: ## Mostra statistiche risorse
	@./manage.sh stats

clean: ## Rimuovi container e volumi (WARNING: rimuove dati!)
	@echo "$(RED)ATTENZIONE: Questa operazione rimuoverà tutti i dati!$(NC)"
	@read -p "Sei sicuro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		./manage.sh clean; \
	fi

test: ## Test ambiente (verifica installazione)
	@echo "$(BLUE)Test ambiente...$(NC)"
	@echo -n "Docker: "
	@command -v docker >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@echo -n "Docker Compose: "
	@docker compose version >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@echo -n "File .env: "
	@test -f .env && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (esegui 'make setup')$(NC)"
	@echo -n "Docker running: "
	@docker ps >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"

# Comandi per servizi specifici
start-%: ## Avvia servizio specifico (es: make start-honeygain)
	@./manage.sh start $*

stop-%: ## Ferma servizio specifico (es: make stop-honeygain)
	@./manage.sh stop $*

restart-%: ## Riavvia servizio specifico (es: make restart-honeygain)
	@./manage.sh restart $*

logs-%: ## Mostra logs servizio specifico (es: make logs-honeygain)
	@./manage.sh logs $*

# Quick aliases
up: start ## Alias per start
down: stop ## Alias per stop
ps: status ## Alias per status
