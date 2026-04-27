"""
Wraps macOS `say` command for text-to-speech output.
No external packages needed — `say` ships with every Mac.
"""

import subprocess


def speak(text: str, voice: str = "Samantha", rate: int = 175) -> None:
    """Speaks the given text using the configured macOS voice."""
    subprocess.run(
        ["say", "-v", voice, "-r", str(rate), text],
        check=True,
    )


def speak_lines(lines: list[str], voice: str = "Samantha", rate: int = 175) -> None:
    """Speaks a list of strings sequentially with a natural pause between each."""
    full_text = "  ".join(lines)  # double space creates a brief pause in `say`
    speak(full_text, voice=voice, rate=rate)
