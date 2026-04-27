import os
import yaml
from dotenv import load_dotenv

load_dotenv()

_config = None


def load() -> dict:
    global _config
    if _config is not None:
        return _config

    config_path = os.path.join(os.path.dirname(__file__), "..", "config.yaml")
    with open(os.path.abspath(config_path), "r") as f:
        _config = yaml.safe_load(f)

    # Inject secrets from .env
    _config.setdefault("secrets", {})
    _config["secrets"]["openweather_api_key"] = os.getenv("OPENWEATHER_API_KEY", "")

    return _config
