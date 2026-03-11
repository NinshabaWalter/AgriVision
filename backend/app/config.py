from pydantic_settings import BaseSettings
from typing import Optional
import os


class Settings(BaseSettings):
    # Database
    database_url: str = "postgresql://user:password@localhost:5432/agri_platform"
    redis_url: str = "redis://localhost:6379/0"
    mongodb_url: str = "mongodb://localhost:27017/agri_platform"
    
    # Security
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Weather API
    openweather_api_key: Optional[str] = None
    weather_api_base_url: str = "https://api.openweathermap.org/data/2.5"
    
    # SMS & Communication
    twilio_account_sid: Optional[str] = None
    twilio_auth_token: Optional[str] = None
    twilio_phone_number: Optional[str] = None
    
    # Email
    sendgrid_api_key: Optional[str] = None
    from_email: str = "noreply@agriplatform.com"
    
    # Cloud Storage
    aws_access_key_id: Optional[str] = None
    aws_secret_access_key: Optional[str] = None
    aws_bucket_name: str = "agri-platform-storage"
    aws_region: str = "us-east-1"
    
    # Machine Learning
    ml_model_path: str = "./ml-models/"
    disease_detection_model: str = "crop_disease_model.h5"
    
    # Market Data
    market_api_base_url: str = "https://api.marketdata.com"
    market_api_key: Optional[str] = None
    
    # Firebase
    firebase_project_id: Optional[str] = None
    firebase_private_key_id: Optional[str] = None
    firebase_private_key: Optional[str] = None
    firebase_client_email: Optional[str] = None
    firebase_client_id: Optional[str] = None
    
    # Environment
    environment: str = "development"
    debug: bool = True
    log_level: str = "INFO"
    
    # Celery
    celery_broker_url: str = "redis://localhost:6379/1"
    celery_result_backend: str = "redis://localhost:6379/2"
    
    # Monitoring
    sentry_dsn: Optional[str] = None
    
    # CORS
    allowed_origins: list = [
        "http://localhost:3000", 
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "http://10.0.2.2:8000",  # Android emulator
        "*"  # Allow all origins in development
    ]
    
    class Config:
        env_file = ".env"
        case_sensitive = False
        extra = "ignore"  # Ignore extra fields from .env file


settings = Settings()