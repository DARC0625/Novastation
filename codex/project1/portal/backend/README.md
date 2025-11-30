# FastAPI Portal Backend (optional)

Minimal API skeleton to manage users and VM links for Guacamole. Replace the in-memory stubs with a real database and auth provider.

## Setup
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # set ADMIN_TOKEN, DATABASE_URL, GUAC_BASE_URL
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Endpoints
- `GET /health`
- `POST /auth/login` → returns bearer token (stubbed)
- `GET /vms` (protected) → sample VM list
- `GET /guac/link/{connection_id}` (protected) → returns Guacamole client URL

## Next steps
- Implement real user auth (SSO or password) and JWT issuance.
- Persist users/VM mappings in PostgreSQL (align with Guacamole connection IDs).
- Issue short-lived Guacamole tokens or embed SSO flows.
