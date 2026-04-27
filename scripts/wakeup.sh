#!/bin/bash
# Called by sleepwatcher on every wake from sleep.
# Symlinked to ~/.wakeup by setup.sh.

PROJECT_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
VENV_PYTHON="$PROJECT_DIR/.venv/bin/python"
LOG="$PROJECT_DIR/logs/jarvis.log"
ERR="$PROJECT_DIR/logs/jarvis_error.log"

"$VENV_PYTHON" "$PROJECT_DIR/run.py" >> "$LOG" 2>> "$ERR"
