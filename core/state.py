"""
Persists lightweight state to disk (state.json at project root).
Used to track things like last-run timestamp across logins.
"""

import json
import os

STATE_PATH = os.path.join(os.path.dirname(__file__), "..", "state.json")


def load() -> dict:
    if os.path.exists(STATE_PATH):
        with open(STATE_PATH, "r") as f:
            return json.load(f)
    return {}


def save(state: dict) -> None:
    with open(STATE_PATH, "w") as f:
        json.dump(state, f, indent=2)


def get(key: str, default=None):
    return load().get(key, default)


def set(key: str, value) -> None:
    state = load()
    state[key] = value
    save(state)
