"""
Jarvis alarm entry point.
Called by launchd at scheduled times — not by the wake/login flow.

Usage:
  python alarm.py morning
  python alarm.py evening
"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from core import config as cfg
from ui.voice import speak


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("morning", "evening"):
        print("Usage: alarm.py [morning|evening]")
        sys.exit(1)

    alarm_type = sys.argv[1]
    config = cfg.load()
    voice = config["voice"]["voice"]
    rate = config["voice"]["rate"]

    if alarm_type == "morning":
        from modules.alarms.morning import build
        text = build(
            city=config["weather"]["city"],
            country_code=config["weather"]["country_code"],
            api_key=config["secrets"]["openweather_api_key"],
            units=config["weather"]["units"],
        )
    else:
        from modules.alarms.evening import build
        text = build()

    speak(text, voice=voice, rate=rate)


if __name__ == "__main__":
    main()
