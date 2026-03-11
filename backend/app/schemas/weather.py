from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class WeatherConditionEnum(str, Enum):
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


class AlertSeverityEnum(str, Enum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"
    SEVERE = "severe"
    EXTREME = "extreme"


class AlertTypeEnum(str, Enum):
    DROUGHT = "drought"
    FLOOD = "flood"
    FROST = "frost"
    HAIL = "hail"
    HIGH_WINDS = "high_winds"
    EXTREME_HEAT = "extreme_heat"
    PEST_OUTBREAK = "pest_outbreak"
    DISEASE_RISK = "disease_risk"


# Weather Data Schemas
class WeatherDataBase(BaseModel):
    recorded_at: datetime
    data_source: Optional[str] = None
    temperature_current: Optional[float] = None
    temperature_min: Optional[float] = None
    temperature_max: Optional[float] = None
    feels_like_temperature: Optional[float] = None
    humidity_percentage: Optional[float] = Field(None, ge=0, le=100)
    atmospheric_pressure_hpa: Optional[float] = Field(None, gt=0)
    dew_point: Optional[float] = None
    rainfall_mm: Optional[float] = Field(None, ge=0)
    rainfall_intensity: Optional[str] = None
    precipitation_probability: Optional[float] = Field(None, ge=0, le=100)
    wind_speed_kmh: Optional[float] = Field(None, ge=0)
    wind_direction_degrees: Optional[float] = Field(None, ge=0, lt=360)
    wind_gust_kmh: Optional[float] = Field(None, ge=0)
    solar_radiation_wm2: Optional[float] = Field(None, ge=0)
    uv_index: Optional[float] = Field(None, ge=0)
    visibility_km: Optional[float] = Field(None, ge=0)
    cloud_cover_percentage: Optional[float] = Field(None, ge=0, le=100)
    soil_temperature: Optional[float] = None
    soil_moisture_percentage: Optional[float] = Field(None, ge=0, le=100)
    condition: Optional[WeatherConditionEnum] = None
    condition_description: Optional[str] = None
    evapotranspiration_mm: Optional[float] = Field(None, ge=0)
    growing_degree_days: Optional[float] = Field(None, ge=0)
    chill_hours: Optional[float] = Field(None, ge=0)


class WeatherDataCreate(WeatherDataBase):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    farm_id: Optional[int] = None


class WeatherDataResponse(WeatherDataBase):
    id: int
    farm_id: Optional[int] = None
    latitude: float
    longitude: float
    data_quality_score: Optional[float] = None
    is_interpolated: bool = False
    created_at: datetime

    class Config:
        from_attributes = True


# Weather Forecast Schemas
class WeatherForecastBase(BaseModel):
    forecast_for_date: datetime
    forecast_hours_ahead: Optional[int] = None
    data_source: Optional[str] = None
    model_name: Optional[str] = None
    temperature_min: Optional[float] = None
    temperature_max: Optional[float] = None
    temperature_avg: Optional[float] = None
    rainfall_mm: Optional[float] = Field(None, ge=0)
    precipitation_probability: Optional[float] = Field(None, ge=0, le=100)
    humidity_percentage: Optional[float] = Field(None, ge=0, le=100)
    wind_speed_kmh: Optional[float] = Field(None, ge=0)
    wind_direction_degrees: Optional[float] = Field(None, ge=0, lt=360)
    condition: Optional[WeatherConditionEnum] = None
    condition_description: Optional[str] = None
    confidence_score: Optional[float] = Field(None, ge=0, le=1)
    irrigation_recommendation: Optional[str] = None
    farming_activities_recommendation: Optional[str] = None


class WeatherForecastCreate(WeatherForecastBase):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)


class WeatherForecastResponse(WeatherForecastBase):
    id: int
    latitude: float
    longitude: float
    forecast_date: datetime
    accuracy_score: Optional[float] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Weather Alert Schemas
class WeatherAlertBase(BaseModel):
    alert_type: AlertTypeEnum
    severity: AlertSeverityEnum
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1)
    start_time: datetime
    end_time: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    risk_level: Optional[str] = None
    potential_impact: Optional[str] = None
    affected_crops: Optional[List[str]] = None
    immediate_actions: Optional[str] = None
    preventive_measures: Optional[str] = None
    recovery_actions: Optional[str] = None
    data_source: Optional[str] = None
    verification_status: Optional[str] = None


