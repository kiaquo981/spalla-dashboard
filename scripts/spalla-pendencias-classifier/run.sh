#!/bin/zsh
# Entrypoint do classifier — chamado pelo launchd a cada 30min
cd "$(dirname "$0")"
LOG_DIR="${HOME}/Library/Logs/spalla-pendencias-classifier"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/$(date +%Y-%m-%d).log"
exec /opt/homebrew/bin/python3 classifier.py --limit 30 >> "$LOG" 2>&1
