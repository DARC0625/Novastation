import { useEffect, useState } from "react";
import axios from "axios";

const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";

export default function App() {
  const [token, setToken] = useState("");
  const [username, setUsername] = useState("demo");
  const [password, setPassword] = useState("demo");
  const [vms, setVms] = useState([]);
  const [status, setStatus] = useState("Ready");

  useEffect(() => {
    // Attempt auto-login if a token is already present
    if (token) {
      fetchVms(token);
    }
  }, [token]);

  const login = async () => {
    setStatus("Authenticating...");
    try {
      const res = await axios.post(`${API_BASE}/auth/login`, { username, password });
      setToken(res.data.access_token);
      setStatus("Authenticated");
    } catch (err) {
      setStatus("Login failed");
      console.error(err);
    }
  };

  const fetchVms = async (tok = token) => {
    setStatus("Loading VMs...");
    try {
      const res = await axios.get(`${API_BASE}/vms`, {
        headers: { Authorization: `Bearer ${tok}` },
      });
      setVms(res.data);
      setStatus("Loaded");
    } catch (err) {
      setStatus("Failed to load VMs");
      console.error(err);
    }
  };

  const openGuac = async (connectionId) => {
    if (!token) return;
    setStatus("Fetching Guacamole link...");
    try {
      const res = await axios.get(`${API_BASE}/guac/link/${connectionId}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      window.open(res.data.url, "_blank", "noopener,noreferrer");
      setStatus("Opened Guacamole");
    } catch (err) {
      setStatus("Failed to fetch link");
      console.error(err);
    }
  };

  return (
    <div className="app-shell">
      <header>
        <div>
          <h1>VM Portal</h1>
          <p className="status">{status}</p>
        </div>
        <div className="card" style={{ minWidth: 260 }}>
          <div style={{ display: "flex", gap: 8, marginBottom: 8 }}>
            <input
              aria-label="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="username"
            />
            <input
              type="password"
              aria-label="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="password"
            />
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <button onClick={login}>Login</button>
            <button className="secondary" onClick={() => fetchVms()} disabled={!token}>
              Refresh VMs
            </button>
          </div>
        </div>
      </header>

      <div className="card">
        <h2>My VMs</h2>
        {vms.length === 0 ? (
          <p>No VMs yet. Login and refresh to load your list.</p>
        ) : (
          <div className="vm-list">
            {vms.map((vm) => (
              <div key={vm.id} className="card vm-card">
                <h3>{vm.name}</h3>
                <p className="status">{vm.host}:{vm.port} · {vm.protocol.toUpperCase()}</p>
                <button onClick={() => openGuac(vm.guac_connection_id || vm.id)} disabled={!token}>
                  Connect
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
