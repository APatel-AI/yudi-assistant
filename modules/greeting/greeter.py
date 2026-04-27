"""
Builds a time-aware greeting.
e.g. "Hello Sir, good morning."
"""

from datetime import datetime
from zoneinfo import ZoneInfo


def get_time_of_day() -> str:
    hour = datetime.now(ZoneInfo("America/Chicago")).hour
    if 5 <= hour < 12:
        return "good morning"
    elif 12 <= hour < 17:
        return "good afternoon"
    elif 17 <= hour < 21:
        return "good evening"
    else:
        return "good night"


def build(name: str) -> str:
    period = get_time_of_day()
    return f"Hello {name}, {period}."
