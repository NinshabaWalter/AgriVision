from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float, JSON, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from app.database import Base
import enum


class MarketType(enum.Enum):
    LOCAL = "local"
    REGIONAL = "regional"
    NATIONAL = "national"
    INTERNATIONAL = "international"
    ONLINE = "online"
    COOPERATIVE = "cooperative"
    AUCTION = "auction"


class PriceType(enum.Enum):
    WHOLESALE = "wholesale"
    RETAIL = "retail"
    FARM_GATE = "farm_gate"
    EXPORT = "export"
    CONTRACT = "contract"


class TransactionStatus(enum.Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    IN_TRANSIT = "in_transit"
    DELIVERED = "delivered"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    DISPUTED = "disputed"


class PaymentStatus(enum.Enum):
    PENDING = "pending"
    PARTIAL = "partial"
    COMPLETED = "completed"
    OVERDUE = "overdue"
    FAILED = "failed"


class Market(Base):
    __tablename__ = "markets"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    type = Column(Enum(MarketType), nullable=False)
    
    # Location information
    location = Column(Geometry('POINT'), nullable=False)
    address = Column(Text)
    country = Column(String(100))
    region = Column(String(100))
    district = Column(String(100))
    
    # Market characteristics
    operating_days = Column(JSON)  # Days of week market operates
    operating_hours = Column(String(100))
    seasonal_operation = Column(Boolean, default=False)
    peak_seasons = Column(JSON)
    
    # Infrastructure
    has_storage_facilities = Column(Boolean, default=False)
    has_processing_facilities = Column(Boolean, default=False)
    has_cold_storage = Column(Boolean, default=False)
    has_grading_facilities = Column(Boolean, default=False)
    has_packaging_facilities = Column(Boolean, default=False)
    
    # Services
    provides_transport = Column(Boolean, default=False)
    provides_credit = Column(Boolean, default=False)
    provides_insurance = Column(Boolean, default=False)
    provides_quality_testing = Column(Boolean, default=False)
    
    # Market information
    average_daily_volume_kg = Column(Float)
    number_of_vendors = Column(Integer)
    primary_crops_traded = Column(JSON)
    
    # Contact information
    contact_person = Column(String(200))
    phone_number = Column(String(20))
    email = Column(String(255))
    website = Column(String(500))
    
    # Metadata
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    prices = relationship("MarketPrice", back_populates="market")
    transactions = relationship("MarketTransaction", back_populates="market")
    buyers = relationship("Buyer", back_populates="preferred_markets")


class MarketPrice(Base):
    __tablename__ = "market_prices"
    
    id = Column(Integer, primary_key=True, index=True)
    market_id = Column(Integer, ForeignKey("markets.id"), nullable=False)
    crop_name = Column(String(200), nullable=False)
    variety = Column(String(200))
    grade = Column(String(50))
    
    # Price information
    price_per_kg = Column(Float, nullable=False)
    price_type = Column(Enum(PriceType), nullable=False)
    currency = Column(String(10), default="KES")
    
    # Market conditions
    supply_level = Column(String(50))  # low, normal, high, oversupply
    demand_level = Column(String(50))  # low, normal, high, very_high
    quality_available = Column(String(50))  # poor, fair, good, excellent
    
    # Volume and trends
    volume_traded_kg = Column(Float)
    price_trend = Column(String(50))  # rising, stable, falling
    price_change_percentage = Column(Float)
    
    # Seasonal factors
    is_peak_season = Column(Boolean, default=False)
    seasonal_factor = Column(Float)  # Multiplier for seasonal adjustment
    
    # Data source and reliability
    data_source = Column(String(100))  # government, market_survey, trader_report, api
    reliability_score = Column(Float)  # 0-1
    sample_size = Column(Integer)
    
    # Temporal information
    price_date = Column(DateTime, nullable=False)
    valid_until = Column(DateTime)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    market = relationship("Market", back_populates="prices")


class Buyer(Base):
    __tablename__ = "buyers"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    type = Column(String(100))  # individual, cooperative, processor, exporter, retailer
    
    # Contact information
    contact_person = Column(String(200))
    phone_number = Column(String(20))
    email = Column(String(255))
    address = Column(Text)
    location = Column(Geometry('POINT'))
    
    # Business information
    business_registration = Column(String(100))
    tax_id = Column(String(100))
    license_number = Column(String(100))
    
    # Buying preferences
    preferred_crops = Column(JSON)
    quality_requirements = Column(JSON)
    volume_requirements = Column(JSON)  # min/max quantities
    preferred_markets_ids = Column(JSON)  # List of market IDs
    
    # Payment terms
    payment_terms = Column(String(200))
    payment_methods = Column(JSON)
    credit_limit = Column(Float)
    payment_history_score = Column(Float)  # 0-1
    
    # Logistics
    provides_transport = Column(Boolean, default=False)
    transport_capacity_kg = Column(Float)
    delivery_radius_km = Column(Float)
    
    # Ratings and reviews
    reliability_rating = Column(Float)  # 0-5
    payment_punctuality_rating = Column(Float)  # 0-5
    communication_rating = Column(Float)  # 0-5
    overall_rating = Column(Float)  # 0-5
    total_transactions = Column(Integer, default=0)
    
    # Status
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    verification_date = Column(DateTime)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    preferred_markets = relationship("Market", back_populates="buyers")
    transactions = relationship("MarketTransaction", back_populates="buyer")
    reviews = relationship("BuyerReview", back_populates="buyer")


class MarketTransaction(Base):
    __tablename__ = "market_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    seller_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    buyer_id = Column(Integer, ForeignKey("buyers.id"), nullable=False)
    market_id = Column(Integer, ForeignKey("markets.id"))
    
    # Product information
    crop_name = Column(String(200), nullable=False)
    variety = Column(String(200))
    grade = Column(String(50))
    quantity_kg = Column(Float, nullable=False)
    
    # Pricing
    price_per_kg = Column(Float, nullable=False)
    total_amount = Column(Float, nullable=False)
    currency = Column(String(10), default="KES")
    
    # Quality specifications
    moisture_content = Column(Float)
    foreign_matter_percentage = Column(Float)
    damage_percentage = Column(Float)
    quality_grade = Column(String(50))
    quality_test_results = Column(JSON)
    
    # Transaction terms
    payment_terms = Column(String(200))
    delivery_terms = Column(String(200))
    delivery_date = Column(DateTime)
    delivery_location = Column(String(500))
    
    # Status tracking
    status = Column(Enum(TransactionStatus), default=TransactionStatus.PENDING)
    payment_status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING)
    
    # Logistics
    transport_arranged_by = Column(String(100))  # seller, buyer, third_party
    transport_cost = Column(Float)
    packaging_cost = Column(Float)
    handling_cost = Column(Float)
    
    # Dates and timeline
    transaction_date = Column(DateTime, nullable=False)
    expected_delivery_date = Column(DateTime)
    actual_delivery_date = Column(DateTime)
    payment_due_date = Column(DateTime)
    payment_received_date = Column(DateTime)
    
    # Documentation
    contract_document_url = Column(String(500))
    quality_certificate_url = Column(String(500))
    delivery_receipt_url = Column(String(500))
    payment_receipt_url = Column(String(500))
    
    # Feedback and ratings
    seller_rating = Column(Float)  # Buyer rates seller
    buyer_rating = Column(Float)   # Seller rates buyer
    seller_feedback = Column(Text)
    buyer_feedback = Column(Text)
    
    # Dispute management
    has_dispute = Column(Boolean, default=False)
    dispute_reason = Column(Text)
    dispute_resolution = Column(Text)
    dispute_resolved_date = Column(DateTime)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    seller = relationship("User", foreign_keys=[seller_id])
    buyer = relationship("Buyer", back_populates="transactions")
    market = relationship("Market", back_populates="transactions")


