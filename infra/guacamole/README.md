# Guacamole Stack (Docker Compose)

Ubuntu 22.04 VM (`vm-guac-01`) running Apache Guacamole with PostgreSQL. Provides browser-based RDP access to Proxmox VMs.

## Quick start
1) Copy `.env.example` to `.env` and set strong passwords.
2) Bring up Postgres + guacd:
   ```bash
   docker compose up -d postgres guacd
   ```
3) Initialize the Guacamole database schema (one-time):
   ```bash
   docker compose run --rm guacamole /opt/guacamole/bin/initdb.sh --postgresql > guac-initdb.sql
   docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /dev/stdin < guac-initdb.sql
   rm guac-initdb.sql
   ```
4) Start all services:
   ```bash
   docker compose up -d
   ```
5) Access the web UI at `http(s)://<host>:${GUACAMOLE_WEB_PORT:-8080}/guacamole/` and log in with the admin credentials from `.env`.

## Nginx reverse proxy (optional)
- Use `nginx.conf` as a template for HTTPS termination and to serve Guacamole at a clean domain (e.g., `https://vm.example.com/`).
- Place TLS cert/key (or certbot-managed `fullchain.pem`/`privkey.pem`) in a secure path and update the `ssl_certificate` lines accordingly.

## Connecting VMs
- For each VM, enable RDP (Windows) or xrdp (Ubuntu). Ensure firewall rules allow the Guacamole VM to reach the RDP port (3389).
- In the Guacamole admin UI, create a connection per VM (protocol RDP) and assign it to the appropriate users.
