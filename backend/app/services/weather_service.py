import requests
import asyncio
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import structlog
from sqlalchemy.orm import Session
from geoalchemy2.functions import ST_DWithin, ST_GeogFromText

from app.config import settings
from app.models.weather import WeatherData, WeatherAlert
from app.models.farm import Farm
from app.services.notification_service import NotificationService

logger = structlog.get_logger()


class WeatherService:
    """Service for weather data and predictions"""
    
    def __init__(self, db: Session):
        self.db = db
        self.notification_service = NotificationService()
    
    async def get_current_weather(self, lat: float, lng: float) -> Dict[str, Any]:
        """Get current weather for location"""
        try:
            url = f"{settings.weather_api_base_url}/weather"
            params = {
                "lat": lat,
                "lon": lng,
                "appid": settings.openweather_api_key,
                "units": "metric"
            }
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            # Store weather data
            weather_data = self.store_weather_data(data, lat, lng, is_forecast=False)
            
            return self.format_weather_response(data, weather_data)
            
        except Exception as e:
            logger.error("Failed to fetch current weather", error=str(e), lat=lat, lng=lng)
            return self.get_cached_weather(lat, lng)
    
    async def get_weather_forecast(self, lat: float, lng: float, days: int = 7) -> List[Dict[str, Any]]:
        """Get weather forecast for location"""
        try:
            url = f"{settings.weather_api_base_url}/forecast"
            params = {
                "lat": lat,
                "lon": lng,
                "appid": settings.openweather_api_key,
                "units": "metric",
                "cnt": days * 8  # 8 forecasts per day (3-hour intervals)
            }
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            # Process and store forecast data
            forecasts = []
            for item in data["list"]:
                weather_data = self.store_weather_data(item, lat, lng, is_forecast=True)
                forecasts.append(self.format_weather_response(item, weather_data))
            
            return forecasts
            
        except Exception as e:
            logger.error("Failed to fetch weather forecast", error=str(e), lat=lat, lng=lng)
            return []
    
    def store_weather_data(self, api_data: Dict, lat: float, lng: float, is_forecast: bool = False) -> WeatherData:
        """Store weather data in database"""
        try:
            # Find nearby farm
            farm = self.find_nearby_farm(lat, lng)
            
            weather_data = WeatherData(
                farm_id=farm.id if farm else None,
                location=f"POINT({lng} {lat})",
                recorded_at=datetime.utcnow(),
                forecast_for=datetime.fromtimestamp(api_data["dt"]) if is_forecast else None,
                temperature_current=api_data["main"]["temp"],
                temperature_min=api_data["main"]["temp_min"],
                temperature_max=api_data["main"]["temp_max"],
                feels_like=api_data["main"]["feels_like"],
                humidity_percentage=api_data["main"]["humidity"],
                pressure_hpa=api_data["main"]["pressure"],
                wind_speed_ms=api_data.get("wind", {}).get("speed", 0),
                wind_direction_degrees=api_data.get("wind", {}).get("deg", 0),
                rainfall_mm=api_data.get("rain", {}).get("1h", 0),
                cloud_cover_percentage=api_data["clouds"]["all"],
                weather_condition=api_data["weather"][0]["main"],
                weather_description=api_data["weather"][0]["description"],
                weather_icon=api_data["weather"][0]["icon"],
                data_source="openweather",
                data_quality="high",
                is_forecast=is_forecast
            )
            
            self.db.add(weather_data)
            self.db.commit()
            self.db.refresh(weather_data)
            
            return weather_data
            
        except Exception as e:
            logger.error("Failed to store weather data", error=str(e))
            self.db.rollback()
            return None
    
    def find_nearby_farm(self, lat: float, lng: float, radius_km: float = 10) -> Optional[Farm]:
        """Find farm within radius of coordinates"""
        try:
            point = f"POINT({lng} {lat})"
            farm = self.db.query(Farm).filter(
                ST_DWithin(
                    Farm.location,
                    ST_GeogFromText(point),
                    radius_km * 1000  # Convert km to meters
                )
            ).first()
            
            return farm
            
        except Exception as e:
            logger.error("Failed to find nearby farm", error=str(e))
            return None
    
    def get_cached_weather(self, lat: float, lng: float) -> Dict[str, Any]:
        """Get cached weather data when API fails"""
        try:
            # Get most recent weather data for location
            point = f"POINT({lng} {lat})"
            weather_data = self.db.query(WeatherData).filter(
                ST_DWithin(
                    WeatherData.location,
                    ST_GeogFromText(point),
                    5000  # 5km radius
                )
            ).order_by(WeatherData.recorded_at.desc()).first()
            
            if weather_data:
                return {
                    "temperature": weather_data.temperature_current,
                    "humidity": weather_data.humidity_percentage,
                    "description": weather_data.weather_description,
                    "cached": True,
                    "last_updated": weather_data.recorded_at.isoformat()
                }
            
        except Exception as e:
            logger.error("Failed to get cached weather", error=str(e))
        
        return {
            "error": "Weather data unavailable",
            "cached": False
        }
    
    def format_weather_response(self, api_data: Dict, weather_data: WeatherData) -> Dict[str, Any]:
        """Format weather data for API response"""
        return {
            "id": weather_data.id if weather_data else None,
            "temperature": api_data["main"]["temp"],
            "temperature_min": api_data["main"]["temp_min"],
            "temperature_max": api_data["main"]["temp_max"],
            "feels_like": api_data["main"]["feels_like"],
            "humidity": api_data["main"]["humidity"],
            "pressure": api_data["main"]["pressure"],
            "wind_speed": api_data.get("wind", {}).get("speed", 0),
            "wind_direction": api_data.get("wind", {}).get("deg", 0),
            "rainfall": api_data.get("rain", {}).get("1h", 0),
            "cloud_cover": api_data["clouds"]["all"],
            "condition": api_data["weather"][0]["main"],
            "description": api_data["weather"][0]["description"],
            "icon": api_data["weather"][0]["icon"],
            "timestamp": datetime.fromtimestamp(api_data["dt"]).isoformat(),
            "data_source": "openweather"
        }
    
    async def check_weather_alerts(self, farm_id: int) -> List[WeatherAlert]:
        """Check for weather alerts for a farm"""
        try:
            farm = self.db.query(Farm).filter(Farm.id == farm_id).first()
            if not farm:
                return []
            
            # Get farm coordinates
            # This would extract lat/lng from farm.location geometry
            # For now, using mock coordinates
            lat, lng = -1.2921, 36.8219  # Nairobi coordinates as example
            
            # Get current weather and forecast
            current_weather = await self.get_current_weather(lat, lng)
            forecast = await self.get_weather_forecast(lat, lng, days=3)
            
            alerts = []
            
            # Check for various weather conditions
            alerts.extend(self.check_temperature_alerts(farm, current_weather, forecast))
            alerts.extend(self.check_rainfall_alerts(farm, current_weather, forecast))
            alerts.extend(self.check_wind_alerts(farm, current_weather, forecast))
            
            # Store alerts in database
            for alert_data in alerts:
                alert = WeatherAlert(**alert_data)
                self.db.add(alert)
            
            self.db.commit()
            
            # Send notifications for high severity alerts
            for alert in alerts:
                if alert.get("severity") in ["high", "extreme"]:
                    await self.notification_service.send_weather_alert(farm.owner, alert)
            
            return alerts
            
        except Exception as e:
            logger.error("Failed to check weather alerts", error=str(e), farm_id=farm_id)
            return []
    
    def check_temperature_alerts(self, farm: Farm, current: Dict, forecast: List[Dict]) -> List[Dict]:
        """Check for temperature-related alerts"""
        alerts = []
        
        # Check for extreme temperatures
        if current.get("temperature", 0) > 35:
            alerts.append({
                "farm_id": farm.id,
                "user_id": farm.owner_id,
                "alert_type": "heat_stress",
                "severity": "high",
                "title": "High Temperature Alert",
                "description": f"Temperature is {current['temperature']}°C. Crops may experience heat stress.",
                "valid_from": datetime.utcnow(),
                "valid_until": datetime.utcnow() + timedelta(hours=6),
                "recommendations": [
                    "Increase irrigation frequency",
                    "Provide shade for sensitive crops",
                    "Avoid field work during peak hours"
                ]
            })
        
        # Check for frost risk
        for day in forecast[:2]:  # Next 2 days
            if day.get("temperature_min", 10) < 5:
                alerts.append({
                    "farm_id": farm.id,
                    "user_id": farm.owner_id,
                    "alert_type": "frost",
                    "severity": "high",
                    "title": "Frost Warning",
                    "description": f"Minimum temperature expected: {day['temperature_min']}°C",
                    "valid_from": datetime.utcnow(),
                    "valid_until": datetime.utcnow() + timedelta(days=1),
                    "recommendations": [
                        "Cover sensitive plants",
                        "Use frost protection methods",
                        "Harvest mature crops if possible"
                    ]
                })
                break
        
        return alerts
    
    def check_rainfall_alerts(self, farm: Farm, current: Dict, forecast: List[Dict]) -> List[Dict]:
        """Check for rainfall-related alerts"""
        alerts = []
        
        # Check for heavy rainfall
        total_rainfall = sum(day.get("rainfall", 0) for day in forecast[:3])
        
        if total_rainfall > 50:  # More than 50mm in 3 days
            alerts.append({
                "farm_id": farm.id,
                "user_id": farm.owner_id,
                "alert_type": "heavy_rain",
                "severity": "medium",
                "title": "Heavy Rainfall Expected",
                "description": f"Expected rainfall: {total_rainfall:.1f}mm over next 3 days",
                "valid_from": datetime.utcnow(),
                "valid_until": datetime.utcnow() + timedelta(days=3),
                "recommendations": [
                    "Ensure proper drainage",
                    "Postpone spraying activities",
                    "Harvest ready crops before rain"
                ]
            })
        
        # Check for drought conditions
        if total_rainfall < 5:  # Less than 5mm in 3 days
            alerts.append({
                "farm_id": farm.id,
                "user_id": farm.owner_id,
                "alert_type": "drought",
                "severity": "medium",
                "title": "Low Rainfall Warning",
                "description": "Very little rainfall expected in the coming days",
                "valid_from": datetime.utcnow(),
                "valid_until": datetime.utcnow() + timedelta(days=3),
                "recommendations": [
                    "Increase irrigation",
                    "Mulch around plants",
                    "Consider drought-resistant varieties"
                ]
            })
        
        return alerts
    
    def check_wind_alerts(self, farm: Farm, current: Dict, forecast: List[Dict]) -> List[Dict]:
        """Check for wind-related alerts"""
        alerts = []
        
        # Check for strong winds
        max_wind = max(day.get("wind_speed", 0) for day in forecast[:2])
        
        if max_wind > 10:  # Wind speed > 10 m/s
            alerts.append({
                "farm_id": farm.id,
                "user_id": farm.owner_id,
                "alert_type": "strong_wind",
                "severity": "medium",
                "title": "Strong Wind Warning",
                "description": f"Wind speeds up to {max_wind:.1f} m/s expected",
                "valid_from": datetime.utcnow(),
                "valid_until": datetime.utcnow() + timedelta(days=1),
                "recommendations": [
                    "Secure loose structures",
                    "Avoid spraying pesticides",
                    "Support tall plants"
                ]
            })
        
        return alerts