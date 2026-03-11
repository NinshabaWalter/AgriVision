from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(
    title="Agricultural Intelligence Platform API",
    description="A comprehensive API for agricultural intelligence platform",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "Agricultural Intelligence Platform API",
        "version": "1.0.0",
        "status": "operational"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Auth endpoints
@app.post("/api/v1/auth/login")
async def login():
    return {
        "access_token": "sample_token_123",
        "token_type": "bearer",
        "user": {
            "id": 1,
            "name": "John Farmer",
            "email": "john@example.com"
        }
    }

@app.post("/api/v1/auth/register")
async def register():
    return {"message": "User registered successfully", "user_id": 1}

# Weather endpoints
@app.get("/api/v1/weather/current")
async def get_current_weather(lat: float = -1.2921, lng: float = 36.8219):
    return {
        "location": {"lat": lat, "lng": lng},
        "temperature": 24.5,
        "humidity": 65,
        "description": "Partly cloudy",
        "timestamp": "2024-01-15T10:30:00Z"
    }

@app.get("/api/v1/weather/forecast")
async def get_weather_forecast(lat: float = -1.2921, lng: float = 36.8219):
    return {
        "location": {"lat": lat, "lng": lng},
        "forecast": [
            {"date": "2024-01-16", "temp_max": 28, "temp_min": 18, "description": "Sunny"},
            {"date": "2024-01-17", "temp_max": 26, "temp_min": 19, "description": "Cloudy"},
            {"date": "2024-01-18", "temp_max": 24, "temp_min": 17, "description": "Rainy"}
        ]
    }

# Disease detection endpoints
@app.post("/api/v1/disease-detection/detect")
async def detect_disease():
    return {
        "disease": "Leaf Blight",
        "confidence": 0.85,
        "recommendations": [
            "Apply fungicide treatment",
            "Improve air circulation",
            "Remove affected leaves"
        ]
    }

# Market endpoints
@app.get("/api/v1/market/prices")
async def get_market_prices():
    return {
        "prices": [
            {"crop": "Maize", "price_per_kg": 45.50, "location": "Nairobi", "trend": "up"},
            {"crop": "Beans", "price_per_kg": 120.00, "location": "Nairobi", "trend": "stable"},
            {"crop": "Tomatoes", "price_per_kg": 80.00, "location": "Nairobi", "trend": "down"}
        ]
    }

# Farm endpoints
@app.get("/api/v1/farms")
async def get_farms():
    return {
        "farms": [
            {
                "id": 1,
                "name": "Green Valley Farm",
                "location": {"lat": -1.2921, "lng": 36.8219},
                "size": "10 acres",
                "crops": ["Maize", "Beans", "Tomatoes"]
            }
        ]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)