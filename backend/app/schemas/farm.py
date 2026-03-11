from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class FarmTypeEnum(str, Enum):
    SUBSISTENCE = "subsistence"
    COMMERCIAL = "commercial"
    MIXED = "mixed"
    ORGANIC = "organic"
    GREENHOUSE = "greenhouse"


class IrrigationTypeEnum(str, Enum):
    RAIN_FED = "rain_fed"
    DRIP = "drip"
    SPRINKLER = "sprinkler"
    FLOOD = "flood"
    MANUAL = "manual"


class SoilTypeEnum(str, Enum):
    CLAY = "clay"
    SANDY = "sandy"
    LOAM = "loam"
    SILT = "silt"
    ROCKY = "rocky"


# Farm Schemas
class FarmBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    country: Optional[str] = None
    region: Optional[str] = None
    district: Optional[str] = None
    village: Optional[str] = None
    address: Optional[str] = None
    total_area_hectares: Optional[float] = Field(None, ge=0)
    cultivated_area_hectares: Optional[float] = Field(None, ge=0)
    farm_type: Optional[FarmTypeEnum] = None
    soil_type: Optional[SoilTypeEnum] = None
    irrigation_type: Optional[IrrigationTypeEnum] = None
    has_electricity: bool = False
    has_water_source: bool = False
    has_storage_facility: bool = False
    has_processing_facility: bool = False
    is_organic_certified: bool = False
    certification_body: Optional[str] = None
    estimated_value: Optional[float] = Field(None, ge=0)
    annual_revenue: Optional[float] = Field(None, ge=0)
    annual_expenses: Optional[float] = Field(None, ge=0)


class FarmCreate(FarmBase):
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    boundary_coordinates: Optional[List[List[float]]] = None


class FarmUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    total_area_hectares: Optional[float] = Field(None, ge=0)
    cultivated_area_hectares: Optional[float] = Field(None, ge=0)
    farm_type: Optional[FarmTypeEnum] = None
    soil_type: Optional[SoilTypeEnum] = None
    irrigation_type: Optional[IrrigationTypeEnum] = None
    has_electricity: Optional[bool] = None
    has_water_source: Optional[bool] = None
    has_storage_facility: Optional[bool] = None
    has_processing_facility: Optional[bool] = None
    is_organic_certified: Optional[bool] = None
    certification_body: Optional[str] = None
    estimated_value: Optional[float] = Field(None, ge=0)
    annual_revenue: Optional[float] = Field(None, ge=0)
    annual_expenses: Optional[float] = Field(None, ge=0)


class FarmResponse(FarmBase):
    id: int
    owner_id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    certification_date: Optional[datetime] = None
    certification_expiry: Optional[datetime] = None
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Field Schemas
class FieldBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    area_hectares: float = Field(..., gt=0)
    soil_type: Optional[SoilTypeEnum] = None
    slope_percentage: Optional[float] = Field(None, ge=0, le=100)
    drainage_quality: Optional[str] = None
    ph_level: Optional[float] = Field(None, ge=0, le=14)
    organic_matter_percentage: Optional[float] = Field(None, ge=0, le=100)
    is_fallow: bool = False


class FieldCreate(FieldBase):
    farm_id: int
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    boundary_coordinates: Optional[List[List[float]]] = None
    current_crop_id: Optional[int] = None


class FieldUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    area_hectares: Optional[float] = Field(None, gt=0)
    soil_type: Optional[SoilTypeEnum] = None
    slope_percentage: Optional[float] = Field(None, ge=0, le=100)
    drainage_quality: Optional[str] = None
    ph_level: Optional[float] = Field(None, ge=0, le=14)
    organic_matter_percentage: Optional[float] = Field(None, ge=0, le=100)
    is_fallow: Optional[bool] = None
    current_crop_id: Optional[int] = None


class FieldResponse(FieldBase):
    id: int
    farm_id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    current_crop_id: Optional[int] = None
    last_cultivation_date: Optional[datetime] = None
    next_planned_cultivation: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Crop Schemas
