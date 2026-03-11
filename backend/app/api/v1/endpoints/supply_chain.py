from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db

router = APIRouter()

@router.get("/shipments")
async def get_shipments(db: Session = Depends(get_db)):
    """Get shipment tracking information"""
    return {
        "shipments": [
            {
                "id": 1,
                "tracking_id": "SHIP-2024-001",
                "product": "Maize",
                "quantity": "2 tons",
                "origin": "Green Valley Farm, Nairobi",
                "destination": "East Africa Grain Company, Mombasa",
                "status": "in_transit",
                "current_location": "Voi, Kenya",
                "estimated_delivery": "2024-01-16T14:00:00Z",
                "driver": {
                    "name": "John Mwangi",
                    "phone": "+254700111222",
                    "vehicle": "KCA 123A"
                },
                "milestones": [
                    {
                        "location": "Green Valley Farm",
                        "timestamp": "2024-01-15T08:00:00Z",
                        "status": "picked_up"
                    },
                    {
                        "location": "Nairobi Checkpoint",
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": "cleared"
                    },
                    {
                        "location": "Voi",
                        "timestamp": "2024-01-15T16:45:00Z",
                        "status": "in_transit"
                    }
                ]
            },
            {
                "id": 2,
                "tracking_id": "SHIP-2024-002",
                "product": "Tomatoes",
                "quantity": "500 kg",
                "origin": "Sunrise Agriculture, Mombasa",
                "destination": "Fresh Produce Market, Nairobi",
                "status": "delivered",
                "current_location": "Fresh Produce Market",
                "delivered_at": "2024-01-14T11:30:00Z",
                "driver": {
                    "name": "Mary Wanjiku",
                    "phone": "+254700333444",
                    "vehicle": "KBZ 456B"
                }
            }
        ]
    }

@router.post("/shipments")
async def create_shipment(db: Session = Depends(get_db)):
    """Create a new shipment"""
    return {
        "shipment_id": "SHIP-2024-003",
        "tracking_id": "SHIP-2024-003",
        "message": "Shipment created successfully",
        "status": "pending_pickup",
        "estimated_pickup": "2024-01-16T09:00:00Z"
    }

@router.get("/shipments/{tracking_id}")
async def track_shipment(tracking_id: str, db: Session = Depends(get_db)):
    """Track a specific shipment"""
    return {
        "tracking_id": tracking_id,
        "product": "Beans",
        "quantity": "1.5 tons",
        "origin": "Happy Farm, Kisumu",
        "destination": "Local Cooperative, Nairobi",
        "status": "picked_up",
        "current_location": "Nakuru",
        "estimated_delivery": "2024-01-17T12:00:00Z",
        "progress": 45,  # percentage
        "driver": {
            "name": "Peter Kiprotich",
            "phone": "+254700555666",
            "vehicle": "KCD 789C"
        },
        "real_time_location": {
            "lat": -0.3031,
            "lng": 36.0800,
            "last_updated": "2024-01-15T18:30:00Z"
        },
        "milestones": [
            {
                "location": "Happy Farm",
                "timestamp": "2024-01-15T07:00:00Z",
                "status": "picked_up",
                "completed": True
            },
            {
                "location": "Kisumu Checkpoint",
                "timestamp": "2024-01-15T09:15:00Z",
                "status": "cleared",
                "completed": True
            },
            {
                "location": "Nakuru",
                "timestamp": "2024-01-15T18:30:00Z",
                "status": "in_transit",
                "completed": True
            },
            {
                "location": "Nairobi Checkpoint",
                "timestamp": null,
                "status": "pending",
                "completed": False
            },
            {
                "location": "Local Cooperative",
                "timestamp": null,
                "status": "pending",
                "completed": False
            }
        ]
    }

