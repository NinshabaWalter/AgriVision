from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class MarketTypeEnum(str, Enum):
    LOCAL = "local"
    REGIONAL = "regional"
    NATIONAL = "national"
    INTERNATIONAL = "international"
    ONLINE = "online"
    COOPERATIVE = "cooperative"
    AUCTION = "auction"


class PriceTypeEnum(str, Enum):
    WHOLESALE = "wholesale"
    RETAIL = "retail"
    FARM_GATE = "farm_gate"
    EXPORT = "export"
    CONTRACT = "contract"


class TransactionStatusEnum(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    IN_TRANSIT = "in_transit"
    DELIVERED = "delivered"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    DISPUTED = "disputed"


class PaymentStatusEnum(str, Enum):
    PENDING = "pending"
    PARTIAL = "partial"
    COMPLETED = "completed"
    OVERDUE = "overdue"
    FAILED = "failed"


# Market Schemas
class MarketBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    type: MarketTypeEnum
    address: Optional[str] = None
    country: Optional[str] = None
    region: Optional[str] = None
    district: Optional[str] = None
    operating_days: Optional[List[str]] = None
    operating_hours: Optional[str] = None
    seasonal_operation: bool = False
    peak_seasons: Optional[List[str]] = None
    has_storage_facilities: bool = False
    has_processing_facilities: bool = False
    has_cold_storage: bool = False
    has_grading_facilities: bool = False
    has_packaging_facilities: bool = False
    provides_transport: bool = False
    provides_credit: bool = False
    provides_insurance: bool = False
    provides_quality_testing: bool = False
    average_daily_volume_kg: Optional[float] = Field(None, ge=0)
    number_of_vendors: Optional[int] = Field(None, ge=0)
    primary_crops_traded: Optional[List[str]] = None
    contact_person: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None


class MarketCreate(MarketBase):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)


class MarketUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    type: Optional[MarketTypeEnum] = None
    operating_days: Optional[List[str]] = None
    operating_hours: Optional[str] = None
    has_storage_facilities: Optional[bool] = None
    has_processing_facilities: Optional[bool] = None
    has_cold_storage: Optional[bool] = None
    provides_transport: Optional[bool] = None
    provides_credit: Optional[bool] = None
    average_daily_volume_kg: Optional[float] = Field(None, ge=0)
    number_of_vendors: Optional[int] = Field(None, ge=0)
    primary_crops_traded: Optional[List[str]] = None
    contact_person: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None


class MarketResponse(MarketBase):
    id: int
    latitude: float
    longitude: float
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Market Price Schemas
class MarketPriceBase(BaseModel):
    crop_name: str = Field(..., min_length=1, max_length=200)
    variety: Optional[str] = None
    grade: Optional[str] = None
    price_per_kg: float = Field(..., gt=0)
    price_type: PriceTypeEnum
    currency: str = Field("KES", min_length=3, max_length=3)
    supply_level: Optional[str] = None
    demand_level: Optional[str] = None
    quality_available: Optional[str] = None
    volume_traded_kg: Optional[float] = Field(None, ge=0)
    price_trend: Optional[str] = None
    price_change_percentage: Optional[float] = None
    is_peak_season: bool = False
    seasonal_factor: Optional[float] = Field(None, gt=0)
    data_source: Optional[str] = None
    reliability_score: Optional[float] = Field(None, ge=0, le=1)
    sample_size: Optional[int] = Field(None, ge=1)
    price_date: datetime


class MarketPriceCreate(MarketPriceBase):
    market_id: int


class MarketPriceUpdate(BaseModel):
    price_per_kg: Optional[float] = Field(None, gt=0)
    supply_level: Optional[str] = None
    demand_level: Optional[str] = None
    quality_available: Optional[str] = None
    volume_traded_kg: Optional[float] = Field(None, ge=0)
    price_trend: Optional[str] = None
    price_change_percentage: Optional[float] = None


class MarketPriceResponse(MarketPriceBase):
    id: int
    market_id: int
    valid_until: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Buyer Schemas
class BuyerBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    type: Optional[str] = None
    contact_person: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None
    business_registration: Optional[str] = None
    tax_id: Optional[str] = None
    license_number: Optional[str] = None
    preferred_crops: Optional[List[str]] = None
    quality_requirements: Optional[Dict[str, Any]] = None
    volume_requirements: Optional[Dict[str, Any]] = None
    payment_terms: Optional[str] = None
    payment_methods: Optional[List[str]] = None
    credit_limit: Optional[float] = Field(None, ge=0)
    provides_transport: bool = False
    transport_capacity_kg: Optional[float] = Field(None, ge=0)
    delivery_radius_km: Optional[float] = Field(None, ge=0)


