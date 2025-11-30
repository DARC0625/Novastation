import os
from typing import List

from fastapi import Depends, FastAPI, HTTPException, Header
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="VM Portal API", version="0.1.0")

ADMIN_TOKEN = os.getenv("ADMIN_TOKEN", "dev-admin-token")


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class VM(BaseModel):
    id: str
    name: str
    protocol: str = "rdp"
    host: str
    port: int = 3389
    guac_connection_id: str | None = None


async def get_token(authorization: str | None = Header(default=None)) -> str:
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or token != ADMIN_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid token")
    return token


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/auth/login", response_model=TokenResponse)
async def login(body: LoginRequest) -> TokenResponse:
    # Replace with real auth (DB/SSO). For now, any username/password returns the admin token.
    return TokenResponse(access_token=ADMIN_TOKEN)


@app.get("/vms", response_model=List[VM])
async def list_vms(token: str = Depends(get_token)) -> List[VM]:
    # Placeholder data; replace with DB lookup + Guacamole connection mapping.
    return [
        VM(id="vm-dev-01", name="Dev VM 01", host="vm-dev-01.local", port=3389, guac_connection_id="1"),
        VM(id="vm-gpu-01", name="GPU VM", host="vm-gpu-01.local", port=3389, guac_connection_id="2"),
    ]


@app.get("/guac/link/{connection_id}")
async def guac_link(connection_id: str, token: str = Depends(get_token)) -> dict[str, str]:
    # In production, mint a short-lived token or signed link to Guacamole.
    base = os.getenv("GUAC_BASE_URL", "https://vm.example.com/guacamole/")
    return {"url": f"{base}#/client/{connection_id}"}
