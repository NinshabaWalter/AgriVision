"""
Enhanced Weather Service for Agricultural Intelligence Platform
Handles hyper-local weather data, SMS alerts, and agricultural-specific features
"""

import logging
import requests
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import asyncio
import json
from geopy.distance import geodesic

from ..core.config import settings
from ..models.weather import WeatherAlert, WeatherData
from .sms_service import sms_service

logger = logging.getLogger(__name__)

class EnhancedWeatherService:
    """Enhanced service for hyper-local weather data and agricultural alerts"""
    
    def __init__(self):
        self.api_key = settings.OPENWEATHER_API_KEY
        self.base_url = "https://api.openweathermap.org/data/2.5"
        self.onecall_url = "https://api.openweathermap.org/data/3.0/onecall"
        
        # East African weather stations for hyper-local data
        self.weather_stations = {
            "kenya": [
                {"name": "Nairobi", "lat": -1.2921, "lon": 36.8219},
                {"name": "Mombasa", "lat": -4.0435, "lon": 39.6682},
                {"name": "Kisumu", "lat": -0.1022, "lon": 34.7617},
                {"name": "Nakuru", "lat": -0.3031, "lon": 36.0800},
                {"name": "Eldoret", "lat": 0.5143, "lon": 35.2698},
                {"name": "Meru", "lat": 0.0469, "lon": 37.6556},
                {"name": "Kitale", "lat": 1.0167, "lon": 35.0000}
            ],
            "tanzania": [
                {"name": "Dar es Salaam", "lat": -6.7924, "lon": 39.2083},
                {"name": "Arusha", "lat": -3.3869, "lon": 36.6830},
                {"name": "Mwanza", "lat": -2.5164, "lon": 32.9175},
                {"name": "Dodoma", "lat": -6.1630, "lon": 35.7516},
                {"name": "Mbeya", "lat": -8.9094, "lon": 33.4607}
            ],
            "uganda": [
                {"name": "Kampala", "lat": 0.3476, "lon": 32.5825},
                {"name": "Gulu", "lat": 2.7796, "lon": 32.2990},
                {"name": "Mbarara", "lat": -0.6107, "lon": 30.6591},
                {"name": "Jinja", "lat": 0.4244, "lon": 33.2040}
            ],
            "ethiopia": [
                {"name": "Addis Ababa", "lat": 9.1450, "lon": 40.4897},
                {"name": "Bahir Dar", "lat": 11.5942, "lon": 37.3914},
                {"name": "Hawassa", "lat": 7.0621, "lon": 38.4776},
                {"name": "Jimma", "lat": 7.6667, "lon": 36.8333}
            ]
        }
        
        # Agricultural weather thresholds
        self.alert_thresholds = {
            "high_temperature": 35,  # Celsius
            "low_temperature": 5,   # Celsius
            "high_humidity": 85,    # Percentage
            "low_humidity": 30,     # Percentage
            "heavy_rain": 50,       # mm per day
            "drought_days": 14,     # Days without rain
            "strong_wind": 25       # km/h
        }
    
    async def get_hyper_local_weather(self, latitude: float, longitude: float, radius_km: int = 10) -> Dict[str, Any]:
        """Get hyper-local weather data within specified radius (5-10km)"""
        try:
            # Get current weather for exact location
            current_weather = await self.get_current_weather(latitude, longitude)
            
            # Find nearby weather stations
            nearby_stations = self._find_nearby_stations(latitude, longitude, radius_km)
            
            # Get weather data from nearby stations
            station_data = []
            for station in nearby_stations:
                station_weather = await self.get_current_weather(station["lat"], station["lon"])
                if station_weather:
                    station_weather["station_name"] = station["name"]
                    station_weather["distance_km"] = geodesic(
                        (latitude, longitude), 
                        (station["lat"], station["lon"])
                    ).kilometers
                    station_data.append(station_weather)
            
            # Calculate micro-climate adjustments
            micro_climate = self._calculate_micro_climate(current_weather, station_data)
            
            # Get agricultural recommendations
            agri_recommendations = self._get_agricultural_recommendations(micro_climate or current_weather)
            
            return {
                "location": {"lat": latitude, "lon": longitude},
                "current_weather": current_weather,
                "micro_climate": micro_climate,
                "nearby_stations": station_data,
                "agricultural_recommendations": agri_recommendations,
                "radius_km": radius_km,
                "timestamp": datetime.utcnow()
            }
            
        except Exception as e:
            logger.error(f"Error fetching hyper-local weather: {str(e)}")
            return {}
    
    async def get_current_weather(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Get current weather for given coordinates"""
        try:
            url = f"{self.base_url}/weather"
            params = {
                "lat": latitude,
                "lon": longitude,
                "appid": self.api_key,
                "units": "metric"
            }
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            return {
                "temperature": data["main"]["temp"],
                "feels_like": data["main"]["feels_like"],
                "temperature_min": data["main"]["temp_min"],
                "temperature_max": data["main"]["temp_max"],
                "humidity": data["main"]["humidity"],
                "pressure": data["main"]["pressure"],
                "description": data["weather"][0]["description"],
                "condition": data["weather"][0]["main"],
                "wind_speed": data["wind"]["speed"] * 3.6,  # Convert m/s to km/h
                "wind_direction": data["wind"].get("deg", 0),
                "visibility": data.get("visibility", 0) / 1000,  # Convert to km
                "uv_index": data.get("uvi", 0),
                "sunrise": datetime.fromtimestamp(data["sys"]["sunrise"]),
                "sunset": datetime.fromtimestamp(data["sys"]["sunset"]),
                "timestamp": datetime.utcnow()
            }
            
        except Exception as e:
            logger.error(f"Error fetching current weather: {str(e)}")
            return {}
    
    async def get_rainfall_prediction(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Get detailed rainfall predictions and seasonal calendar"""
        try:
            # Get 14-day forecast
            forecast = await self.get_weather_forecast(latitude, longitude, 14)
            
            # Calculate rainfall statistics
            total_rainfall = sum(day.get("precipitation", 0) for day in forecast)
            rainy_days = len([day for day in forecast if day.get("precipitation", 0) > 1])
            heavy_rain_days = len([day for day in forecast if day.get("precipitation", 0) > 10])
            
            # Determine season based on location and date
            season_info = self._get_seasonal_info(latitude, longitude)
            
            # Generate rainfall calendar
            rainfall_calendar = self._generate_rainfall_calendar(latitude, longitude)
            
            # Get drought/flood risk assessment
            risk_assessment = self._assess_weather_risks(forecast, season_info)
            
            return {
                "location": {"lat": latitude, "lon": longitude},
                "next_14_days": {
                    "total_rainfall_mm": round(total_rainfall, 1),
                    "rainy_days": rainy_days,
                    "heavy_rain_days": heavy_rain_days,
                    "daily_forecast": forecast
                },
                "seasonal_info": season_info,
                "rainfall_calendar": rainfall_calendar,
                "risk_assessment": risk_assessment,
                "recommendations": self._get_rainfall_recommendations(total_rainfall, rainy_days, season_info)
            }
            
        except Exception as e:
            logger.error(f"Error getting rainfall prediction: {str(e)}")
            return {}
    
    async def get_weather_forecast(self, latitude: float, longitude: float, days: int = 7) -> List[Dict[str, Any]]:
        """Get detailed weather forecast for given coordinates"""
        try:
            url = f"{self.base_url}/forecast"
            params = {
                "lat": latitude,
                "lon": longitude,
                "appid": self.api_key,
                "units": "metric",
                "cnt": min(days * 8, 40)  # Max 40 forecasts (5 days)
            }
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            # Group by day and get daily summaries
            daily_forecasts = {}
            
            for item in data["list"]:
                dt = datetime.fromtimestamp(item["dt"])
                date_key = dt.date()
                
                if date_key not in daily_forecasts:
                    daily_forecasts[date_key] = {
                        "date": dt,
                        "temperatures": [],
                        "humidity": [],
                        "precipitation": 0,
                        "wind_speeds": [],
                        "conditions": [],
                        "descriptions": []
                    }
                
                daily_forecasts[date_key]["temperatures"].append(item["main"]["temp"])
                daily_forecasts[date_key]["humidity"].append(item["main"]["humidity"])
                daily_forecasts[date_key]["precipitation"] += item.get("rain", {}).get("3h", 0)
                daily_forecasts[date_key]["wind_speeds"].append(item["wind"]["speed"] * 3.6)
                daily_forecasts[date_key]["conditions"].append(item["weather"][0]["main"])
                daily_forecasts[date_key]["descriptions"].append(item["weather"][0]["description"])
            
            # Convert to final format
            forecast = []
            for date_key in sorted(daily_forecasts.keys())[:days]:
                day_data = daily_forecasts[date_key]
                
                forecast.append({
                    "date": day_data["date"],
                    "temperature_max": max(day_data["temperatures"]),
                    "temperature_min": min(day_data["temperatures"]),
                    "temperature_avg": sum(day_data["temperatures"]) / len(day_data["temperatures"]),
                    "humidity": sum(day_data["humidity"]) / len(day_data["humidity"]),
                    "precipitation": day_data["precipitation"],
                    "wind_speed": max(day_data["wind_speeds"]),
                    "condition": max(set(day_data["conditions"]), key=day_data["conditions"].count),
                    "description": max(set(day_data["descriptions"]), key=day_data["descriptions"].count)
                })
            
            return forecast
            
        except Exception as e:
            logger.error(f"Error fetching weather forecast: {str(e)}")
            return []
    
    async def check_weather_alerts(self, latitude: float, longitude: float, user_id: int, phone_number: str, language: str = "en") -> List[Dict[str, Any]]:
        """Check for weather alerts and send SMS notifications"""
        try:
            current_weather = await self.get_current_weather(latitude, longitude)
            forecast = await self.get_weather_forecast(latitude, longitude, 3)
            
            alerts = []
            
            # Check current conditions
            if current_weather:
                # High temperature alert
                if current_weather["temperature"] > self.alert_thresholds["high_temperature"]:
                    alerts.append({
                        "type": "high_temperature",
                        "severity": "warning",
                        "title": "High Temperature Alert",
                        "message": f"Temperature is {current_weather['temperature']:.1f}°C. Protect crops from heat stress.",
                        "recommendations": [
                            "Increase irrigation frequency",
                            "Provide shade for sensitive crops",
                            "Harvest early morning or evening",
                            "Avoid field work during peak hours"
                        ],
                        "valid_until": datetime.utcnow() + timedelta(hours=6)
                    })
                
                # Low temperature/frost alert
                if current_weather["temperature"] < self.alert_thresholds["low_temperature"]:
                    alerts.append({
                        "type": "frost_warning",
                        "severity": "high",
                        "title": "Frost Warning",
                        "message": f"Temperature is {current_weather['temperature']:.1f}°C. Risk of frost damage.",
                        "recommendations": [
                            "Cover sensitive plants",
                            "Use frost protection methods",
                            "Harvest mature crops if possible",
                            "Light smudge fires if available"
                        ],
                        "valid_until": datetime.utcnow() + timedelta(hours=12)
                    })
                
                # Strong wind alert
                if current_weather["wind_speed"] > self.alert_thresholds["strong_wind"]:
                    alerts.append({
                        "type": "strong_wind",
                        "severity": "warning",
                        "title": "Strong Wind Alert",
                        "message": f"Wind speed is {current_weather['wind_speed']:.1f} km/h. Secure crops and equipment.",
                        "recommendations": [
                            "Secure loose equipment",
                            "Support tall crops",
                            "Delay spraying activities",
                            "Check greenhouse structures"
                        ],
                        "valid_until": datetime.utcnow() + timedelta(hours=6)
                    })
                
                # High humidity alert (disease risk)
                if current_weather["humidity"] > self.alert_thresholds["high_humidity"]:
                    alerts.append({
                        "type": "high_humidity",
                        "severity": "watch",
                        "title": "High Humidity - Disease Risk",
                        "message": f"Humidity is {current_weather['humidity']}%. Increased disease risk.",
                        "recommendations": [
                            "Monitor crops for disease symptoms",
                            "Improve air circulation",
                            "Consider preventive fungicide application",
                            "Avoid overhead irrigation"
                        ],
                        "valid_until": datetime.utcnow() + timedelta(hours=12)
                    })
            
            # Check forecast for upcoming alerts
            for i, day in enumerate(forecast[:3]):
                # Heavy rain alert
                if day["precipitation"] > self.alert_thresholds["heavy_rain"]:
                    alerts.append({
                        "type": "heavy_rain",
                        "severity": "watch",
                        "title": "Heavy Rain Expected",
                        "message": f"Heavy rain ({day['precipitation']:.1f}mm) expected on {day['date'].strftime('%d/%m')}.",
                        "recommendations": [
                            "Ensure proper drainage",
                            "Harvest mature crops",
                            "Protect stored produce",
                            "Postpone spraying activities"
                        ],
                        "valid_until": day['date'] + timedelta(days=1)
                    })
                
                # Extreme temperature forecast
                if day["temperature_max"] > 38:
                    alerts.append({
                        "type": "extreme_heat_forecast",
                        "severity": "warning",
                        "title": "Extreme Heat Forecast",
                        "message": f"Extreme heat ({day['temperature_max']:.1f}°C) expected on {day['date'].strftime('%d/%m')}.",
                        "recommendations": [
                            "Plan irrigation for early morning",
                            "Provide crop shade if possible",
                            "Avoid field work during midday",
                            "Monitor livestock for heat stress"
                        ],
                        "valid_until": day['date'] + timedelta(days=1)
                    })
            
            # Check for drought conditions
            drought_alert = await self._check_drought_conditions(latitude, longitude)
            if drought_alert:
                alerts.append(drought_alert)
            
            # Send SMS alerts for high severity alerts
            high_severity_alerts = [alert for alert in alerts if alert["severity"] in ["warning", "high"]]
            if high_severity_alerts:
                await self.send_weather_alerts(phone_number, high_severity_alerts, language)
            
            return alerts
            
        except Exception as e:
            logger.error(f"Error checking weather alerts: {str(e)}")
            return []
    
    async def send_weather_alerts(self, phone_number: str, alerts: List[Dict[str, Any]], language: str = "en") -> bool:
        """Send weather alerts via SMS"""
        try:
            if not alerts:
                return True
            
            # Create alert message
            alert_message = self._create_alert_message(alerts, language)
            
            # Send SMS
            return await sms_service.send_sms(phone_number, alert_message, language)
            
        except Exception as e:
            logger.error(f"Error sending weather alerts: {str(e)}")
            return False
    
    def _find_nearby_stations(self, latitude: float, longitude: float, radius_km: int) -> List[Dict[str, Any]]:
        """Find weather stations within specified radius"""
        nearby_stations = []
        user_location = (latitude, longitude)
        
        for country, stations in self.weather_stations.items():
            for station in stations:
                station_location = (station["lat"], station["lon"])
                distance = geodesic(user_location, station_location).kilometers
                
                if distance <= radius_km:
                    station_copy = station.copy()
                    station_copy["distance_km"] = distance
                    nearby_stations.append(station_copy)
        
        # Sort by distance
        nearby_stations.sort(key=lambda x: x["distance_km"])
        return nearby_stations[:5]  # Return closest 5 stations
    
    def _calculate_micro_climate(self, current_weather: Dict[str, Any], station_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate micro-climate adjustments based on nearby stations"""
        if not station_data or not current_weather:
            return current_weather
        
        # Weight stations by inverse distance
        total_weight = 0
        weighted_temp = 0
        weighted_humidity = 0
        weighted_wind = 0
        
        for station in station_data:
            weight = 1 / (station["distance_km"] + 1)  # +1 to avoid division by zero
            total_weight += weight
            weighted_temp += station["temperature"] * weight
            weighted_humidity += station["humidity"] * weight
            weighted_wind += station["wind_speed"] * weight
        
        if total_weight > 0:
            avg_temp = weighted_temp / total_weight
            avg_humidity = weighted_humidity / total_weight
            avg_wind = weighted_wind / total_weight
            
            # Calculate adjustments (30% weight to nearby stations)
            temp_adjustment = (avg_temp - current_weather.get("temperature", avg_temp)) * 0.3
            humidity_adjustment = (avg_humidity - current_weather.get("humidity", avg_humidity)) * 0.3
            wind_adjustment = (avg_wind - current_weather.get("wind_speed", avg_wind)) * 0.3
            
            return {
                "adjusted_temperature": current_weather.get("temperature", 0) + temp_adjustment,
                "adjusted_humidity": current_weather.get("humidity", 0) + humidity_adjustment,
                "adjusted_wind_speed": current_weather.get("wind_speed", 0) + wind_adjustment,
                "confidence": min(len(station_data) * 20, 100),  # Confidence based on station count
                "adjustment_factors": {
                    "temperature": temp_adjustment,
                    "humidity": humidity_adjustment,
                    "wind_speed": wind_adjustment
                },
                "base_weather": current_weather
            }
        
        return current_weather
    
    def _get_seasonal_info(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Get seasonal information based on location"""
        current_month = datetime.now().month
        
        # East African seasons (simplified)
        if -5 <= latitude <= 5:  # Equatorial region
            if 3 <= current_month <= 5:
                season = "long_rains"
                description = "Long rains season (March-May)"
                planting_window = "Optimal planting time for main season crops"
            elif 10 <= current_month <= 12:
                season = "short_rains"
                description = "Short rains season (October-December)"
                planting_window = "Good for quick-maturing crops"
            elif 6 <= current_month <= 9:
                season = "dry_season"
                description = "Dry season (June-September)"
                planting_window = "Irrigation required for most crops"
            else:
                season = "transition"
                description = "Transition period"
                planting_window = "Monitor weather closely"
        else:
            # Simplified for other regions
            if 11 <= current_month or current_month <= 3:
                season = "wet_season"
                description = "Wet season"
                planting_window = "Good for rain-fed crops"
            else:
                season = "dry_season"
                description = "Dry season"
                planting_window = "Irrigation recommended"
        
        return {
            "current_season": season,
            "description": description,
            "month": current_month,
            "planting_window": planting_window,
            "optimal_crops": self._get_seasonal_crops(season)
        }
    
    def _get_seasonal_crops(self, season: str) -> List[str]:
        """Get optimal crops for current season"""
        crop_calendar = {
            "long_rains": ["maize", "beans", "sorghum", "millet", "cassava", "sweet_potato"],
            "short_rains": ["maize", "beans", "vegetables", "legumes", "cowpeas"],
            "dry_season": ["irrigation_crops", "vegetables", "fruits", "tomatoes"],
            "wet_season": ["rice", "maize", "beans", "vegetables", "bananas"],
            "transition": ["vegetables", "legumes", "quick_maturing_crops"]
        }
        
        return crop_calendar.get(season, ["vegetables"])
    
    def _generate_rainfall_calendar(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Generate rainfall calendar for the location"""
        # Simplified rainfall calendar for East Africa
        calendar = {
            "january": {"rainfall_mm": 60, "description": "Moderate rains", "farming_activity": "Land preparation"},
            "february": {"rainfall_mm": 40, "description": "Light rains", "farming_activity": "Planting preparation"},
            "march": {"rainfall_mm": 120, "description": "Long rains begin", "farming_activity": "Main season planting"},
            "april": {"rainfall_mm": 200, "description": "Peak long rains", "farming_activity": "Crop management"},
            "may": {"rainfall_mm": 150, "description": "Long rains end", "farming_activity": "Weeding and fertilizing"},
            "june": {"rainfall_mm": 30, "description": "Dry season", "farming_activity": "Irrigation if needed"},
            "july": {"rainfall_mm": 20, "description": "Dry season", "farming_activity": "Pest control"},
            "august": {"rainfall_mm": 25, "description": "Dry season", "farming_activity": "Harvesting"},
            "september": {"rainfall_mm": 35, "description": "Dry season", "farming_activity": "Post-harvest activities"},
            "october": {"rainfall_mm": 80, "description": "Short rains begin", "farming_activity": "Second season planting"},
            "november": {"rainfall_mm": 120, "description": "Peak short rains", "farming_activity": "Crop management"},
            "december": {"rainfall_mm": 90, "description": "Short rains end", "farming_activity": "Harvesting"}
        }
        
        return calendar
    
    def _assess_weather_risks(self, forecast: List[Dict[str, Any]], season_info: Dict[str, Any]) -> Dict[str, Any]:
        """Assess drought and flood risks"""
        total_rainfall = sum(day.get("precipitation", 0) for day in forecast)
        max_daily_rain = max((day.get("precipitation", 0) for day in forecast), default=0)
        consecutive_dry_days = 0
        max_dry_streak = 0
        
        for day in forecast:
            if day.get("precipitation", 0) < 1:
                consecutive_dry_days += 1
                max_dry_streak = max(max_dry_streak, consecutive_dry_days)
            else:
                consecutive_dry_days = 0
        
        # Risk assessment
        drought_risk = "low"
        flood_risk = "low"
        
        if total_rainfall < 10:
            drought_risk = "high"
        elif total_rainfall < 25:
            drought_risk = "medium"
        
        if max_daily_rain > 75:
            flood_risk = "high"
        elif max_daily_rain > 40:
            flood_risk = "medium"
        
        return {
            "drought_risk": drought_risk,
            "flood_risk": flood_risk,
            "total_rainfall_14_days": total_rainfall,
            "max_daily_rainfall": max_daily_rain,
            "max_dry_streak_days": max_dry_streak,
            "risk_factors": {
                "seasonal_context": season_info["current_season"],
                "rainfall_deficit": max(0, 50 - total_rainfall),  # Expected vs actual
                "extreme_weather_events": max_daily_rain > 50 or max_dry_streak > 7
            }
        }
    
    def _get_rainfall_recommendations(self, total_rainfall: float, rainy_days: int, season_info: Dict[str, Any]) -> List[str]:
        """Get rainfall-based recommendations"""
        recommendations = []
        
        if total_rainfall < 20:
            recommendations.extend([
                "Consider irrigation for water-sensitive crops",
                "Plant drought-resistant varieties",
                "Mulch to conserve soil moisture",
                "Harvest rainwater if possible"
            ])
        elif total_rainfall > 100:
            recommendations.extend([
                "Ensure proper field drainage",
                "Monitor for fungal diseases",
                "Delay harvesting if possible",
                "Protect stored produce from moisture"
            ])
        else:
            recommendations.append("Rainfall levels are adequate for most crops")
        
        if season_info["current_season"] == "long_rains":
            recommendations.append("Optimal time for planting main season crops")
        elif season_info["current_season"] == "short_rains":
            recommendations.append("Good time for quick-maturing crops")
        elif season_info["current_season"] == "dry_season":
            recommendations.append("Focus on irrigation and water conservation")
        
        return recommendations
    
    def _get_agricultural_recommendations(self, weather_data: Dict[str, Any]) -> List[str]:
        """Get agricultural recommendations based on current weather"""
        recommendations = []
        
        if not weather_data:
            return recommendations
        
        temp = weather_data.get("temperature", 0)
        humidity = weather_data.get("humidity", 0)
        wind_speed = weather_data.get("wind_speed", 0)
        
        # Temperature-based recommendations
        if temp > 30:
            recommendations.extend([
                "Irrigate crops early morning or evening",
                "Provide shade for sensitive crops",
                "Monitor livestock for heat stress"
            ])
        elif temp < 15:
            recommendations.extend([
                "Protect sensitive crops from cold",
                "Delay planting of warm-season crops"
            ])
        
        # Humidity-based recommendations
        if humidity > 80:
            recommendations.extend([
                "Monitor for fungal diseases",
                "Improve air circulation around crops"
            ])
        elif humidity < 40:
            recommendations.extend([
                "Increase irrigation frequency",
                "Consider mulching to retain moisture"
            ])
        
        # Wind-based recommendations
        if wind_speed > 20:
            recommendations.extend([
                "Secure loose equipment and structures",
                "Delay spraying activities"
            ])
        
        return recommendations
    
    async def _check_drought_conditions(self, latitude: float, longitude: float) -> Optional[Dict[str, Any]]:
        """Check for drought conditions"""
        try:
            # Get extended forecast
            forecast = await self.get_weather_forecast(latitude, longitude, 14)
            
            total_rain = sum(day.get("precipitation", 0) for day in forecast)
            dry_days = len([day for day in forecast if day.get("precipitation", 0) < 1])
            
            if total_rain < 10 and dry_days > 10:  # Less than 10mm in 14 days with 10+ dry days
                return {
                    "type": "drought_warning",
                    "severity": "high",
                    "title": "Severe Drought Conditions",
                    "message": f"Only {total_rain:.1f}mm rainfall expected in next 14 days with {dry_days} dry days.",
                    "recommendations": [
                        "Implement emergency water conservation",
                        "Consider drought-resistant crops for next season",
                        "Monitor soil moisture levels daily",
                        "Reduce livestock numbers if necessary"
                    ],
                    "valid_until": datetime.utcnow() + timedelta(days=14)
                }
            elif total_rain < 25:  # Less than 25mm in 14 days
                return {
                    "type": "drought_watch",
                    "severity": "watch",
                    "title": "Drought Conditions Developing",
                    "message": f"Low rainfall expected ({total_rain:.1f}mm) in next 14 days.",
                    "recommendations": [
                        "Implement water conservation measures",
                        "Monitor crop stress indicators",
                        "Prepare irrigation systems",
                        "Consider early harvest if crops are mature"
                    ],
                    "valid_until": datetime.utcnow() + timedelta(days=14)
                }
            
            return None
            
        except Exception as e:
            logger.error(f"Error checking drought conditions: {str(e)}")
            return None
    
    def _create_alert_message(self, alerts: List[Dict[str, Any]], language: str) -> str:
        """Create SMS alert message"""
        if not alerts:
            return ""
        
        messages = {
            "en": "🌤️ WEATHER ALERTS:\n",
            "sw": "🌤️ ONYO LA HALI YA HEWA:\n",
            "am": "🌤️ የአየር ሁኔታ ማስጠንቀቂያ:\n",
            "fr": "🌤️ ALERTES MÉTÉO:\n"
        }
        
        message = messages.get(language, messages["en"])
        
        for i, alert in enumerate(alerts[:2], 1):  # Limit to 2 alerts for SMS length
            message += f"{i}. {alert['title']}: {alert['message']}\n"
            if alert.get('recommendations'):
                message += f"💡 {alert['recommendations'][0]}\n"
        
        if len(alerts) > 2:
            more_text = {
                "en": f"...and {len(alerts) - 2} more alerts. Check app for details.",
                "sw": f"...na onyo {len(alerts) - 2} zaidi. Angalia app kwa maelezo.",
                "am": f"...እና {len(alerts) - 2} ተጨማሪ ማስጠንቀቂያዎች። ለዝርዝር መተግበሪያውን ይመልከቱ።",
                "fr": f"...et {len(alerts) - 2} autres alertes. Vérifiez l'app pour plus de détails."
            }
            message += more_text.get(language, more_text["en"])
        
        return message


# Service instance
enhanced_weather_service = EnhancedWeatherService()