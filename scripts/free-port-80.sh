#!/usr/bin/env bash
# Free port 80 (and 443) so the Docker nginx container can bind.
# Run with: sudo ./scripts/free-port-80.sh  (or run the commands below yourself)
set -e
echo "Checking what is using port 80..."
if ! command -v lsof >/dev/null 2>&1; then
  echo "Install lsof (e.g. apt install lsof) or run: sudo systemctl stop nginx"
  exit 1
fi
PID=$(lsof -t -i:80 2>/dev/null || true)
if [ -z "$PID" ]; then
  echo "Port 80 is free. You can run: docker compose up -d"
  exit 0
fi
echo "Port 80 is in use by PID(s): $PID"
# Prefer stopping nginx service if it's the one listening (Linux)
if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet nginx 2>/dev/null; then
  echo "Stopping host nginx (systemctl)..."
  sudo systemctl stop nginx
  echo "Done. Start your stack: docker compose up -d"
  exit 0
fi
# macOS / Homebrew nginx
if [ -f /opt/homebrew/opt/nginx/bin/nginx ] || [ -f /usr/local/opt/nginx/bin/nginx ]; then
  echo "Stopping nginx..."
  sudo nginx -s stop 2>/dev/null || true
  sleep 1
  if ! lsof -t -i:80 >/dev/null 2>&1; then
    echo "Done. Run: docker compose up -d"
    exit 0
  fi
fi
# Otherwise kill the process(es) on port 80
echo "Stopping process(es) on port 80 (need sudo)..."
PIDS=$(lsof -t -i:80 2>/dev/null || true)
if [ -n "$PIDS" ]; then
  sudo kill $PIDS 2>/dev/null || true
  sleep 2
fi
if lsof -t -i:80 >/dev/null 2>&1; then
  echo "Still in use. Try: sudo kill \$(lsof -t -i:80)"
  exit 1
fi
echo "Port 80 is free. Run: docker compose up -d"
