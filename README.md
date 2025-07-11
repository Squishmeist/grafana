# Grafana Monitoring Stack

This Docker Compose setup provides a complete monitoring and logging stack with:

- **Grafana** (Port 3000) - Visualization and dashboards
- **Prometheus** (Port 9090) - Metrics collection and storage
- **Loki** (Port 3100) - Log aggregation system
- **Promtail** - Log shipping agent

## Quick Start

1. Start the stack:

   ```bash
   make start
   ```

2. Access the services:

   - **Grafana**: http://localhost:3000 (admin/admin)
   - **Prometheus**: http://localhost:9090
   - **Loki**: http://localhost:3100

3. View available commands:
   ```bash
   make help
   ```

## Services Overview

### Grafana

- Default credentials: `admin/admin`
- Pre-configured with Prometheus and Loki data sources
- Access at: http://localhost:3000

### Prometheus

- Scrapes metrics from itself, Grafana, and Loki
- Web UI at: http://localhost:9090
- Configuration: `prometheus/prometheus.yml`

### Loki

- Log aggregation system
- API endpoint: http://localhost:3100
- Configuration: `loki/loki-config.yml`

### Promtail

- Ships logs from Docker containers and system logs to Loki
- Configuration: `promtail/promtail-config.yml`

## Directory Structure

```
.
├── docker-compose.yml
├── grafana/
│   └── provisioning/
│       ├── datasources/
│       │   └── datasources.yml
│       └── dashboards/
│           └── dashboards.yml
├── prometheus/
│   └── prometheus.yml
├── loki/
│   └── loki-config.yml
└── promtail/
    └── promtail-config.yml
```

## Managing the Stack

All stack management is done through the Makefile. Run `make help` to see all available commands.

### Common Commands

```bash
# Start the stack
make start

# Stop the stack
make stop

# Restart the stack
make restart

# View logs from all services
make logs

# View logs from specific service
make logs-grafana
make logs-prometheus
make logs-loki
make logs-promtail

# Check service status
make status

# Check service health
make health

# Reset stack (removes all data)
make reset

# Update to latest images
make update
```

## Adding Your Applications

### Metrics (Prometheus)

Add your application to `prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: "your-app"
    static_configs:
      - targets: ["your-app:port"]
```

### Logs (Promtail)

Modify `promtail/promtail-config.yml` to include your application logs:

```yaml
scrape_configs:
  - job_name: your-app-logs
    static_configs:
      - targets:
          - localhost
        labels:
          job: your-app
          __path__: /path/to/your/app/logs/*.log
```

## Data Persistence

The setup uses Docker volumes for data persistence:

- `grafana-storage` - Grafana dashboards and settings
- `prometheus-storage` - Prometheus metrics data
- `loki-storage` - Loki log data

## Security Notes

- Default Grafana credentials are `admin/admin` - change these in production
- Services are exposed on localhost - adjust ports and networking for production use
- Consider adding authentication and TLS for production deployments

## Advanced Features

### Backup and Restore

```bash
# Create a backup of Grafana dashboards
make backup

# Restore from a backup file
make restore BACKUP_FILE=backups/grafana-backup-20250711-120000.tar.gz
```

### Development Mode

```bash
# Start in development mode (foreground with logs)
make dev
```

### Configuration Validation

```bash
# Check if all required config files exist
make check-config
```

## Troubleshooting

### Check service status

```bash
make status
```

### Check service health

```bash
make health
```

### View service logs

```bash
make logs-[service-name]
```

### Reset data (removes all stored data)

```bash
make reset
```