class BuyerCreate(BuyerBase):
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    preferred_markets_ids: Optional[List[int]] = None


class BuyerUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    type: Optional[str] = None
    contact_person: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    preferred_crops: Optional[List[str]] = None
    quality_requirements: Optional[Dict[str, Any]] = None
    payment_terms: Optional[str] = None
    credit_limit: Optional[float] = Field(None, ge=0)
    provides_transport: Optional[bool] = None
    transport_capacity_kg: Optional[float] = Field(None, ge=0)


class BuyerResponse(BuyerBase):
    id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    payment_history_score: Optional[float] = None
    reliability_rating: Optional[float] = None
    payment_punctuality_rating: Optional[float] = None
    communication_rating: Optional[float] = None
    overall_rating: Optional[float] = None
    total_transactions: int
    is_active: bool
    is_verified: bool
    verification_date: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Market Transaction Schemas
class MarketTransactionBase(BaseModel):
    crop_name: str = Field(..., min_length=1, max_length=200)
    variety: Optional[str] = None
    grade: Optional[str] = None
    quantity_kg: float = Field(..., gt=0)
    price_per_kg: float = Field(..., gt=0)
    currency: str = Field("KES", min_length=3, max_length=3)
    moisture_content: Optional[float] = Field(None, ge=0, le=100)
    foreign_matter_percentage: Optional[float] = Field(None, ge=0, le=100)
    damage_percentage: Optional[float] = Field(None, ge=0, le=100)
    quality_grade: Optional[str] = None
    quality_test_results: Optional[Dict[str, Any]] = None
    payment_terms: Optional[str] = None
    delivery_terms: Optional[str] = None
    delivery_date: Optional[datetime] = None
    delivery_location: Optional[str] = None
    transport_arranged_by: Optional[str] = None
    transport_cost: Optional[float] = Field(None, ge=0)
    packaging_cost: Optional[float] = Field(None, ge=0)
    handling_cost: Optional[float] = Field(None, ge=0)


class MarketTransactionCreate(MarketTransactionBase):
    buyer_id: int
    market_id: Optional[int] = None


class MarketTransactionUpdate(BaseModel):
    status: Optional[TransactionStatusEnum] = None
    payment_status: Optional[PaymentStatusEnum] = None
    actual_delivery_date: Optional[datetime] = None
    payment_received_date: Optional[datetime] = None
    seller_rating: Optional[float] = Field(None, ge=1, le=5)
    buyer_rating: Optional[float] = Field(None, ge=1, le=5)
    seller_feedback: Optional[str] = None
    buyer_feedback: Optional[str] = None
    has_dispute: Optional[bool] = None
    dispute_reason: Optional[str] = None


class MarketTransactionResponse(MarketTransactionBase):
    id: int
    seller_id: int
    buyer_id: int
    market_id: Optional[int] = None
    total_amount: float
    status: TransactionStatusEnum
    payment_status: PaymentStatusEnum
    transaction_date: datetime
    expected_delivery_date: Optional[datetime] = None
    actual_delivery_date: Optional[datetime] = None
    payment_due_date: Optional[datetime] = None
    payment_received_date: Optional[datetime] = None
    contract_document_url: Optional[str] = None
    quality_certificate_url: Optional[str] = None
    delivery_receipt_url: Optional[str] = None
    payment_receipt_url: Optional[str] = None
    seller_rating: Optional[float] = None
    buyer_rating: Optional[float] = None
    seller_feedback: Optional[str] = None
    buyer_feedback: Optional[str] = None
    has_dispute: bool
    dispute_reason: Optional[str] = None
    dispute_resolution: Optional[str] = None
    dispute_resolved_date: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Buyer Review Schemas
class BuyerReviewBase(BaseModel):
    overall_rating: float = Field(..., ge=1, le=5)
    payment_punctuality: Optional[float] = Field(None, ge=1, le=5)
    communication: Optional[float] = Field(None, ge=1, le=5)
    reliability: Optional[float] = Field(None, ge=1, le=5)
    fairness: Optional[float] = Field(None, ge=1, le=5)
    title: Optional[str] = Field(None, max_length=200)
    review_text: Optional[str] = None
    pros: Optional[List[str]] = None
    cons: Optional[List[str]] = None
    would_trade_again: Optional[bool] = None
    recommended_for: Optional[List[str]] = None
    is_anonymous: bool = False


