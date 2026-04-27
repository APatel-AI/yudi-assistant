"""
Reports macOS RAM pressure level: normal, warning, or critical.
Uses the built-in `memory_pressure` CLI tool — accurate for Apple Silicon.
"""

import subprocess


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
        return "RAM pressure is unavailable."
