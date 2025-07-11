# Grafana Monitoring Stack Makefile
# A simple Makefile to manage the Docker Compose monitoring stack

.PHONY: help start stop restart logs status reset clean build pull health

# Default target
.DEFAULT_GOAL := help

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(GREEN)Grafana Monitoring Stack Management$(NC)"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-12s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

start: ## Start the monitoring stack
	@echo "$(GREEN)Starting Grafana monitoring stack...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Stack started successfully!$(NC)"
	@echo "Services available at:"
	@echo "  - Grafana: http://localhost:3000 (admin/admin)"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Loki: http://localhost:3100"

stop: ## Stop the monitoring stack
	@echo "$(YELLOW)Stopping Grafana monitoring stack...$(NC)"
	docker-compose down
	@echo "$(GREEN)Stack stopped successfully!$(NC)"

restart: ## Restart the monitoring stack
	@echo "$(YELLOW)Restarting Grafana monitoring stack...$(NC)"
	docker-compose restart
	@echo "$(GREEN)Stack restarted successfully!$(NC)"

logs: ## View logs from all services
	docker-compose logs -f

logs-grafana: ## View Grafana logs
	docker-compose logs -f grafana

logs-prometheus: ## View Prometheus logs
	docker-compose logs -f prometheus

logs-loki: ## View Loki logs
	docker-compose logs -f loki

logs-promtail: ## View Promtail logs
	docker-compose logs -f promtail

status: ## Show service status
	@echo "$(GREEN)Service Status:$(NC)"
	docker-compose ps

health: ## Check health of all services
	@echo "$(GREEN)Checking service health...$(NC)"
	@echo "Grafana:"
	@curl -s -o /dev/null -w "  Status: %{http_code}\n" http://localhost:3000/api/health || echo "  Status: Not responding"
	@echo "Prometheus:"
	@curl -s -o /dev/null -w "  Status: %{http_code}\n" http://localhost:9090/-/healthy || echo "  Status: Not responding"
	@echo "Loki:"
	@curl -s -o /dev/null -w "  Status: %{http_code}\n" http://localhost:3100/ready || echo "  Status: Not responding"

build: ## Build/rebuild the stack
	@echo "$(GREEN)Building monitoring stack...$(NC)"
	docker-compose build

pull: ## Pull latest images
	@echo "$(GREEN)Pulling latest images...$(NC)"
	docker-compose pull

reset: ## Reset stack and remove all data (WARNING: destructive)
	@echo "$(RED)WARNING: This will remove all data!$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "$(YELLOW)Resetting stack (removing all data)...$(NC)"
	docker-compose down -v
	docker-compose up -d
	@echo "$(GREEN)Stack reset successfully!$(NC)"

clean: ## Stop and remove containers, networks, and volumes
	@echo "$(YELLOW)Cleaning up monitoring stack...$(NC)"
	docker-compose down -v --remove-orphans
	@echo "$(GREEN)Cleanup completed!$(NC)"

init: ## Initialize the stack (first time setup)
	@echo "$(GREEN)Initializing Grafana monitoring stack...$(NC)"
	@echo "Creating necessary directories..."
	@mkdir -p grafana/provisioning/datasources
	@mkdir -p grafana/provisioning/dashboards
	@mkdir -p prometheus
	@mkdir -p loki
	@mkdir -p promtail
	@echo "$(GREEN)Initialization completed!$(NC)"
	@echo "Run 'make start' to start the stack"

dev: ## Start in development mode (with live reloading)
	@echo "$(GREEN)Starting in development mode...$(NC)"
	docker-compose up

check-config: ## Validate configuration files
	@echo "$(GREEN)Validating configuration files...$(NC)"
	@if [ -f prometheus/prometheus.yml ]; then \
		echo "✓ Prometheus config found"; \
	else \
		echo "✗ Prometheus config missing"; \
	fi
	@if [ -f loki/loki-config.yml ]; then \
		echo "✓ Loki config found"; \
	else \
		echo "✗ Loki config missing"; \
	fi
	@if [ -f promtail/promtail-config.yml ]; then \
		echo "✓ Promtail config found"; \
	else \
		echo "✗ Promtail config missing"; \
	fi
	@if [ -f grafana/provisioning/datasources/datasources.yml ]; then \
		echo "✓ Grafana datasources config found"; \
	else \
		echo "✗ Grafana datasources config missing"; \
	fi

update: ## Update all images to latest versions
	@echo "$(GREEN)Updating to latest images...$(NC)"
	docker-compose pull
	docker-compose up -d
	@echo "$(GREEN)Update completed!$(NC)"

backup: ## Backup Grafana dashboards and settings
	@echo "$(GREEN)Creating backup...$(NC)"
	@mkdir -p backups
	docker-compose exec -T grafana tar czf - /var/lib/grafana > backups/grafana-backup-$$(date +%Y%m%d-%H%M%S).tar.gz
	@echo "$(GREEN)Backup created in backups/ directory$(NC)"

restore: ## Restore Grafana from backup (specify BACKUP_FILE=filename)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "$(RED)Please specify BACKUP_FILE=filename$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restoring from $(BACKUP_FILE)...$(NC)"
	docker-compose exec -T grafana tar xzf - -C / < $(BACKUP_FILE)
	docker-compose restart grafana
	@echo "$(GREEN)Restore completed!$(NC)"
