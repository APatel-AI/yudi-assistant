"""
Builds a time-aware greeting.
e.g. "Hello Sir, good morning."
"""

from datetime import datetime
from zoneinfo import ZoneInfo
from core import config as cfg


def get_time_of_day() -> str:
    tz = cfg.load()["user"].get("timezone", "America/New_York")
    hour = datetime.now(ZoneInfo(tz)).hour
    if 5 <= hour < 12:
        return "good morning"
    elif 12 <= hour < 17:
        return "good afternoon"
    elif 17 <= hour < 21:
        return "good evening"
    else:
        return "good night"


def build() -> str:
    period = get_time_of_day()
    return f"Hello Sir, {period}."
