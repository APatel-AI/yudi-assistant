"""
Jarvis — entry point.
Orchestrates all modules and speaks the full briefing on login.
"""

import sys
import os

# Allow absolute imports from project root
sys.path.insert(0, os.path.dirname(__file__))

from core import config as cfg
from ui.voice import speak_lines
from modules.greeting.greeter import build as build_greeting
from modules.ram.monitor import get_pressure
from modules.time.clock import build as build_time
from modules.weather.fetcher import build as build_weather


def main():
    config = cfg.load()

    name        = config["user"]["name"]
    voice       = config["voice"]["voice"]
    rate        = config["voice"]["rate"]
    city        = config["weather"]["city"]
    country     = config["weather"]["country_code"]
    units       = config["weather"]["units"]
    api_key     = config["secrets"]["openweather_api_key"]
    modules_on  = config.get("modules", {})

    lines = []

    if modules_on.get("greeting", True):
        lines.append(build_greeting())

    if modules_on.get("ram", True):
        lines.append(get_pressure())

    if modules_on.get("time", True):
        lines.append(build_time())

    if modules_on.get("weather", True):
        lines.append(build_weather(city, country, api_key, units))

    if lines:
        speak_lines(lines, voice=voice, rate=rate)


if __name__ == "__main__":
    main()
