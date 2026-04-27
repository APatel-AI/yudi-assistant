"""
Returns current Central and Eastern times as a spoken string.
No internet or API needed — uses Python's built-in zoneinfo.
"""

from datetime import datetime
from zoneinfo import ZoneInfo


def build() -> str:
    fmt = "%-I:%M %p"  # e.g. "2:45 PM" — no leading zero on macOS/Linux

    central = datetime.now(ZoneInfo("America/Chicago")).strftime(fmt)
    eastern = datetime.now(ZoneInfo("America/New_York")).strftime(fmt)

    return (
        f"The current Central time is {central}, "
        f"and {eastern} Eastern."
    )
