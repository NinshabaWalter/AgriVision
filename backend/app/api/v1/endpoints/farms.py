from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db

router = APIRouter()

@router.get("/")
async def get_farms(db: Session = Depends(get_db)):
    """Get list of farms"""
    return [
        {
            "id": 1,
            "name": "Green Valley Farm",
            "location": {"lat": -1.2921, "lng": 36.8219},
            "size": "10 acres",
            "crops": ["Maize", "Beans", "Tomatoes"],
            "owner": "John Farmer",
            "status": "Active"
        },
        {
            "id": 2,
            "name": "Sunrise Agriculture",
            "location": {"lat": -4.0435, "lng": 39.6682},
            "size": "25 acres",
            "crops": ["Coffee", "Bananas"],
            "owner": "Mary Grower",
            "status": "Active"
        }
    ]

@router.post("/")
async def create_farm(db: Session = Depends(get_db)):
    """Create a new farm"""
    return {
        "id": 3,
        "name": "New Farm",
        "message": "Farm created successfully"
    }

@router.get("/{farm_id}")
async def get_farm(farm_id: int, db: Session = Depends(get_db)):
    """Get farm details"""
    return {
        "id": farm_id,
        "name": "Green Valley Farm",
        "location": {"lat": -1.2921, "lng": 36.8219},
        "size": "10 acres",
        "crops": ["Maize", "Beans", "Tomatoes"],
        "owner": "John Farmer",
        "status": "Active",
        "soil_health": "Good",
        "irrigation": "Drip irrigation",
        "last_harvest": "2024-06-15"
    }

@router.get("/{farm_id}/analytics")
async def get_farm_analytics(farm_id: int, db: Session = Depends(get_db)):
    """Get farm analytics and insights"""
    return {
        "farm_id": farm_id,
        "yield_prediction": {
            "maize": "8 tons/hectare",
            "beans": "2.5 tons/hectare"
        },
        "soil_health_score": 85,
        "weather_risk": "Low",
        "disease_risk": "Medium",
        "recommended_actions": [
            "Apply organic fertilizer",
            "Monitor for leaf blight",
            "Prepare for harvest in 2 weeks"
        ]
    }