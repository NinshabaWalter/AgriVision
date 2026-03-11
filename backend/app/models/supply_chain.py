from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float, JSON, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from app.database import Base


class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, index=True)
    
    # Product identification
    product_code = Column(String(100), unique=True)
    name = Column(String(200), nullable=False)
    category = Column(String(100))  # grains, vegetables, fruits, livestock
    subcategory = Column(String(100))
    
    # Product details
    variety = Column(String(100))
    scientific_name = Column(String(200))
    description = Column(Text)
    
    # Physical characteristics
    unit_of_measure = Column(String(20))  # kg, tons, pieces, liters
    average_weight_kg = Column(Float)
    shelf_life_days = Column(Integer)
    
    # Quality standards
    quality_standards = Column(JSON)  # List of quality requirements
    grading_criteria = Column(JSON)
    
    # Certifications
    organic_certified = Column(Boolean, default=False)
    fair_trade_certified = Column(Boolean, default=False)
    other_certifications = Column(JSON)
    
    # Nutritional information
    nutritional_info = Column(JSON)
    
    # Storage and handling
    storage_requirements = Column(JSON)
    handling_instructions = Column(Text)
    packaging_requirements = Column(JSON)
    
    # Seasonal information
    harvest_seasons = Column(JSON)  # List of harvest periods
    availability_calendar = Column(JSON)
    
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    batches = relationship("Batch", back_populates="product")


class Batch(Base):
    __tablename__ = "batches"
    
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    crop_id = Column(Integer, ForeignKey("crops.id"))
    
    # Batch identification
    batch_number = Column(String(100), unique=True, nullable=False)
    lot_number = Column(String(100))
    
    # Production information
    farm_id = Column(Integer, ForeignKey("farms.id"))
    farmer_id = Column(Integer, ForeignKey("users.id"))
    harvest_date = Column(DateTime(timezone=True))
    production_date = Column(DateTime(timezone=True))
    
    # Quantity and quality
    initial_quantity_kg = Column(Float, nullable=False)
    current_quantity_kg = Column(Float)
    quality_grade = Column(String(20))
    quality_test_results = Column(JSON)
    
    # Processing information
    processing_method = Column(String(100))
    processing_location = Column(String(200))
    processing_date = Column(DateTime(timezone=True))
    
    # Packaging
    packaging_type = Column(String(100))
    packaging_date = Column(DateTime(timezone=True))
    package_size_kg = Column(Float)
    number_of_packages = Column(Integer)
    
    # Certifications for this batch
    organic_certified = Column(Boolean, default=False)
    certification_numbers = Column(JSON)
    
    # Expiry and shelf life
    expiry_date = Column(DateTime(timezone=True))
    best_before_date = Column(DateTime(timezone=True))
    
    # Status tracking
    status = Column(String(20), default='produced')  # produced, processed, packaged, shipped, delivered, sold
    current_location = Column(Geometry('POINT'))
    current_facility = Column(String(200))
    
    # Cost tracking
    production_cost_per_kg = Column(Numeric(8, 2))
    processing_cost_per_kg = Column(Numeric(8, 2))
    packaging_cost_per_kg = Column(Numeric(8, 2))
    total_cost = Column(Numeric(10, 2))
    
    # Traceability
    parent_batch_id = Column(Integer, ForeignKey("batches.id"))  # For processed products
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    product = relationship("Product", back_populates="batches")
    crop = relationship("Crop", back_populates="batches")
    farm = relationship("Farm")
    farmer = relationship("User")
    parent_batch = relationship("Batch", remote_side=[id])
    child_batches = relationship("Batch", remote_side=[parent_batch_id])
    supply_chain_events = relationship("SupplyChainEvent", back_populates="batch")


class SupplyChainEvent(Base):
    __tablename__ = "supply_chain_events"
    
    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, ForeignKey("batches.id"), nullable=False)
    
    # Event details
    event_type = Column(String(50), nullable=False)  # harvest, processing, packaging, transport, storage, sale
    event_description = Column(Text)
    event_timestamp = Column(DateTime(timezone=True), nullable=False)
    
    # Location information
    location = Column(Geometry('POINT'))
    facility_name = Column(String(200))
    facility_type = Column(String(100))  # farm, processing_plant, warehouse, market, retail
    address = Column(Text)
    
    # Responsible party
    responsible_party = Column(String(200))
    responsible_party_type = Column(String(50))  # farmer, processor, transporter, retailer
    contact_information = Column(JSON)
    
    # Quantity tracking
    quantity_in_kg = Column(Float)
    quantity_out_kg = Column(Float)
    quantity_lost_kg = Column(Float)
    loss_reason = Column(String(200))
    
    # Quality information
    quality_check_performed = Column(Boolean, default=False)
    quality_results = Column(JSON)
    quality_grade = Column(String(20))
    quality_notes = Column(Text)
    
    # Transportation details (if applicable)
    transport_method = Column(String(100))  # truck, motorcycle, bicycle, walking
    vehicle_registration = Column(String(50))
    driver_name = Column(String(200))
    departure_time = Column(DateTime(timezone=True))
    arrival_time = Column(DateTime(timezone=True))
    distance_km = Column(Float)
    
    # Storage conditions
    storage_temperature_c = Column(Float)
    storage_humidity_percentage = Column(Float)
    storage_conditions = Column(JSON)
    
    # Documentation
    documentation_reference = Column(String(100))
    certificates = Column(JSON)  # List of certificates/documents
    photos = Column(JSON)  # List of photo URLs
    
    # Cost information
    event_cost = Column(Numeric(10, 2))
    cost_type = Column(String(50))  # transport, storage, processing, handling
    
    # Environmental conditions
    weather_conditions = Column(JSON)
    temperature_during_event = Column(Float)
    
    # Verification
    verified = Column(Boolean, default=False)
    verified_by = Column(String(200))
    verification_method = Column(String(100))  # manual, qr_code, rfid, gps
    
    # Next destination
    next_destination = Column(String(200))
    expected_arrival = Column(DateTime(timezone=True))
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    batch = relationship("Batch", back_populates="supply_chain_events")