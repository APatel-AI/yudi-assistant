# Jarvis — Mac Login Assistant

A lightweight, voice-based briefing assistant for macOS. On every login, Jarvis speaks a personalized briefing covering your greeting, RAM pressure, current time zones, and weather with air quality.

No Electron. No menu bar bloat. One Python process that runs, speaks, and exits.

---

## When It Runs

| Event | Speaks? |
|---|---|
| Login (after boot or log out) | Yes — via Launch Agent |
| Wake from sleep | Yes — via sleepwatcher |
| Lock screen unlock | No |

## What It Says

On each login or wake from sleep:

> *"Hello Arpan, good morning. RAM pressure is normal. The current Central time is 8:45 AM, and 9:45 AM Eastern. Currently in Chicago it's 62 degrees Fahrenheit, partly cloudy, and feels like 59. Air quality is good."*

---

## Project Structure

```
jarvis/
├── run.py                          # Entry point — orchestrates all modules
├── config.yaml                     # Your personal settings (name, city, voice)
├── .env                            # Secret API keys — never commit this
├── .env.example                    # Template for .env
├── requirements.txt                # Python dependencies
├── setup.sh                        # One-time install + login agent + sleepwatcher registration
│
├── scripts/
│   └── wakeup.sh                   # Called by sleepwatcher on every wake — symlinked to ~/.wakeup
│
├── core/
│   ├── config.py                   # Loads config.yaml + .env
│   └── state.py                    # Persists state across logins (JSON)
│
├── modules/                        # Self-contained feature modules
│   ├── greeting/greeter.py         # Time-aware greeting ("good morning" etc.)
│   ├── ram/monitor.py              # RAM pressure via macOS memory_pressure tool
│   ├── time/clock.py               # Central + Eastern time strings
│   └── weather/fetcher.py          # Weather + AQI spoken summary
│
├── ui/
│   └── voice.py                    # Wraps macOS `say` command
│
├── integrations/
│   └── openweathermap.py           # OpenWeatherMap API client (weather + AQI)
│
├── launchagent/
│   └── com.jarvis.assistant.plist  # Login Agent template (setup.sh fills paths)
│
└── logs/
    ├── jarvis.log                  # stdout from each run
    └── jarvis_error.log            # stderr / errors
```

---

## Requirements

- macOS (Apple Silicon or Intel)
- Python 3.9 or later (`python3 --version` to check)
- A free [OpenWeatherMap API key](https://openweathermap.org/api) (takes ~2 minutes to get)

---

## Setup

### 1. Clone / navigate to the project

```bash
cd /path/to/jarvis
```

### 2. Add your OpenWeatherMap API key

Sign up free at [openweathermap.org](https://openweathermap.org/api), then copy `.env.example`:

```bash
cp .env.example .env
```

Open `.env` and replace `your_api_key_here` with your actual key:

```
OPENWEATHER_API_KEY=abc123yourkeyhere
```

### 3. Personalize `config.yaml`

```yaml
user:
  name: "Arpan"          # Your name for the greeting

voice:
  rate: 175              # Speaking speed (words per minute)
  voice: "Samantha"      # Run `say -v ?` in Terminal to see all available voices

weather:
  city: "Chicago"        # Your city
  country_code: "US"
  units: "imperial"      # imperial = °F  |  metric = °C
```

### 4. Run setup

```bash
./setup.sh
```

This will:
- Create a Python virtual environment in `.venv/`
- Install all dependencies
- Register a **Login Agent** so Jarvis runs automatically on every login

### 5. Test it immediately

```bash
.venv/bin/python run.py
```

You should hear your full briefing spoken aloud.

---

## Toggling Features On/Off

Edit `config.yaml` — set any module to `false` to silence it:

```yaml
modules:
  greeting: true
  ram: true
  time: true
  weather: false    # <-- turns off weather without touching any code
```

No restart needed for the next login.

---

## Changing the Voice

Run this in Terminal to hear all available voices:

```bash
say -v ? | grep en_
```

Then update `config.yaml`:

```yaml
voice:
  voice: "Alex"     # or "Daniel", "Karen", "Moira", etc.
```

---

## Viewing Logs

If something sounds wrong or goes silent, check the logs:

```bash
# Recent output
cat logs/jarvis.log

# Errors (e.g. bad API key, network issue)
cat logs/jarvis_error.log
```

---

## Uninstalling

```bash
# Remove login agent
launchctl unload ~/Library/LaunchAgents/com.jarvis.assistant.plist
rm ~/Library/LaunchAgents/com.jarvis.assistant.plist

# Remove sleep/wake hook
brew services stop sleepwatcher
rm ~/.wakeup
```

The project folder and `.venv` can then be deleted manually.

---

## Adding New Features

Each feature is a self-contained module:

1. Create a folder under `modules/` (e.g. `modules/calendar/`)
2. Add an `__init__.py` and your logic file
3. Return a plain string meant to be spoken
4. Import and call it in `run.py`
5. Add a toggle for it in `config.yaml` under `modules:`

---

## Troubleshooting

| Problem | Fix |
|---|---|
| No sound on login | Check `logs/jarvis_error.log` for Python errors |
| Wrong city weather | Verify `city` + `country_code` in `config.yaml` |
| `API key invalid` error | Check your `.env` file has the correct key |
| Voice not found | Run `say -v ?` and use an exact name from the list |
| Runs too early (desktop not ready) | The plist has a 10s delay — increase `ThrottleInterval` if needed |
