"""
Morning alarm message.
e.g. "Hello, good morning. It is currently 4:30 AM.
      Now would be a great time to wake up.
      It's currently 58 degrees Fahrenheit outside.
      Have a great day, Sir."
"""

from datetime import datetime
from zoneinfo import ZoneInfo
from integrations.openweathermap import fetch_summary
from core import config as cfg


def build(city: str, country_code: str, api_key: str, units: str = "imperial") -> str:
    tz = cfg.load()["user"].get("timezone", "America/New_York")
    now = datetime.now(ZoneInfo(tz))
    time_str = now.strftime("%-I:%M %p")  # e.g. "4:30 AM"

    try:
        data = fetch_summary(city, country_code, api_key, units)
        unit_word = "Fahrenheit" if units == "imperial" else "Celsius"
        temp_str = f"{data['temp']} degrees {unit_word}"
    except Exception:
        temp_str = "an unknown temperature"

    return (
        f"Hello, good morning Sir. It is currently {time_str}. "
        f"Now would be a great time to wake up. "
        f"It's currently {temp_str} outside. "
        f"Have a great day, Sir."
    )
