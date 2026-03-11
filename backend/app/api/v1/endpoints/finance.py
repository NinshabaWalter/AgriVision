from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db

router = APIRouter()

@router.get("/loans")
async def get_available_loans(db: Session = Depends(get_db)):
    """Get available loan products"""
    return {
        "loans": [
            {
                "id": 1,
                "name": "Crop Production Loan",
                "provider": "Agricultural Finance Corporation",
                "amount_range": {"min": 50000, "max": 2000000},
                "interest_rate": 12.5,
                "term_months": 12,
                "requirements": [
                    "Valid ID",
                    "Farm ownership documents",
                    "Crop insurance"
                ],
                "processing_time": "7-14 days",
                "collateral_required": True
            },
            {
                "id": 2,
                "name": "Equipment Finance",
                "provider": "Kenya Commercial Bank",
                "amount_range": {"min": 100000, "max": 5000000},
                "interest_rate": 14.0,
                "term_months": 36,
                "requirements": [
                    "Business registration",
                    "Financial statements",
                    "Equipment quotation"
                ],
                "processing_time": "14-21 days",
                "collateral_required": True
            },
            {
                "id": 3,
                "name": "Microfinance Loan",
                "provider": "Faulu Microfinance",
                "amount_range": {"min": 10000, "max": 500000},
                "interest_rate": 18.0,
                "term_months": 6,
                "requirements": [
                    "Group membership",
                    "Valid ID",
                    "Business plan"
                ],
                "processing_time": "3-5 days",
                "collateral_required": False
            }
        ]
    }

@router.post("/loans/apply")
async def apply_for_loan(db: Session = Depends(get_db)):
    """Apply for a loan"""
    return {
        "application_id": "LOAN-2024-001",
        "message": "Loan application submitted successfully",
        "status": "under_review",
        "next_steps": [
            "Upload required documents",
            "Wait for initial review (3-5 days)",
            "Attend interview if shortlisted"
        ]
    }

@router.get("/loans/applications")
async def get_loan_applications(db: Session = Depends(get_db)):
    """Get user's loan applications"""
    return {
        "applications": [
            {
                "id": 1,
                "application_id": "LOAN-2024-001",
                "loan_type": "Crop Production Loan",
                "amount": 500000,
                "status": "approved",
                "applied_date": "2024-01-05T10:00:00Z",
                "decision_date": "2024-01-12T15:30:00Z",
                "disbursement_date": "2024-01-15T09:00:00Z"
            },
            {
                "id": 2,
                "application_id": "LOAN-2024-002",
                "loan_type": "Equipment Finance",
                "amount": 1200000,
                "status": "under_review",
                "applied_date": "2024-01-10T14:20:00Z",
                "decision_date": null,
                "disbursement_date": null
            }
        ]
    }

@router.get("/insurance")
async def get_insurance_products(db: Session = Depends(get_db)):
    """Get available insurance products"""
    return {
        "products": [
            {
                "id": 1,
                "name": "Crop Insurance",
                "provider": "APA Insurance",
                "coverage": "Weather-related crop losses",
                "premium_rate": 5.5,  # percentage of sum insured
                "max_coverage": 2000000,
                "crops_covered": ["Maize", "Wheat", "Beans", "Rice"],
                "risks_covered": [
                    "Drought",
                    "Excessive rainfall",
                    "Hail",
                    "Frost",
                    "Pest and disease"
                ]
            },
            {
                "id": 2,
                "name": "Livestock Insurance",
                "provider": "Jubilee Insurance",
                "coverage": "Death and theft of livestock",
                "premium_rate": 8.0,
                "max_coverage": 5000000,
                "animals_covered": ["Cattle", "Goats", "Sheep", "Poultry"],
                "risks_covered": [
                    "Disease",
                    "Accident",
                    "Theft",
                    "Natural disasters"
                ]
            }
        ]
    }

@router.post("/insurance/apply")
async def apply_for_insurance(db: Session = Depends(get_db)):
    """Apply for insurance"""
    return {
        "policy_id": "INS-2024-001",
        "message": "Insurance application submitted successfully",
        "status": "pending_assessment",
        "next_steps": [
            "Farm inspection scheduled",
            "Premium calculation",
            "Policy issuance"
        ]
    }

@router.get("/wallet")
async def get_wallet_balance(db: Session = Depends(get_db)):
    """Get user's wallet balance and transactions"""
    return {
        "balance": 125000.50,
        "currency": "KES",
        "recent_transactions": [
            {
                "id": 1,
                "type": "credit",
                "amount": 91000,
                "description": "Maize sale payment",
                "date": "2024-01-10T16:00:00Z",
                "reference": "TXN-2024-001"
            },
            {
                "id": 2,
                "type": "debit",
                "amount": 15000,
                "description": "Fertilizer purchase",
                "date": "2024-01-08T10:30:00Z",
                "reference": "PUR-2024-005"
            },
            {
                "id": 3,
                "type": "credit",
                "amount": 60000,
                "description": "Bean sale payment",
                "date": "2024-01-05T14:20:00Z",
                "reference": "TXN-2024-002"
            }
        ]
    }

@router.get("/savings")
async def get_savings_products(db: Session = Depends(get_db)):
    """Get available savings products"""
    return {
        "products": [
            {
                "id": 1,
                "name": "Farmer Savings Account",
                "provider": "Equity Bank",
                "interest_rate": 6.5,
                "minimum_balance": 1000,
                "features": [
                    "Mobile banking",
                    "No monthly fees",
                    "Seasonal savings plans"
                ]
            },
            {
                "id": 2,
                "name": "Agricultural Fixed Deposit",
                "provider": "Co-operative Bank",
                "interest_rate": 9.0,
                "minimum_balance": 50000,
                "term_months": 12,
                "features": [
                    "Higher interest rates",
                    "Loan against deposit",
                    "Automatic renewal"
                ]
            }
        ]
    }