class CropCategoryEnum(str, Enum):
    CEREALS = "cereals"
    LEGUMES = "legumes"
    VEGETABLES = "vegetables"
    FRUITS = "fruits"
    CASH_CROPS = "cash_crops"
    FODDER = "fodder"
    SPICES = "spices"


class CropBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    scientific_name: Optional[str] = None
    local_name: Optional[str] = None
    category: Optional[CropCategoryEnum] = None
    variety: Optional[str] = None
    growing_season: Optional[str] = None
    maturity_days: Optional[int] = Field(None, gt=0)
    expected_yield_per_hectare: Optional[float] = Field(None, ge=0)
    min_temperature: Optional[float] = None
    max_temperature: Optional[float] = None
    min_rainfall_mm: Optional[float] = Field(None, ge=0)
    max_rainfall_mm: Optional[float] = Field(None, ge=0)
    soil_ph_min: Optional[float] = Field(None, ge=0, le=14)
    soil_ph_max: Optional[float] = Field(None, ge=0, le=14)
    seed_cost_per_hectare: Optional[float] = Field(None, ge=0)
    fertilizer_cost_per_hectare: Optional[float] = Field(None, ge=0)
    labor_cost_per_hectare: Optional[float] = Field(None, ge=0)
    expected_price_per_kg: Optional[float] = Field(None, ge=0)


class CropCreate(CropBase):
    farm_id: int


class CropUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    scientific_name: Optional[str] = None
    local_name: Optional[str] = None
    category: Optional[CropCategoryEnum] = None
    variety: Optional[str] = None
    growing_season: Optional[str] = None
    maturity_days: Optional[int] = Field(None, gt=0)
    expected_yield_per_hectare: Optional[float] = Field(None, ge=0)
    min_temperature: Optional[float] = None
    max_temperature: Optional[float] = None
    min_rainfall_mm: Optional[float] = Field(None, ge=0)
    max_rainfall_mm: Optional[float] = Field(None, ge=0)
    soil_ph_min: Optional[float] = Field(None, ge=0, le=14)
    soil_ph_max: Optional[float] = Field(None, ge=0, le=14)
    seed_cost_per_hectare: Optional[float] = Field(None, ge=0)
    fertilizer_cost_per_hectare: Optional[float] = Field(None, ge=0)
    labor_cost_per_hectare: Optional[float] = Field(None, ge=0)
    expected_price_per_kg: Optional[float] = Field(None, ge=0)


class CropResponse(CropBase):
    id: int
    farm_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Planting Record Schemas
class PlantingRecordBase(BaseModel):
    planting_date: datetime
    area_planted_hectares: float = Field(..., gt=0)
    seed_variety: Optional[str] = None
    seed_quantity_kg: Optional[float] = Field(None, ge=0)
    seed_cost: Optional[float] = Field(None, ge=0)
    planting_method: Optional[str] = None
    row_spacing_cm: Optional[float] = Field(None, gt=0)
    plant_spacing_cm: Optional[float] = Field(None, gt=0)
    planting_depth_cm: Optional[float] = Field(None, gt=0)
    expected_harvest_date: Optional[datetime] = None
    expected_yield_kg: Optional[float] = Field(None, ge=0)
    fertilizer_cost: Optional[float] = Field(None, ge=0)
    pesticide_cost: Optional[float] = Field(None, ge=0)
    labor_cost: Optional[float] = Field(None, ge=0)
    irrigation_cost: Optional[float] = Field(None, ge=0)
    other_costs: Optional[float] = Field(None, ge=0)
    notes: Optional[str] = None
    weather_conditions: Optional[str] = None
    challenges_faced: Optional[str] = None


class PlantingRecordCreate(PlantingRecordBase):
    field_id: int
    crop_id: int


class PlantingRecordUpdate(BaseModel):
    actual_harvest_date: Optional[datetime] = None
    actual_yield_kg: Optional[float] = Field(None, ge=0)
    quality_grade: Optional[str] = None
    status: Optional[str] = None
    notes: Optional[str] = None


