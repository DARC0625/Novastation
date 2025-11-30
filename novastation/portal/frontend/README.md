# React Portal Frontend (optional)

Lightweight dashboard to list accessible VMs and open Guacamole links via the backend API.

## Setup
```bash
npm install
npm run dev -- --host 0.0.0.0 --port 5173
```

Set `VITE_API_BASE_URL` in an `.env` file (e.g., `http://localhost:8000`). Example `.env`:
```
VITE_API_BASE_URL=http://localhost:8000
```

## Notes
- The backend currently returns a static token and mock VM list; replace with real auth and data.
- The "Connect" button opens the Guacamole client URL returned by the backend.