@router.get("/logistics")
async def get_logistics_providers(db: Session = Depends(get_db)):
    """Get available logistics providers"""
    return {
        "providers": [
            {
                "id": 1,
                "name": "AgriTransport Kenya",
                "contact": "+254700777888",
                "email": "dispatch@agritransport.co.ke",
                "services": ["Refrigerated transport", "Bulk cargo", "Express delivery"],
                "coverage_areas": ["Nairobi", "Mombasa", "Kisumu", "Nakuru"],
                "vehicle_types": ["Trucks", "Refrigerated vans", "Pickups"],
                "rating": 4.6,
                "price_per_km": 25.0,  # KES
                "insurance_covered": True
            },
            {
                "id": 2,
                "name": "Farm to Market Logistics",
                "contact": "+254700999000",
                "email": "bookings@farmtomarket.co.ke",
                "services": ["Same day delivery", "Scheduled transport", "Storage"],
                "coverage_areas": ["Central Kenya", "Eastern Kenya"],
                "vehicle_types": ["Vans", "Trucks", "Motorcycles"],
                "rating": 4.3,
                "price_per_km": 22.0,  # KES
                "insurance_covered": True
            }
        ]
    }

@router.get("/warehouses")
async def get_warehouses(location: Optional[str] = None, db: Session = Depends(get_db)):
    """Get available warehouses"""
    warehouses = [
        {
            "id": 1,
            "name": "Central Storage Facility",
            "location": "Nairobi",
            "address": "Industrial Area, Nairobi",
            "capacity": "5000 tons",
            "available_space": "1200 tons",
            "storage_types": ["Dry storage", "Cold storage", "Controlled atmosphere"],
            "services": ["Sorting", "Packaging", "Quality control"],
            "rates": {
                "dry_storage": 15.0,  # KES per ton per day
                "cold_storage": 35.0,
                "controlled_atmosphere": 50.0
            },
            "contact": "+254700111333",
            "certifications": ["HACCP", "ISO 22000"]
        },
        {
            "id": 2,
            "name": "Coastal Grain Silo",
            "location": "Mombasa",
            "address": "Port Area, Mombasa",
            "capacity": "10000 tons",
            "available_space": "3500 tons",
            "storage_types": ["Bulk grain storage", "Bagged storage"],
            "services": ["Fumigation", "Moisture control", "Loading/Unloading"],
            "rates": {
                "bulk_storage": 12.0,  # KES per ton per day
                "bagged_storage": 18.0
            },
            "contact": "+254700222444",
            "certifications": ["KEBS", "Port Health"]
        }
    ]
    
    if location:
        warehouses = [w for w in warehouses if location.lower() in w["location"].lower()]
    
    return {"warehouses": warehouses}

@router.post("/warehouses/book")
async def book_warehouse_space(db: Session = Depends(get_db)):
    """Book warehouse space"""
    return {
        "booking_id": "WH-2024-001",
        "message": "Warehouse space booked successfully",
        "warehouse": "Central Storage Facility",
        "space_allocated": "50 tons",
        "booking_period": "30 days",
        "total_cost": 22500,  # KES
        "check_in_date": "2024-01-20T08:00:00Z"
    }

@router.get("/quality-control")
async def get_quality_reports(shipment_id: Optional[str] = None, db: Session = Depends(get_db)):
    """Get quality control reports"""
    return {
        "reports": [
            {
                "id": 1,
                "shipment_id": "SHIP-2024-001",
                "product": "Maize",
                "inspection_date": "2024-01-15T08:30:00Z",
                "inspector": "Jane Mutua",
                "grade": "Grade A",
                "quality_score": 92,
                "parameters": {
                    "moisture_content": 13.5,  # percentage
                    "foreign_matter": 0.8,    # percentage
                    "damaged_kernels": 2.1,   # percentage
                    "test_weight": 78.5       # kg/hl
                },
                "certification": "KEBS Certified",
                "status": "approved",
                "notes": "Excellent quality maize meeting export standards"
            }
        ]
    }