#!/bin/bash
# Jarvis Setup Script
# Run once to install dependencies and register the login agent.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.jarvis.assistant.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
LOGS_DIR="$PROJECT_DIR/logs"

echo "==> Setting up Jarvis..."

# 1. Check Python 3.9+
PYTHON=$(which python3)
PYTHON_VERSION=$($PYTHON -c 'import sys; print(sys.version_info[:2])')
echo "    Python: $PYTHON ($PYTHON_VERSION)"

# 2. Create virtual environment
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    echo "==> Creating virtual environment..."
    $PYTHON -m venv "$PROJECT_DIR/.venv"
fi

VENV_PYTHON="$PROJECT_DIR/.venv/bin/python"

# 3. Install dependencies
echo "==> Installing Python dependencies..."
"$VENV_PYTHON" -m pip install --upgrade pip -q
"$VENV_PYTHON" -m pip install -r "$PROJECT_DIR/requirements.txt" -q

# 4. Create .env if it doesn't exist
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "==> Creating .env from template..."
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo ""
    echo "    ACTION REQUIRED: Open .env and add your OpenWeatherMap API key."
    echo "    Get a free key at: https://openweathermap.org/api"
    echo ""
fi

# 5. Create logs directory
mkdir -p "$LOGS_DIR"

# 6. Generate the Launch Agent plist with real paths
echo "==> Registering Login Agent..."
mkdir -p "$LAUNCH_AGENTS_DIR"

PLIST_SRC="$PROJECT_DIR/launchagent/$PLIST_NAME"
PLIST_DEST="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

sed \
    -e "s|PYTHON_PATH_PLACEHOLDER|$VENV_PYTHON|g" \
    -e "s|PROJECT_PATH_PLACEHOLDER|$PROJECT_DIR|g" \
    "$PLIST_SRC" > "$PLIST_DEST"

# 7. Load the agent (unload first in case it was already registered)
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo ""
echo "✓ Jarvis is set up and will run automatically on your next login."
echo ""
echo "To test it right now, run:"
echo "  $VENV_PYTHON $PROJECT_DIR/run.py"
echo ""
echo "To uninstall:"
echo "  launchctl unload $PLIST_DEST && rm $PLIST_DEST"