class PlantingRecordResponse(PlantingRecordBase):
    id: int
    field_id: int
    crop_id: int
    actual_harvest_date: Optional[datetime] = None
    actual_yield_kg: Optional[float] = None
    quality_grade: Optional[str] = None
    status: str
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Harvest Record Schemas
class HarvestRecordBase(BaseModel):
    harvest_date: datetime
    area_harvested_hectares: float = Field(..., gt=0)
    total_yield_kg: float = Field(..., ge=0)
    quality_grade: Optional[str] = None
    moisture_content_percentage: Optional[float] = Field(None, ge=0, le=100)
    damage_percentage: Optional[float] = Field(None, ge=0, le=100)
    foreign_matter_percentage: Optional[float] = Field(None, ge=0, le=100)
    drying_method: Optional[str] = None
    storage_method: Optional[str] = None
    processing_method: Optional[str] = None
    price_per_kg: Optional[float] = Field(None, ge=0)
    total_revenue: Optional[float] = Field(None, ge=0)
    marketing_cost: Optional[float] = Field(None, ge=0)
    storage_cost: Optional[float] = Field(None, ge=0)
    processing_cost: Optional[float] = Field(None, ge=0)
    transport_cost: Optional[float] = Field(None, ge=0)
    buyer_type: Optional[str] = None
    market_location: Optional[str] = None
    payment_terms: Optional[str] = None
    notes: Optional[str] = None
    lessons_learned: Optional[str] = None


class HarvestRecordCreate(HarvestRecordBase):
    planting_record_id: int
    field_id: int
    crop_id: int


class HarvestRecordUpdate(BaseModel):
    quality_grade: Optional[str] = None
    price_per_kg: Optional[float] = Field(None, ge=0)
    total_revenue: Optional[float] = Field(None, ge=0)
    payment_received: Optional[bool] = None
    payment_date: Optional[datetime] = None
    notes: Optional[str] = None


class HarvestRecordResponse(HarvestRecordBase):
    id: int
    planting_record_id: int
    field_id: int
    crop_id: int
    yield_per_hectare: Optional[float] = None
    payment_received: bool
    payment_date: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Equipment Schemas
class EquipmentBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    type: Optional[str] = None
    brand: Optional[str] = None
    model: Optional[str] = None
    purchase_date: Optional[datetime] = None
    purchase_price: Optional[float] = Field(None, ge=0)
    supplier: Optional[str] = None
    warranty_expiry: Optional[datetime] = None
    condition: Optional[str] = None
    last_maintenance_date: Optional[datetime] = None
    next_maintenance_due: Optional[datetime] = None
    hours_used: Optional[float] = Field(None, ge=0)
    current_value: Optional[float] = Field(None, ge=0)
    annual_depreciation: Optional[float] = Field(None, ge=0)
    maintenance_cost_annual: Optional[float] = Field(None, ge=0)
    is_available: bool = True
    is_shared: bool = False
    notes: Optional[str] = None


class EquipmentCreate(EquipmentBase):
    farm_id: int


class EquipmentUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    condition: Optional[str] = None
    last_maintenance_date: Optional[datetime] = None
    next_maintenance_due: Optional[datetime] = None
    hours_used: Optional[float] = Field(None, ge=0)
    current_value: Optional[float] = Field(None, ge=0)
    maintenance_cost_annual: Optional[float] = Field(None, ge=0)
    is_available: Optional[bool] = None
    is_shared: Optional[bool] = None
    notes: Optional[str] = None


class EquipmentResponse(EquipmentBase):
    id: int
    farm_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Farm Statistics
class FarmStatistics(BaseModel):
    total_farms: int
    total_area_hectares: float
    total_fields: int
    total_crops: int
    active_plantings: int
    recent_harvests: int
    average_yield_per_hectare: Optional[float] = None
    total_revenue: Optional[float] = None
    total_expenses: Optional[float] = None
    profit_margin: Optional[float] = None