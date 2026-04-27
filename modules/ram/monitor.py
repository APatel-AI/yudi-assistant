"""
Reports macOS RAM pressure level: normal, warning, or critical.
Uses the built-in `memory_pressure` CLI tool — accurate for Apple Silicon.
Falls back to psutil usage percent if the tool is unavailable.
"""

import subprocess
import psutil


def get_pressure() -> str:
    """Returns a human-readable RAM pressure string for speaking."""
    try:
        result = subprocess.run(
            ["memory_pressure"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        output = result.stdout.lower()
        if "critical" in output:
            level = "critical"
        elif "warn" in output:
            level = "warning"
        else:
            level = "normal"
        return f"RAM pressure is {level}."
    except Exception:
        # Fallback: psutil percentage
        percent = psutil.virtual_memory().percent
        return f"RAM usage is at {percent:.0f} percent."
