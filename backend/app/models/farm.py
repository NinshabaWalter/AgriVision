from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float, JSON, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from app.database import Base
import enum


class FarmType(enum.Enum):
    SUBSISTENCE = "subsistence"
    COMMERCIAL = "commercial"
    MIXED = "mixed"
    ORGANIC = "organic"
    GREENHOUSE = "greenhouse"


class IrrigationType(enum.Enum):
    RAIN_FED = "rain_fed"
    DRIP = "drip"
    SPRINKLER = "sprinkler"
    FLOOD = "flood"
    MANUAL = "manual"


class SoilType(enum.Enum):
    CLAY = "clay"
    SANDY = "sandy"
    LOAM = "loam"
    SILT = "silt"
    ROCKY = "rocky"


class Farm(Base):
    __tablename__ = "farms"
    
    id = Column(Integer, primary_key=True, index=True)
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String(200), nullable=False)
    description = Column(Text)
    
    # Location information
    country = Column(String(100))
    region = Column(String(100))
    district = Column(String(100))
    village = Column(String(100))
    address = Column(Text)
    location = Column(Geometry('POINT'))  # Farm center point
    boundary = Column(Geometry('POLYGON'))  # Farm boundary
    
    # Farm characteristics
    total_area_hectares = Column(Float)
    cultivated_area_hectares = Column(Float)
    farm_type = Column(Enum(FarmType))
    soil_type = Column(Enum(SoilType))
    irrigation_type = Column(Enum(IrrigationType))
    
    # Infrastructure
    has_electricity = Column(Boolean, default=False)
    has_water_source = Column(Boolean, default=False)
    has_storage_facility = Column(Boolean, default=False)
    has_processing_facility = Column(Boolean, default=False)
    
    # Certification and compliance
    is_organic_certified = Column(Boolean, default=False)
    certification_body = Column(String(200))
    certification_date = Column(DateTime)
    certification_expiry = Column(DateTime)
    
    # Financial information
    estimated_value = Column(Float)
    annual_revenue = Column(Float)
    annual_expenses = Column(Float)
    
    # Metadata
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    owner = relationship("User", back_populates="farms")
    fields = relationship("Field", back_populates="farm", cascade="all, delete-orphan")
    crops = relationship("Crop", back_populates="farm")
    weather_data = relationship("WeatherData", back_populates="farm")
    soil_tests = relationship("SoilTest", back_populates="farm")
    equipment = relationship("Equipment", back_populates="farm")


class Field(Base):
    __tablename__ = "fields"
    
    id = Column(Integer, primary_key=True, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=False)
    name = Column(String(200), nullable=False)
    description = Column(Text)
    
    # Location and size
    location = Column(Geometry('POINT'))  # Field center
    boundary = Column(Geometry('POLYGON'))  # Field boundary
    area_hectares = Column(Float, nullable=False)
    
    # Field characteristics
    soil_type = Column(Enum(SoilType))
    slope_percentage = Column(Float)
    drainage_quality = Column(String(50))  # poor, fair, good, excellent
    ph_level = Column(Float)
    organic_matter_percentage = Column(Float)
    
    # Current status
    current_crop_id = Column(Integer, ForeignKey("crops.id"))
    is_fallow = Column(Boolean, default=False)
    last_cultivation_date = Column(DateTime)
    next_planned_cultivation = Column(DateTime)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    farm = relationship("Farm", back_populates="fields")
    current_crop = relationship("Crop", foreign_keys=[current_crop_id])
    planting_records = relationship("PlantingRecord", back_populates="field")
    harvest_records = relationship("HarvestRecord", back_populates="field")


class CropCategory(enum.Enum):
    CEREALS = "cereals"
    LEGUMES = "legumes"
    VEGETABLES = "vegetables"
    FRUITS = "fruits"
    CASH_CROPS = "cash_crops"
    FODDER = "fodder"
    SPICES = "spices"


class Crop(Base):
    __tablename__ = "crops"
    
    id = Column(Integer, primary_key=True, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=False)
    name = Column(String(200), nullable=False)
    scientific_name = Column(String(200))
    local_name = Column(String(200))
    category = Column(Enum(CropCategory))
    variety = Column(String(200))
    
    # Growing characteristics
    growing_season = Column(String(100))  # wet, dry, year-round
    maturity_days = Column(Integer)
    expected_yield_per_hectare = Column(Float)
    
    # Requirements
    min_temperature = Column(Float)
    max_temperature = Column(Float)
    min_rainfall_mm = Column(Float)
    max_rainfall_mm = Column(Float)
    soil_ph_min = Column(Float)
    soil_ph_max = Column(Float)
    
    # Economic data
    seed_cost_per_hectare = Column(Float)
    fertilizer_cost_per_hectare = Column(Float)
    labor_cost_per_hectare = Column(Float)
    expected_price_per_kg = Column(Float)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    farm = relationship("Farm", back_populates="crops")
    planting_records = relationship("PlantingRecord", back_populates="crop")
    harvest_records = relationship("HarvestRecord", back_populates="crop")
    disease_detections = relationship("DiseaseDetection", back_populates="crop")


