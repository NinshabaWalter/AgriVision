from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db

router = APIRouter()

@router.get("/prices")
async def get_market_prices(crop: Optional[str] = None, location: Optional[str] = None, db: Session = Depends(get_db)):
    """Get current market prices"""
    prices = [
        {
            "crop": "Maize",
            "price_per_kg": 45.50,
            "currency": "KES",
            "location": "Nairobi",
            "market": "Wakulima Market",
            "quality": "Grade A",
            "last_updated": "2024-01-15T08:00:00Z",
            "trend": "up",
            "change_percentage": 2.3
        },
        {
            "crop": "Beans",
            "price_per_kg": 120.00,
            "currency": "KES",
            "location": "Nairobi",
            "market": "Wakulima Market",
            "quality": "Grade A",
            "last_updated": "2024-01-15T08:00:00Z",
            "trend": "stable",
            "change_percentage": 0.1
        },
        {
            "crop": "Tomatoes",
            "price_per_kg": 80.00,
            "currency": "KES",
            "location": "Nairobi",
            "market": "Wakulima Market",
            "quality": "Grade A",
            "last_updated": "2024-01-15T08:00:00Z",
            "trend": "down",
            "change_percentage": -5.2
        }
    ]
    
    if crop:
        prices = [p for p in prices if p["crop"].lower() == crop.lower()]
    if location:
        prices = [p for p in prices if location.lower() in p["location"].lower()]
    
    return {"prices": prices}

@router.get("/buyers")
async def get_buyers(crop: Optional[str] = None, location: Optional[str] = None, db: Session = Depends(get_db)):
    """Get list of buyers"""
    buyers = [
        {
            "id": 1,
            "name": "East Africa Grain Company",
            "contact": "+254700123456",
            "email": "procurement@eagc.com",
            "location": "Nairobi",
            "crops_interested": ["Maize", "Wheat", "Beans"],
            "min_quantity": "10 tons",
            "payment_terms": "30 days",
            "rating": 4.5,
            "verified": True
        },
        {
            "id": 2,
            "name": "Fresh Produce Exporters",
            "contact": "+254700654321",
            "email": "buy@freshexport.com",
            "location": "Mombasa",
            "crops_interested": ["Tomatoes", "Peppers", "Onions"],
            "min_quantity": "5 tons",
            "payment_terms": "15 days",
            "rating": 4.2,
            "verified": True
        }
    ]
    
    if crop:
        buyers = [b for b in buyers if crop in b["crops_interested"]]
    if location:
        buyers = [b for b in buyers if location.lower() in b["location"].lower()]
    
    return {"buyers": buyers}

@router.post("/transactions")
async def create_transaction(db: Session = Depends(get_db)):
    """Record a new transaction"""
    return {
        "id": 1,
        "message": "Transaction recorded successfully",
        "transaction_id": "TXN-2024-001",
        "status": "pending"
    }

@router.get("/transactions")
async def get_transactions(db: Session = Depends(get_db)):
    """Get transaction history"""
    return {
        "transactions": [
            {
                "id": 1,
                "transaction_id": "TXN-2024-001",
                "crop": "Maize",
                "quantity": "2 tons",
                "price_per_kg": 45.50,
                "total_amount": 91000,
                "buyer": "East Africa Grain Company",
                "status": "completed",
                "date": "2024-01-10T10:00:00Z"
            },
            {
                "id": 2,
                "transaction_id": "TXN-2024-002",
                "crop": "Beans",
                "quantity": "500 kg",
                "price_per_kg": 120.00,
                "total_amount": 60000,
                "buyer": "Local Cooperative",
                "status": "pending",
                "date": "2024-01-15T14:30:00Z"
            }
        ]
    }

@router.get("/analytics")
async def get_market_analytics(crop: Optional[str] = None, db: Session = Depends(get_db)):
    """Get market analytics and trends"""
    return {
        "crop": crop or "All crops",
        "analytics": {
            "average_price": 82.17,
            "price_trend": "stable",
            "demand_level": "high",
            "supply_level": "medium",
            "best_selling_season": "March-May",
            "top_markets": ["Nairobi", "Mombasa", "Kisumu"],
            "price_forecast": {
                "next_week": 85.00,
                "next_month": 88.50,
                "confidence": 0.75
            }
        }
    }