#!/bin/bash
set -e

REPO="https://github.com/vector-just-technology/Home-server.git"
INSTALL_DIR="$HOME/home-server"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }
head() { echo -e "\n${CYAN}=== $1 ===${NC}"; }

cleanup() {
  if [ $? -ne 0 ]; then
    err "Installation failed at step $CURRENT_STEP"
    err "Check the output above for details"
  fi
}
trap cleanup EXIT

CURRENT_STEP="initializing"

echo -e "${CYAN}"
echo "  _    _ _____ _   _ _____   _____ _           _        _ _ "
echo " | |  | |_   _| \ | |  __ \|  ___| |         | |      | | |"
echo " | |__| | | | |  \| | |  \/| |__ | | ___  ___| |_ __ _| | |"
echo " |  __  | | | | . \` | | __ |  __|| |/ _ \/ __| __/ _\` | | |"
echo " | |  | |_| |_| |\  | |_\ \| |___| |  __/\__ \ || (_| | | |"
echo " |_|  |_|\___/\_| \_/\____/\____/|_|\___||___/\__\__,_|_|_|"
echo -e "${NC}"
echo "  Home Server — Clean Installation"
echo "============================================"

CURRENT_STEP="checking-system"
head "System Requirements"

OS="$(uname -s)"
ARCH="$(uname -m)"
log "OS: $OS | Arch: $ARCH"

if [ "$OS" != "Linux" ]; then
  err "Linux required (detected: $OS)"
  exit 1
fi

has_cmd() { command -v "$1" &>/dev/null; }

check_dep() {
  if has_cmd "$1"; then
    log "$1: $($1 --version 2>&1 | head -1)"
  else
    warn "$1 not found — will install"
    return 1
  fi
}

check_dep python3
check_dep pip3
check_dep node
check_dep npm
check_dep git
check_dep curl

CURRENT_STEP="installing-deps"
head "Installing System Dependencies"

if has_cmd apt; then
  log "Debian/Ubuntu detected"
  sudo apt update -qq
  sudo apt install -y -qq python3 python3-pip python3-venv nodejs npm git curl wget sqlite3
elif has_cmd dnf; then
  log "Fedora detected"
  sudo dnf install -y python3 python3-pip nodejs npm git curl wget sqlite
elif has_cmd pacman; then
  log "Arch detected"
  sudo pacman -Sy --noconfirm python python-pip nodejs npm git curl wget sqlite
elif has_cmd zypper; then
  log "openSUSE detected"
  sudo zypper install -y python3 python3-pip nodejs npm git curl wget sqlite3
else
  warn "Unknown package manager — install python3, nodejs, npm, git manually"
fi

if ! has_cmd node; then
  warn "Node.js not found — installing via NodeSource"
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
fi

CURRENT_STEP="cloning"
head "Cloning Repository"

if [ -d "$INSTALL_DIR" ]; then
  warn "Directory $INSTALL_DIR already exists"
  read -rp "Remove and re-clone? (y/N): " confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    rm -rf "$INSTALL_DIR"
  else
    log "Using existing directory"
    cd "$INSTALL_DIR"
    git pull
  fi
fi

if [ ! -d "$INSTALL_DIR" ]; then
  log "Cloning into $INSTALL_DIR"
  git clone "$REPO" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

CURRENT_STEP="python-env"
head "Setting Up Python Environment"

if [ ! -d ".venv" ]; then
  log "Creating virtual environment"
  python3 -m venv .venv
fi

log "Installing Python packages"
.venv/bin/pip install --upgrade pip -q
.venv/bin/pip install -r requirements.txt -q

CURRENT_STEP="database"
head "Initializing Database"

DB="server/instance/alpha.db"
mkdir -p server/instance

if [ -f "$DB" ]; then
  log "Database exists — running migrations"
else
  log "Creating database"
fi

cd server
../.venv/bin/python -c "
from main import create_app, db
app = create_app()
with app.app_context():
    db.create_all()
    print('Database tables created')
" 2>/dev/null || true
cd ..

python3 -c "
import sqlite3, os
db_path = os.path.join('server', 'instance', 'alpha.db')
if os.path.exists(db_path):
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    for table in ['user', 'chat_message', 'conversation']:
        c.execute(f'PRAGMA table_info({table})')
        cols = [row[1] for row in c.fetchall()]
        if table == 'user' and 'permissions' not in cols:
            c.execute(\"ALTER TABLE user ADD COLUMN permissions TEXT DEFAULT '{}'\")
            log('Added permissions column to user')
        if table == 'chat_message' and 'conversation_id' not in cols:
            c.execute('ALTER TABLE chat_message ADD COLUMN conversation_id VARCHAR(64)')
            log('Added conversation_id to chat_message')
    conn.commit()
    conn.close()
" 2>/dev/null || true

CURRENT_STEP="building-frontend"
head "Building Frontend"

cd ui
if [ ! -d "node_modules" ]; then
  log "Installing npm packages"
  npm install
fi
log "Building production bundle"
npm run build
cd ..

CURRENT_STEP="ollama"
head "Setting Up Ollama (Optional)"

if ! has_cmd ollama; then
  warn "Installing Ollama..."
  if has_cmd wget; then
    wget -qO- https://ollama.com/install.sh | sh 2>/dev/null || true
  else
    curl -fsSL https://ollama.com/install.sh | sh 2>/dev/null || true
  fi
fi

if has_cmd ollama; then
  log "Pulling AI models (background)"
  nohup ollama pull llama3.2:1b >/dev/null 2>&1 &
  nohup ollama pull mistral:7b >/dev/null 2>&1 &
else
  warn "Ollama skipped — install manually: curl -fsSL https://ollama.com/install.sh | sh"
fi

CURRENT_STEP="systemd-service"
head "Creating Systemd Service"

SERVICE_FILE="/etc/systemd/system/home-server.service"
cat << 'SERVICEEOF' | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Home Server
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/home-server
ExecStart=/home/pi/home-server/.venv/bin/python /home/pi/home-server/server/run.py
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
SERVICEEOF

sudo sed -i "s|/home/pi|$HOME|g" "$SERVICE_FILE"

log "Enabling service"
sudo systemctl daemon-reload
sudo systemctl enable home-server.service

CURRENT_STEP="starting"
head "Starting Server"

sudo systemctl restart home-server.service || true

for i in $(seq 1 15); do
  if curl -s http://localhost:5000/api/status &>/dev/null; then
    log "Server is online!"
    break
  fi
  sleep 2
done

IP=$(hostname -I | awk '{print $1}')
log "Installation complete!"
echo ""
echo -e "  ${GREEN}Open in browser:${NC}  http://$IP:5000"
echo -e "  ${YELLOW}First visit?${NC}       Click 'Create one' to register as admin"
echo -e "  ${YELLOW}Manage service:${NC}    sudo systemctl {start|stop|restart} home-server"
echo -e "  ${YELLOW}View logs:${NC}         sudo journalctl -u home-server -f"
echo ""