class PlantingRecord(Base):
    __tablename__ = "planting_records"
    
    id = Column(Integer, primary_key=True, index=True)
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=False)
    crop_id = Column(Integer, ForeignKey("crops.id"), nullable=False)
    
    # Planting details
    planting_date = Column(DateTime, nullable=False)
    area_planted_hectares = Column(Float, nullable=False)
    seed_variety = Column(String(200))
    seed_quantity_kg = Column(Float)
    seed_cost = Column(Float)
    
    # Planting method
    planting_method = Column(String(100))  # direct_seeding, transplanting, broadcasting
    row_spacing_cm = Column(Float)
    plant_spacing_cm = Column(Float)
    planting_depth_cm = Column(Float)
    
    # Expected outcomes
    expected_harvest_date = Column(DateTime)
    expected_yield_kg = Column(Float)
    
    # Actual outcomes (filled after harvest)
    actual_harvest_date = Column(DateTime)
    actual_yield_kg = Column(Float)
    quality_grade = Column(String(50))
    
    # Costs and inputs
    fertilizer_cost = Column(Float)
    pesticide_cost = Column(Float)
    labor_cost = Column(Float)
    irrigation_cost = Column(Float)
    other_costs = Column(Float)
    
    # Notes and observations
    notes = Column(Text)
    weather_conditions = Column(Text)
    challenges_faced = Column(Text)
    
    # Status
    status = Column(String(50), default="planted")  # planted, growing, harvested, failed
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    field = relationship("Field", back_populates="planting_records")
    crop = relationship("Crop", back_populates="planting_records")
    harvest_records = relationship("HarvestRecord", back_populates="planting_record")


class HarvestRecord(Base):
    __tablename__ = "harvest_records"
    
    id = Column(Integer, primary_key=True, index=True)
    planting_record_id = Column(Integer, ForeignKey("planting_records.id"), nullable=False)
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=False)
    crop_id = Column(Integer, ForeignKey("crops.id"), nullable=False)
    
    # Harvest details
    harvest_date = Column(DateTime, nullable=False)
    area_harvested_hectares = Column(Float, nullable=False)
    total_yield_kg = Column(Float, nullable=False)
    yield_per_hectare = Column(Float)
    
    # Quality assessment
    quality_grade = Column(String(50))  # A, B, C, reject
    moisture_content_percentage = Column(Float)
    damage_percentage = Column(Float)
    foreign_matter_percentage = Column(Float)
    
    # Post-harvest handling
    drying_method = Column(String(100))
    storage_method = Column(String(100))
    processing_method = Column(String(100))
    
    # Economic data
    price_per_kg = Column(Float)
    total_revenue = Column(Float)
    marketing_cost = Column(Float)
    storage_cost = Column(Float)
    processing_cost = Column(Float)
    transport_cost = Column(Float)
    
    # Market information
    buyer_type = Column(String(100))  # local_market, cooperative, processor, export
    market_location = Column(String(200))
    payment_terms = Column(String(100))
    payment_received = Column(Boolean, default=False)
    payment_date = Column(DateTime)
    
    # Notes
    notes = Column(Text)
    lessons_learned = Column(Text)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    planting_record = relationship("PlantingRecord", back_populates="harvest_records")
    field = relationship("Field", back_populates="harvest_records")
    crop = relationship("Crop", back_populates="harvest_records")


class Equipment(Base):
    __tablename__ = "equipment"
    
    id = Column(Integer, primary_key=True, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=False)
    name = Column(String(200), nullable=False)
    type = Column(String(100))  # tractor, plow, harvester, irrigation, etc.
    brand = Column(String(100))
    model = Column(String(100))
    
    # Purchase information
    purchase_date = Column(DateTime)
    purchase_price = Column(Float)
    supplier = Column(String(200))
    warranty_expiry = Column(DateTime)
    
    # Current status
    condition = Column(String(50))  # excellent, good, fair, poor, broken
    last_maintenance_date = Column(DateTime)
    next_maintenance_due = Column(DateTime)
    hours_used = Column(Float)
    
    # Financial
    current_value = Column(Float)
    annual_depreciation = Column(Float)
    maintenance_cost_annual = Column(Float)
    
    # Usage tracking
    is_available = Column(Boolean, default=True)
    is_shared = Column(Boolean, default=False)  # Shared with other farmers
    
    # Metadata
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    farm = relationship("Farm", back_populates="equipment")