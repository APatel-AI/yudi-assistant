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

# 8. Register sleepwatcher wake hook
echo "==> Registering sleepwatcher wake hook..."
WAKEUP_SCRIPT="$PROJECT_DIR/scripts/wakeup.sh"
WAKEUP_LINK="$HOME/.wakeup"

if [ ! -f "$WAKEUP_SCRIPT" ]; then
    echo "    ERROR: $WAKEUP_SCRIPT not found. Skipping sleepwatcher setup."
else
    # Remove existing link/file if present
    [ -e "$WAKEUP_LINK" ] && rm "$WAKEUP_LINK"
    ln -s "$WAKEUP_SCRIPT" "$WAKEUP_LINK"
    echo "    Symlinked ~/.wakeup -> $WAKEUP_SCRIPT"

    # Start sleepwatcher service if installed
    if command -v sleepwatcher &>/dev/null || [ -f "/opt/homebrew/bin/sleepwatcher" ]; then
        brew services start sleepwatcher 2>/dev/null && \
            echo "    sleepwatcher service started." || \
            echo "    sleepwatcher already running or could not start — check: brew services list"
    else
        echo "    WARNING: sleepwatcher not found. Install it with: brew install sleepwatcher"
    fi
fi

# 9. Register morning + evening alarm agents
echo "==> Registering alarm agents..."

# Parse alarm times from config.yaml
MORNING_HOUR=$("$VENV_PYTHON" -c "import yaml; c=yaml.safe_load(open('$PROJECT_DIR/config.yaml')); print(c['alarms']['morning']['hour'])")
MORNING_MINUTE=$("$VENV_PYTHON" -c "import yaml; c=yaml.safe_load(open('$PROJECT_DIR/config.yaml')); print(c['alarms']['morning']['minute'])")
EVENING_HOUR=$("$VENV_PYTHON" -c "import yaml; c=yaml.safe_load(open('$PROJECT_DIR/config.yaml')); print(c['alarms']['evening']['hour'])")
EVENING_MINUTE=$("$VENV_PYTHON" -c "import yaml; c=yaml.safe_load(open('$PROJECT_DIR/config.yaml')); print(c['alarms']['evening']['minute'])")

echo "    Morning alarm: $(printf '%02d:%02d' $MORNING_HOUR $MORNING_MINUTE)"
echo "    Evening alarm: $(printf '%02d:%02d' $EVENING_HOUR $EVENING_MINUTE)"

for ALARM in morning evening; do
    SRC="$PROJECT_DIR/launchagent/com.jarvis.$ALARM.plist"
    DEST="$LAUNCH_AGENTS_DIR/com.jarvis.$ALARM.plist"

    sed \
        -e "s|PYTHON_PATH_PLACEHOLDER|$VENV_PYTHON|g" \
        -e "s|PROJECT_PATH_PLACEHOLDER|$PROJECT_DIR|g" \
        -e "s|MORNING_HOUR_PLACEHOLDER|$MORNING_HOUR|g" \
        -e "s|MORNING_MINUTE_PLACEHOLDER|$MORNING_MINUTE|g" \
        -e "s|EVENING_HOUR_PLACEHOLDER|$EVENING_HOUR|g" \
        -e "s|EVENING_MINUTE_PLACEHOLDER|$EVENING_MINUTE|g" \
        "$SRC" > "$DEST"

    launchctl unload "$DEST" 2>/dev/null || true
    launchctl load "$DEST"
    echo "    Loaded com.jarvis.$ALARM"
done

# 10. Schedule Mac wake 2 minutes before morning alarm (so launchd can fire it from sleep)
echo "==> Scheduling daily Mac wake before morning alarm..."
WAKE_MINUTE=$((MORNING_MINUTE - 2))
WAKE_HOUR=$MORNING_HOUR
if [ $WAKE_MINUTE -lt 0 ]; then
    WAKE_MINUTE=$((60 + WAKE_MINUTE))
    WAKE_HOUR=$((MORNING_HOUR - 1))
fi
WAKE_TIME=$(printf "%02d:%02d:00" $WAKE_HOUR $WAKE_MINUTE)
echo "    sudo pmset repeat wake MTWRFSU $WAKE_TIME"
sudo pmset repeat wake MTWRFSU $WAKE_TIME && \
    echo "    Mac will wake at $WAKE_TIME daily." || \
    echo "    WARNING: pmset failed. Morning alarm may not fire from sleep. Try running manually with sudo."

echo ""
echo "✓ Jarvis is set up."
echo "  - Speaks on login (Launch Agent)"
echo "  - Speaks on wake from sleep (sleepwatcher)"
echo "  - Morning alarm at $(printf '%02d:%02d' $MORNING_HOUR $MORNING_MINUTE) (Mac wakes at $WAKE_TIME)"
echo "  - Evening reminder at $(printf '%02d:%02d' $EVENING_HOUR $EVENING_MINUTE)"
echo ""
echo "To test alarms right now:"
echo "  $VENV_PYTHON $PROJECT_DIR/alarm.py morning"
echo "  $VENV_PYTHON $PROJECT_DIR/alarm.py evening"
echo ""
echo "To change alarm times: edit config.yaml then re-run ./setup.sh"
echo ""
echo "To uninstall:"
echo "  launchctl unload $PLIST_DEST && rm $PLIST_DEST"
echo "  launchctl unload $LAUNCH_AGENTS_DIR/com.jarvis.morning.plist && rm $LAUNCH_AGENTS_DIR/com.jarvis.morning.plist"
echo "  launchctl unload $LAUNCH_AGENTS_DIR/com.jarvis.evening.plist && rm $LAUNCH_AGENTS_DIR/com.jarvis.evening.plist"
echo "  sudo pmset repeat cancel"
echo "  brew services stop sleepwatcher && rm ~/.wakeup"
