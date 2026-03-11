from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db

router = APIRouter()

@router.get("/profile")
async def get_user_profile(db: Session = Depends(get_db)):
    """Get current user profile"""
    return {
        "id": 1,
        "name": "John Farmer",
        "email": "john@example.com",
        "phone": "+254700000000",
        "location": "Nairobi, Kenya",
        "farm_size": "5 acres",
        "crops": ["Maize", "Beans", "Tomatoes"]
    }

@router.put("/profile")
async def update_user_profile(db: Session = Depends(get_db)):
    """Update user profile"""
    return {"message": "Profile updated successfully"}

@router.get("/farmers")
async def get_farmers(db: Session = Depends(get_db)):
    """Get list of farmers"""
    return [
        {
            "id": 1,
            "name": "John Farmer",
            "location": "Nairobi, Kenya",
            "crops": ["Maize", "Beans"]
        },
        {
            "id": 2,
            "name": "Mary Grower",
            "location": "Mombasa, Kenya",
            "crops": ["Tomatoes", "Peppers"]
        }
    ]