class BuyerReview(Base):
    __tablename__ = "buyer_reviews"
    
    id = Column(Integer, primary_key=True, index=True)
    buyer_id = Column(Integer, ForeignKey("buyers.id"), nullable=False)
    reviewer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    transaction_id = Column(Integer, ForeignKey("market_transactions.id"))
    
    # Ratings (1-5 scale)
    overall_rating = Column(Float, nullable=False)
    payment_punctuality = Column(Float)
    communication = Column(Float)
    reliability = Column(Float)
    fairness = Column(Float)
    
    # Review content
    title = Column(String(200))
    review_text = Column(Text)
    pros = Column(JSON)
    cons = Column(JSON)
    
    # Recommendations
    would_trade_again = Column(Boolean)
    recommended_for = Column(JSON)  # Types of farmers/situations
    
    # Review metadata
    is_verified = Column(Boolean, default=False)
    is_anonymous = Column(Boolean, default=False)
    helpful_votes = Column(Integer, default=0)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    buyer = relationship("Buyer", back_populates="reviews")
    reviewer = relationship("User")
    transaction = relationship("MarketTransaction")


class PriceAlert(Base):
    __tablename__ = "price_alerts"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    crop_name = Column(String(200), nullable=False)
    market_id = Column(Integer, ForeignKey("markets.id"))
    
    # Alert conditions
    target_price = Column(Float, nullable=False)
    alert_type = Column(String(50))  # above, below, change_percentage
    threshold_percentage = Column(Float)  # For percentage change alerts
    
    # Alert settings
    is_active = Column(Boolean, default=True)
    notification_methods = Column(JSON)  # sms, email, push
    frequency = Column(String(50))  # immediate, daily, weekly
    
    # Trigger history
    last_triggered = Column(DateTime)
    trigger_count = Column(Integer, default=0)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User")
    market = relationship("Market")


class MarketAnalysis(Base):
    __tablename__ = "market_analysis"
    
    id = Column(Integer, primary_key=True, index=True)
    crop_name = Column(String(200), nullable=False)
    market_id = Column(Integer, ForeignKey("markets.id"))
    analysis_date = Column(DateTime, nullable=False)
    analysis_period = Column(String(50))  # daily, weekly, monthly, seasonal
    
    # Price analysis
    average_price = Column(Float)
    min_price = Column(Float)
    max_price = Column(Float)
    price_volatility = Column(Float)
    price_trend = Column(String(50))
    
    # Volume analysis
    total_volume_traded = Column(Float)
    average_daily_volume = Column(Float)
    volume_trend = Column(String(50))
    
    # Market dynamics
    supply_demand_ratio = Column(Float)
    market_concentration = Column(Float)  # HHI or similar measure
    number_of_active_traders = Column(Integer)
    
    # Seasonal patterns
    seasonal_index = Column(Float)
    is_peak_season = Column(Boolean)
    seasonal_price_premium = Column(Float)
    
    # Quality trends
    average_quality_grade = Column(String(50))
    quality_premium = Column(Float)
    rejection_rate = Column(Float)
    
    # Forecasts
    price_forecast_7_days = Column(Float)
    price_forecast_30_days = Column(Float)
    confidence_interval = Column(JSON)  # Upper and lower bounds
    
    # Market insights
    key_insights = Column(JSON)
    recommendations = Column(JSON)
    risk_factors = Column(JSON)
    opportunities = Column(JSON)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    market = relationship("Market")