class BuyerReviewCreate(BuyerReviewBase):
    buyer_id: int
    transaction_id: Optional[int] = None


class BuyerReviewResponse(BuyerReviewBase):
    id: int
    buyer_id: int
    reviewer_id: int
    transaction_id: Optional[int] = None
    is_verified: bool
    helpful_votes: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Price Alert Schemas
class PriceAlertBase(BaseModel):
    crop_name: str = Field(..., min_length=1, max_length=200)
    target_price: float = Field(..., gt=0)
    alert_type: str = Field(..., regex="^(above|below|change_percentage)$")
    threshold_percentage: Optional[float] = None
    notification_methods: Optional[List[str]] = None
    frequency: str = Field("immediate", regex="^(immediate|daily|weekly)$")


class PriceAlertCreate(PriceAlertBase):
    market_id: Optional[int] = None


class PriceAlertUpdate(BaseModel):
    target_price: Optional[float] = Field(None, gt=0)
    alert_type: Optional[str] = Field(None, regex="^(above|below|change_percentage)$")
    threshold_percentage: Optional[float] = None
    is_active: Optional[bool] = None
    notification_methods: Optional[List[str]] = None
    frequency: Optional[str] = Field(None, regex="^(immediate|daily|weekly)$")


class PriceAlertResponse(PriceAlertBase):
    id: int
    user_id: int
    market_id: Optional[int] = None
    is_active: bool
    last_triggered: Optional[datetime] = None
    trigger_count: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Market Analysis Schemas
class MarketAnalysisBase(BaseModel):
    crop_name: str = Field(..., min_length=1, max_length=200)
    analysis_date: datetime
    analysis_period: str
    average_price: Optional[float] = None
    min_price: Optional[float] = None
    max_price: Optional[float] = None
    price_volatility: Optional[float] = None
    price_trend: Optional[str] = None
    total_volume_traded: Optional[float] = None
    average_daily_volume: Optional[float] = None
    volume_trend: Optional[str] = None
    supply_demand_ratio: Optional[float] = None
    market_concentration: Optional[float] = None
    number_of_active_traders: Optional[int] = None
    seasonal_index: Optional[float] = None
    is_peak_season: Optional[bool] = None
    seasonal_price_premium: Optional[float] = None
    average_quality_grade: Optional[str] = None
    quality_premium: Optional[float] = None
    rejection_rate: Optional[float] = None
    price_forecast_7_days: Optional[float] = None
    price_forecast_30_days: Optional[float] = None
    confidence_interval: Optional[Dict[str, float]] = None
    key_insights: Optional[List[str]] = None
    recommendations: Optional[List[str]] = None
    risk_factors: Optional[List[str]] = None
    opportunities: Optional[List[str]] = None


class MarketAnalysisCreate(MarketAnalysisBase):
    market_id: Optional[int] = None


class MarketAnalysisResponse(MarketAnalysisBase):
    id: int
    market_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True


# Market Search and Filter Schemas
class MarketSearchRequest(BaseModel):
    crop_name: Optional[str] = None
    market_type: Optional[MarketTypeEnum] = None
    location: Optional[Dict[str, float]] = None  # lat, lng
    radius_km: Optional[float] = Field(None, gt=0)
    has_storage: Optional[bool] = None
    has_transport: Optional[bool] = None
    min_price: Optional[float] = Field(None, ge=0)
    max_price: Optional[float] = Field(None, ge=0)
    sort_by: Optional[str] = Field("distance", regex="^(distance|price|rating|volume)$")
    limit: int = Field(20, ge=1, le=100)


class PriceComparisonRequest(BaseModel):
    crop_name: str = Field(..., min_length=1)
    markets: Optional[List[int]] = None
    location: Optional[Dict[str, float]] = None  # lat, lng
    radius_km: Optional[float] = Field(50, gt=0)
    date_range_days: int = Field(30, ge=1, le=365)


class PriceComparisonResponse(BaseModel):
    crop_name: str
    comparison_date: datetime
    markets: List[Dict[str, Any]]
    price_statistics: Dict[str, float]
    best_price_market: Dict[str, Any]
    recommendations: List[str]


# Market Statistics
class MarketStatistics(BaseModel):
    total_markets: int
    active_markets: int
    total_buyers: int
    verified_buyers: int
    total_transactions: int
    total_transaction_value: float
    average_transaction_size: float
    most_traded_crops: List[Dict[str, Any]]
    price_trends: Dict[str, Any]
    market_activity_score: float