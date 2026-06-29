<p align="center">
  <img width="334" height="115" alt="Home Server" src="https://github.com/user-attachments/assets/bfa10489-5590-481d-8f49-fb03d3a1234a" />
</p>
<p align="center">
  <img src="https://img.shields.io/badge/React-JS-blue" alt="ReactJS">
  <img src="https://img.shields.io/badge/Flask-Python-green" alt="Flask">
  <img src="https://img.shields.io/badge/Licence-MIT-orange" alt="Licence">
  <a href="https://github.com/vector-just-technology">
    <img src="https://img.shields.io/badge/My-Profile-purple" alt="GitHub Repo">
  </a>
</p>

<p align="center">
  A full-featured personal cloud operating system for your Raspberry Pi — dashboard, AI studio, storage management, device monitoring, and more.
</p>

---

## One-Line Install

```bash
curl -sL https://raw.githubusercontent.com/vector-just-technology/Home-server/master/install.sh | bash
```

This installs everything: Python/Node dependencies, builds the frontend, sets up the database, creates a systemd service, and starts the server. Open `http://<pi-ip>:5000` in your browser.

The first user to register becomes the administrator.

---

## Features

| Category | What's Included |
|----------|----------------|
| **Dashboard** | Live metrics, CPU/RAM/disk charts, top processes, alerts panel, real-time clock, animated counters with sparklines |
| **AI Studio** | Chat interface with multiple providers (Ollama, OpenAI-compatible), file analysis, code generation, image generation, GitHub intel |
| **Storage** | Drive overview, SMART data, ZFS pool info, RAID status, safe drive detection (excludes OS drive), format/mount controls |
| **Devices** | HomeAssistant-style room grouping, network map, 29 device type icons, ping/status toggles, ARP + nmap discovery |
| **System Tools** | 20 category tabs with 100+ tools: Services, Docker, Cron, Firewall, Sensors, USB, Kernel Modules, Packages, Env, Connections |
| **Users & Permissions** | Granular per-user permissions — 14 pages × 40+ actions, 8 feature toggles, storage/device limits, restrictiveness meter |
| **Customization** | 10,000+ options: typography, layout density, card/button/input styles, 85 languages, 43 currencies, custom CSS, 24 accent colors, 54 wallpapers, image upload |
| **Extensions** | 50+ entries with detail modals, toggle switches, version tracking |
| **WiFi Hotspot** | Built-in access point mode — default SSID `V-Home-server`, password `homeserver` |
| **Notifications** | Real-time notification system with read/unread tracking |
| **Backup & Security** | Backup jobs, encryption config, audit log, share links with password protection |

---

## Quick Start (Manual)

```bash
# Clone
git clone https://github.com/vector-just-technology/Home-server.git
cd Home-server

# Backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Frontend
cd ui
npm install
npm run build
cd ..

# Database
cd server
../.venv/bin/python -c "from main import create_app, db; app = create_app(); app.app_context().push(); db.create_all()"
cd ..

# Run
.venv/bin/python server/run.py
```

Then open `http://<pi-ip>:5000`.

---

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Board** | Raspberry Pi 4 (4GB) | Raspberry Pi 5 (8GB+) |
| **Storage** | 32GB SD card | 128GB+ SSD via USB |
| **RAM** | 4GB | 8GB+ |
| **OS** | Raspberry Pi OS (64-bit) | Raspberry Pi OS (64-bit) |

---

## Ollama Integration (Optional)

For local AI models:

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:1b
ollama pull mistral:7b
```

Requires a Raspberry Pi 5 with 6GB+ RAM for reasonable performance.
The server also supports OpenAI-compatible cloud APIs (OpenAI, Groq, etc.).

---

## Project Structure

```
├── server/                 # Flask backend
│   ├── api/               # API blueprints (auth, storage, devices, ai, etc.)
│   ├── models/            # SQLAlchemy models
│   ├── main.py            # App factory
│   ├── config.py          # Configuration
│   └── run.py             # Entry point
├── ui/                    # React frontend (Vite)
│   ├── src/
│   │   ├── pages/        # Page components
│   │   ├── components/   # Reusable components
│   │   ├── hooks/        # React hooks
│   │   ├── styles/       # Global CSS
│   │   └── utils/        # API client, types
│   └── package.json
├── update.sh              # Update script (git pull + build + restart)
├── install.sh             # Clean installation script
└── README.md
```

---

## Updating

```bash
cd ~/home-server
git pull
bash update.sh
```

Or use the **Dev Update** button on the login page.

---

## Service Management

```bash
sudo systemctl start home-server
sudo systemctl stop home-server
sudo systemctl restart home-server
sudo journalctl -u home-server -f   # Live logs
```

---

## License

MIT