class WeatherAlertCreate(WeatherAlertBase):
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    affected_area_coordinates: Optional[List[List[float]]] = None
    weather_data_id: Optional[int] = None


class WeatherAlertUpdate(BaseModel):
    is_active: Optional[bool] = None
    is_acknowledged: Optional[bool] = None
    verification_status: Optional[str] = None
    end_time: Optional[datetime] = None


class WeatherAlertResponse(WeatherAlertBase):
    id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    weather_data_id: Optional[int] = None
    is_active: bool
    is_acknowledged: bool
    acknowledged_by: Optional[int] = None
    acknowledged_at: Optional[datetime] = None
    verified_by: Optional[str] = None
    issued_at: datetime
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Weather Notification Schemas
class WeatherNotificationBase(BaseModel):
    notification_type: str
    message: str = Field(..., min_length=1)


class WeatherNotificationCreate(WeatherNotificationBase):
    alert_id: int
    user_id: int


class WeatherNotificationResponse(WeatherNotificationBase):
    id: int
    alert_id: int
    user_id: int
    sent_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    read_at: Optional[datetime] = None
    status: str
    delivery_attempts: int
    last_attempt_at: Optional[datetime] = None
    failure_reason: Optional[str] = None
    is_dismissed: bool
    dismissed_at: Optional[datetime] = None
    user_response: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Climate Data Schemas
class ClimateDataBase(BaseModel):
    year: int = Field(..., ge=1900, le=2100)
    month: Optional[int] = Field(None, ge=1, le=12)
    avg_temperature: Optional[float] = None
    min_temperature: Optional[float] = None
    max_temperature: Optional[float] = None
    temperature_range: Optional[float] = None
    total_rainfall_mm: Optional[float] = Field(None, ge=0)
    avg_monthly_rainfall: Optional[float] = Field(None, ge=0)
    max_daily_rainfall: Optional[float] = Field(None, ge=0)
    rainy_days_count: Optional[int] = Field(None, ge=0)
    avg_humidity_percentage: Optional[float] = Field(None, ge=0, le=100)
    avg_wind_speed_kmh: Optional[float] = Field(None, ge=0)
    predominant_wind_direction: Optional[float] = Field(None, ge=0, lt=360)
    growing_season_length_days: Optional[int] = Field(None, ge=0)
    frost_free_days: Optional[int] = Field(None, ge=0)
    heat_stress_days: Optional[int] = Field(None, ge=0)
    drought_stress_days: Optional[int] = Field(None, ge=0)
    extreme_heat_events: Optional[int] = Field(None, ge=0)
    extreme_cold_events: Optional[int] = Field(None, ge=0)
    heavy_rainfall_events: Optional[int] = Field(None, ge=0)
    drought_periods: Optional[int] = Field(None, ge=0)
    storm_events: Optional[int] = Field(None, ge=0)
    data_source: Optional[str] = None
    data_completeness_percentage: Optional[float] = Field(None, ge=0, le=100)


class ClimateDataCreate(ClimateDataBase):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)


class ClimateDataResponse(ClimateDataBase):
    id: int
    latitude: float
    longitude: float
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Weather Request Schemas
class WeatherForecastRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    days: int = Field(7, ge=1, le=14)
    include_hourly: bool = False
    include_alerts: bool = True


class WeatherHistoryRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    start_date: datetime
    end_date: datetime
    data_source: Optional[str] = None


class WeatherAnalysisRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    analysis_type: str  # seasonal, annual, trend, comparison
    period_years: int = Field(5, ge=1, le=30)
    crop_type: Optional[str] = None


# Weather Analysis Response
class WeatherAnalysis(BaseModel):
    location: Dict[str, float]  # lat, lng
    analysis_period: str
    temperature_trends: Dict[str, Any]
    rainfall_patterns: Dict[str, Any]
    seasonal_variations: Dict[str, Any]
    extreme_events_frequency: Dict[str, int]
    agricultural_suitability: Dict[str, Any]
    climate_risks: List[str]
    recommendations: List[str]
    confidence_score: float = Field(..., ge=0, le=1)


# Weather Statistics
class WeatherStatistics(BaseModel):
    total_weather_records: int
    latest_update: Optional[datetime] = None
    data_sources: List[str]
    coverage_area_km2: Optional[float] = None
    active_alerts: int
    forecast_accuracy: Optional[float] = None
    average_temperature: Optional[float] = None
    total_rainfall_ytd: Optional[float] = None
    extreme_events_count: int