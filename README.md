# 🚀 Grafana Monitoring Stack

Docker Compose setup for full-featured monitoring & logging:

- 📊 Grafana ([Port 3000](http://localhost:3000)) – Dashboards & visualisation `admin/admin`
- 📈 Prometheus ([Port 9090](http://localhost:9090)) – Metrics collection
- 📜 Loki ([Port 3100](http://localhost:3100)) – Log aggregation
- 🚚 Promtail – Log shipping agent

## ⚡ Quick Start

Start the stack:

```bash
make start
```

## 📁 Directory Structure

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

## 🛠️ Managing the Stack

Run make help for all options, commands:

```bash
make start       # 🚀 Start the stack
make stop        # 🛑 Stop the stack
make restart     # ♻️ Restart services
make logs        # 📄 View all logs
make status      # 🔍 Check service status
make reset       # 💥 Reset stack (removes data)
make update      # ⬆️ Pull latest images
```

View logs per service:

```bash
make logs-grafana
make logs-prometheus
make logs-loki
make logs-promtail
```

## 💾 Data Persistence

Docker volumes keep your data safe:

- `grafana-storage` - Dashboards and settings
- `prometheus-storage` - Metrics
- `loki-storage` - Logs
