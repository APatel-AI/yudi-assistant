"""
Builds a spoken weather + air quality string.
e.g. "Currently in Chicago it's 68 degrees Fahrenheit, partly cloudy,
      and feels like 65. Air quality is good."
"""

from integrations.openweathermap import fetch_summary


def build(city: str, country_code: str, api_key: str, units: str = "imperial") -> str:
    try:
        data = fetch_summary(city, country_code, api_key, units)
        return (
            f"Currently in {city} it's {data['temp']} degrees {data['unit_label']}, "
            f"{data['description']}, and feels like {data['feels_like']}. "
            f"Air quality is {data['aqi_label']}."
        )
    except Exception as e:
        return f"Weather information is currently unavailable."
