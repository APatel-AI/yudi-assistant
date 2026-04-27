"""
Thin client for the OpenWeatherMap API.
Uses two endpoints:
  - Current Weather: api.openweathermap.org/data/2.5/weather
  - Air Quality:     api.openweathermap.org/data/2.5/air_pollution
"""

import requests

BASE_URL = "https://api.openweathermap.org/data/2.5"

AQI_LABELS = {
    1: "good",
    2: "fair",
    3: "moderate",
    4: "poor",
    5: "very poor",
}


def get_weather(city: str, country_code: str, api_key: str, units: str = "imperial") -> dict:
    """Returns raw current weather data for a city."""
    resp = requests.get(
        f"{BASE_URL}/weather",
        params={
            "q": f"{city},{country_code}",
            "appid": api_key,
            "units": units,
        },
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def get_air_quality(lat: float, lon: float, api_key: str) -> dict:
    """Returns raw air quality data for a lat/lon coordinate."""
    resp = requests.get(
        f"{BASE_URL}/air_pollution",
        params={"lat": lat, "lon": lon, "appid": api_key},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def fetch_summary(city: str, country_code: str, api_key: str, units: str = "imperial") -> dict:
    """
    Returns a clean summary dict:
    {
        "temp": 72,
        "feels_like": 70,
        "description": "partly cloudy",
        "aqi_label": "good",
        "unit_label": "Fahrenheit",
    }
    """
    weather = get_weather(city, country_code, api_key, units)
    lat = weather["coord"]["lat"]
    lon = weather["coord"]["lon"]
    aqi_data = get_air_quality(lat, lon, api_key)

    aqi_index = aqi_data["list"][0]["main"]["aqi"]
    unit_label = "Fahrenheit" if units == "imperial" else "Celsius"

    return {
        "temp": round(weather["main"]["temp"]),
        "feels_like": round(weather["main"]["feels_like"]),
        "description": weather["weather"][0]["description"],
        "aqi_label": AQI_LABELS.get(aqi_index, "unknown"),
        "unit_label": unit_label,
    }
