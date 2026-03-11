from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float, JSON, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from app.database import Base
import enum


class WeatherCondition(enum.Enum):
    CLEAR = "clear"
    PARTLY_CLOUDY = "partly_cloudy"
    CLOUDY = "cloudy"
    OVERCAST = "overcast"
    LIGHT_RAIN = "light_rain"
    MODERATE_RAIN = "moderate_rain"
    HEAVY_RAIN = "heavy_rain"
    THUNDERSTORM = "thunderstorm"
    FOG = "fog"
    HAIL = "hail"
    SNOW = "snow"


class AlertSeverity(enum.Enum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"
    SEVERE = "severe"
    EXTREME = "extreme"


class AlertType(enum.Enum):
    DROUGHT = "drought"
    FLOOD = "flood"
    FROST = "frost"
    HAIL = "hail"
    HIGH_WINDS = "high_winds"
    EXTREME_HEAT = "extreme_heat"
    PEST_OUTBREAK = "pest_outbreak"
    DISEASE_RISK = "disease_risk"


class WeatherData(Base):
    __tablename__ = "weather_data"
    
    id = Column(Integer, primary_key=True, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id"))
    location = Column(Geometry('POINT'), nullable=False)
    
    # Timestamp
    recorded_at = Column(DateTime, nullable=False)
    data_source = Column(String(100))  # api, sensor, manual, satellite
    
    # Temperature data (Celsius)
    temperature_current = Column(Float)
    temperature_min = Column(Float)
    temperature_max = Column(Float)
    feels_like_temperature = Column(Float)
    
    # Humidity and pressure
    humidity_percentage = Column(Float)
    atmospheric_pressure_hpa = Column(Float)
    dew_point = Column(Float)
    
    # Precipitation
    rainfall_mm = Column(Float, default=0.0)
    rainfall_intensity = Column(String(50))  # light, moderate, heavy
    precipitation_probability = Column(Float)  # 0-100%
    
    # Wind data
    wind_speed_kmh = Column(Float)
    wind_direction_degrees = Column(Float)
    wind_gust_kmh = Column(Float)
    
    # Solar and visibility
    solar_radiation_wm2 = Column(Float)
    uv_index = Column(Float)
    visibility_km = Column(Float)
    cloud_cover_percentage = Column(Float)
    
    # Soil conditions (if available from sensors)
    soil_temperature = Column(Float)
    soil_moisture_percentage = Column(Float)
    
    # Weather condition
    condition = Column(Enum(WeatherCondition))
    condition_description = Column(String(200))
    
    # Agricultural indices
    evapotranspiration_mm = Column(Float)
    growing_degree_days = Column(Float)
    chill_hours = Column(Float)
    
    # Data quality
    data_quality_score = Column(Float)  # 0-1, 1 being highest quality
    is_interpolated = Column(Boolean, default=False)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    farm = relationship("Farm", back_populates="weather_data")
    alerts = relationship("WeatherAlert", back_populates="weather_data")


class WeatherForecast(Base):
    __tablename__ = "weather_forecasts"
    
    id = Column(Integer, primary_key=True, index=True)
    location = Column(Geometry('POINT'), nullable=False)
    
    # Forecast details
    forecast_date = Column(DateTime, nullable=False)
    forecast_for_date = Column(DateTime, nullable=False)
    forecast_hours_ahead = Column(Integer)
    data_source = Column(String(100))
    model_name = Column(String(100))
    
    # Temperature forecast
    temperature_min = Column(Float)
    temperature_max = Column(Float)
    temperature_avg = Column(Float)
    
    # Precipitation forecast
    rainfall_mm = Column(Float, default=0.0)
    precipitation_probability = Column(Float)
    
    # Other conditions
    humidity_percentage = Column(Float)
    wind_speed_kmh = Column(Float)
    wind_direction_degrees = Column(Float)
    condition = Column(Enum(WeatherCondition))
    condition_description = Column(String(200))
    
    # Confidence and accuracy
    confidence_score = Column(Float)  # 0-1
    accuracy_score = Column(Float)  # Filled after actual data is available
    
    # Agricultural relevance
    irrigation_recommendation = Column(String(200))
    farming_activities_recommendation = Column(Text)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())


class WeatherAlert(Base):
    __tablename__ = "weather_alerts"
    
    id = Column(Integer, primary_key=True, index=True)
    weather_data_id = Column(Integer, ForeignKey("weather_data.id"))
    
    # Alert details
    alert_type = Column(Enum(AlertType), nullable=False)
    severity = Column(Enum(AlertSeverity), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    
    # Geographic scope
    location = Column(Geometry('POINT'))
    affected_area = Column(Geometry('POLYGON'))
    
    # Timing
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime)
    issued_at = Column(DateTime, nullable=False)
    expires_at = Column(DateTime)
    
    # Impact assessment
    risk_level = Column(String(50))
    potential_impact = Column(Text)
    affected_crops = Column(JSON)  # List of crop types that might be affected
    
    # Recommendations
    immediate_actions = Column(Text)
    preventive_measures = Column(Text)
    recovery_actions = Column(Text)
    
    # Alert management
    is_active = Column(Boolean, default=True)
    is_acknowledged = Column(Boolean, default=False)
    acknowledged_by = Column(Integer, ForeignKey("users.id"))
    acknowledged_at = Column(DateTime)
    
    # Source and verification
    data_source = Column(String(100))
    verification_status = Column(String(50))  # unverified, verified, false_alarm
    verified_by = Column(String(100))
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    weather_data = relationship("WeatherData", back_populates="alerts")
    acknowledged_user = relationship("User", foreign_keys=[acknowledged_by])
    notifications = relationship("WeatherNotification", back_populates="alert")


class WeatherNotification(Base):
    __tablename__ = "weather_notifications"
    
    id = Column(Integer, primary_key=True, index=True)
    alert_id = Column(Integer, ForeignKey("weather_alerts.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Notification details
    notification_type = Column(String(50))  # sms, email, push, in_app
    message = Column(Text, nullable=False)
    
    # Delivery status
    sent_at = Column(DateTime)
    delivered_at = Column(DateTime)
    read_at = Column(DateTime)
    status = Column(String(50), default="pending")  # pending, sent, delivered, failed, read
    
    # Delivery attempts
    delivery_attempts = Column(Integer, default=0)
    last_attempt_at = Column(DateTime)
    failure_reason = Column(String(200))
    
    # User interaction
    is_dismissed = Column(Boolean, default=False)
    dismissed_at = Column(DateTime)
    user_response = Column(String(200))  # acknowledged, ignored, action_taken
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    alert = relationship("WeatherAlert", back_populates="notifications")
    user = relationship("User")


class ClimateData(Base):
    __tablename__ = "climate_data"
    
    id = Column(Integer, primary_key=True, index=True)
    location = Column(Geometry('POINT'), nullable=False)
    
    # Time period
    year = Column(Integer, nullable=False)
    month = Column(Integer)  # NULL for annual data
    
    # Temperature statistics (Celsius)
    avg_temperature = Column(Float)
    min_temperature = Column(Float)
    max_temperature = Column(Float)
    temperature_range = Column(Float)
    
    # Precipitation statistics
    total_rainfall_mm = Column(Float)
    avg_monthly_rainfall = Column(Float)
    max_daily_rainfall = Column(Float)
    rainy_days_count = Column(Integer)
    
    # Humidity and other conditions
    avg_humidity_percentage = Column(Float)
    avg_wind_speed_kmh = Column(Float)
    predominant_wind_direction = Column(Float)
    
    # Agricultural metrics
    growing_season_length_days = Column(Integer)
    frost_free_days = Column(Integer)
    heat_stress_days = Column(Integer)  # Days above crop-specific threshold
    drought_stress_days = Column(Integer)
    
    # Extreme events count
    extreme_heat_events = Column(Integer)
    extreme_cold_events = Column(Integer)
    heavy_rainfall_events = Column(Integer)
    drought_periods = Column(Integer)
    storm_events = Column(Integer)
    
    # Data source and quality
    data_source = Column(String(100))
    data_completeness_percentage = Column(Float)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())