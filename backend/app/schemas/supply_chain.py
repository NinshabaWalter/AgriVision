from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class ProductStatusEnum(str, Enum):
    PLANNING = "planning"
    GROWING = "growing"
    HARVESTED = "harvested"
    PROCESSED = "processed"
    PACKAGED = "packaged"
    IN_TRANSIT = "in_transit"
    DELIVERED = "delivered"
    SOLD = "sold"
    EXPIRED = "expired"


class BatchStatusEnum(str, Enum):
    CREATED = "created"
    IN_PRODUCTION = "in_production"
    QUALITY_CHECK = "quality_check"
    APPROVED = "approved"
    REJECTED = "rejected"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    RECALLED = "recalled"


class EventTypeEnum(str, Enum):
    PLANTING = "planting"
    FERTILIZER_APPLICATION = "fertilizer_application"
    PESTICIDE_APPLICATION = "pesticide_application"
    IRRIGATION = "irrigation"
    HARVESTING = "harvesting"
    PROCESSING = "processing"
    PACKAGING = "packaging"
    QUALITY_TEST = "quality_test"
    STORAGE = "storage"
    TRANSPORT = "transport"
    DELIVERY = "delivery"
    SALE = "sale"


class QualityGradeEnum(str, Enum):
    PREMIUM = "premium"
    GRADE_A = "grade_a"
    GRADE_B = "grade_b"
    GRADE_C = "grade_c"
    REJECT = "reject"


# Product Schemas
class ProductBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    product_code: Optional[str] = None
    category: Optional[str] = None
    variety: Optional[str] = None
    description: Optional[str] = None
    unit_of_measure: str = Field(..., min_length=1, max_length=50)
    shelf_life_days: Optional[int] = Field(None, gt=0)
    storage_requirements: Optional[str] = None
    handling_instructions: Optional[str] = None
    nutritional_info: Optional[Dict[str, Any]] = None
    certifications: Optional[List[str]] = None
    origin_country: Optional[str] = None
    origin_region: Optional[str] = None
    seasonal_availability: Optional[List[str]] = None
    target_markets: Optional[List[str]] = None
    quality_standards: Optional[Dict[str, Any]] = None


class ProductCreate(ProductBase):
    farm_id: int
    crop_id: Optional[int] = None


class ProductUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    shelf_life_days: Optional[int] = Field(None, gt=0)
    storage_requirements: Optional[str] = None
    handling_instructions: Optional[str] = None
    certifications: Optional[List[str]] = None
    target_markets: Optional[List[str]] = None
    quality_standards: Optional[Dict[str, Any]] = None


class ProductResponse(ProductBase):
    id: int
    farm_id: int
    crop_id: Optional[int] = None
    producer_id: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Batch Schemas
class BatchBase(BaseModel):
    batch_number: str = Field(..., min_length=1, max_length=100)
    production_date: datetime
    expiry_date: Optional[datetime] = None
    quantity: float = Field(..., gt=0)
    unit_of_measure: str = Field(..., min_length=1, max_length=50)
    quality_grade: Optional[QualityGradeEnum] = None
    quality_score: Optional[float] = Field(None, ge=0, le=100)
    moisture_content_percentage: Optional[float] = Field(None, ge=0, le=100)
    foreign_matter_percentage: Optional[float] = Field(None, ge=0, le=100)
    damage_percentage: Optional[float] = Field(None, ge=0, le=100)
    processing_method: Optional[str] = None
    packaging_type: Optional[str] = None
    packaging_date: Optional[datetime] = None
    storage_location: Optional[str] = None
    storage_conditions: Optional[Dict[str, Any]] = None
    certifications: Optional[List[str]] = None
    test_results: Optional[Dict[str, Any]] = None
    notes: Optional[str] = None

    @validator('expiry_date')
    def validate_expiry_date(cls, v, values):
        if v and 'production_date' in values and v <= values['production_date']:
            raise ValueError('Expiry date must be after production date')
        return v


class BatchCreate(BatchBase):
    product_id: int
    field_id: Optional[int] = None
    harvest_record_id: Optional[int] = None


class BatchUpdate(BaseModel):
    quantity: Optional[float] = Field(None, gt=0)
    quality_grade: Optional[QualityGradeEnum] = None
    quality_score: Optional[float] = Field(None, ge=0, le=100)
    moisture_content_percentage: Optional[float] = Field(None, ge=0, le=100)
    packaging_type: Optional[str] = None
    packaging_date: Optional[datetime] = None
    storage_location: Optional[str] = None
    storage_conditions: Optional[Dict[str, Any]] = None
    test_results: Optional[Dict[str, Any]] = None
    status: Optional[BatchStatusEnum] = None
    notes: Optional[str] = None


class BatchResponse(BatchBase):
    id: int
    product_id: int
    field_id: Optional[int] = None
    harvest_record_id: Optional[int] = None
    producer_id: int
    status: BatchStatusEnum
    current_quantity: Optional[float] = None
    quantity_sold: Optional[float] = None
    quantity_remaining: Optional[float] = None
    traceability_code: Optional[str] = None
    blockchain_hash: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Supply Chain Event Schemas
class SupplyChainEventBase(BaseModel):
    event_type: EventTypeEnum
    event_date: datetime
    location: Optional[str] = None
    description: str = Field(..., min_length=1)
    actor_name: Optional[str] = None
    actor_role: Optional[str] = None
    quantity_affected: Optional[float] = Field(None, ge=0)
    unit_of_measure: Optional[str] = None
    environmental_conditions: Optional[Dict[str, Any]] = None
    equipment_used: Optional[str] = None
    materials_used: Optional[List[str]] = None
    quality_parameters: Optional[Dict[str, Any]] = None
    compliance_status: Optional[str] = None
    certifications_applied: Optional[List[str]] = None
    cost: Optional[float] = Field(None, ge=0)
    currency: str = Field("KES", min_length=3, max_length=3)
    duration_minutes: Optional[int] = Field(None, gt=0)
    weather_conditions: Optional[Dict[str, Any]] = None
    photos: Optional[List[str]] = None
    documents: Optional[List[str]] = None
    verification_status: Optional[str] = None
    verified_by: Optional[str] = None
    verification_date: Optional[datetime] = None
    notes: Optional[str] = None


class SupplyChainEventCreate(SupplyChainEventBase):
    batch_id: int
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)


class SupplyChainEventUpdate(BaseModel):
    description: Optional[str] = Field(None, min_length=1)
    quantity_affected: Optional[float] = Field(None, ge=0)
    quality_parameters: Optional[Dict[str, Any]] = None
    cost: Optional[float] = Field(None, ge=0)
    photos: Optional[List[str]] = None
    documents: Optional[List[str]] = None
    verification_status: Optional[str] = None
    verified_by: Optional[str] = None
    verification_date: Optional[datetime] = None
    notes: Optional[str] = None


class SupplyChainEventResponse(SupplyChainEventBase):
    id: int
    batch_id: int
    recorded_by: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    event_sequence: Optional[int] = None
    previous_event_id: Optional[int] = None
    next_event_id: Optional[int] = None
    blockchain_transaction_id: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Traceability Schemas
class TraceabilityRequest(BaseModel):
    batch_number: Optional[str] = None
    product_code: Optional[str] = None
    traceability_code: Optional[str] = None
    include_events: bool = True
    include_quality_data: bool = True
    include_certifications: bool = True


class TraceabilityResponse(BaseModel):
    batch_info: Dict[str, Any]
    product_info: Dict[str, Any]
    farm_info: Dict[str, Any]
    producer_info: Dict[str, Any]
    supply_chain_events: List[Dict[str, Any]]
    quality_history: List[Dict[str, Any]]
    certifications: List[Dict[str, Any]]
    current_location: Optional[Dict[str, Any]] = None
    journey_summary: Dict[str, Any]
    compliance_status: str
    verification_score: float = Field(..., ge=0, le=100)


# Quality Control Schemas
class QualityTestBase(BaseModel):
    test_type: str = Field(..., min_length=1, max_length=100)
    test_date: datetime
    laboratory: Optional[str] = None
    test_method: Optional[str] = None
    sample_size: Optional[float] = Field(None, gt=0)
    test_parameters: Dict[str, Any]
    test_results: Dict[str, Any]
    pass_fail_status: str = Field(..., regex="^(pass|fail|conditional)$")
    quality_score: Optional[float] = Field(None, ge=0, le=100)
    defects_found: Optional[List[str]] = None
    corrective_actions: Optional[List[str]] = None
    retest_required: bool = False
    retest_date: Optional[datetime] = None
    test_cost: Optional[float] = Field(None, ge=0)
    currency: str = Field("KES", min_length=3, max_length=3)
    tester_name: Optional[str] = None
    tester_certification: Optional[str] = None
    test_report_url: Optional[str] = None
    notes: Optional[str] = None


class QualityTestCreate(QualityTestBase):
    batch_id: int


class QualityTestUpdate(BaseModel):
    test_results: Optional[Dict[str, Any]] = None
    pass_fail_status: Optional[str] = Field(None, regex="^(pass|fail|conditional)$")
    quality_score: Optional[float] = Field(None, ge=0, le=100)
    defects_found: Optional[List[str]] = None
    corrective_actions: Optional[List[str]] = None
    retest_required: Optional[bool] = None
    retest_date: Optional[datetime] = None
    test_report_url: Optional[str] = None
    notes: Optional[str] = None


class QualityTestResponse(QualityTestBase):
    id: int
    batch_id: int
    conducted_by: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Certification Schemas
class CertificationBase(BaseModel):
    certification_type: str = Field(..., min_length=1, max_length=100)
    certification_body: str = Field(..., min_length=1, max_length=200)
    certificate_number: str = Field(..., min_length=1, max_length=100)
    issue_date: datetime
    expiry_date: datetime
    scope: Optional[str] = None
    standards_met: Optional[List[str]] = None
    audit_date: Optional[datetime] = None
    auditor_name: Optional[str] = None
    audit_score: Optional[float] = Field(None, ge=0, le=100)
    conditions: Optional[List[str]] = None
    certificate_url: Optional[str] = None
    verification_url: Optional[str] = None
    cost: Optional[float] = Field(None, ge=0)
    currency: str = Field("KES", min_length=3, max_length=3)
    renewal_required: bool = True
    renewal_reminder_days: Optional[int] = Field(None, gt=0)

    @validator('expiry_date')
    def validate_expiry_date(cls, v, values):
        if 'issue_date' in values and v <= values['issue_date']:
            raise ValueError('Expiry date must be after issue date')
        return v


class CertificationCreate(CertificationBase):
    product_id: Optional[int] = None
    batch_id: Optional[int] = None
    farm_id: Optional[int] = None


class CertificationUpdate(BaseModel):
    expiry_date: Optional[datetime] = None
    audit_score: Optional[float] = Field(None, ge=0, le=100)
    conditions: Optional[List[str]] = None
    certificate_url: Optional[str] = None
    verification_url: Optional[str] = None
    renewal_required: Optional[bool] = None


class CertificationResponse(CertificationBase):
    id: int
    product_id: Optional[int] = None
    batch_id: Optional[int] = None
    farm_id: Optional[int] = None
    holder_id: int
    is_active: bool
    is_verified: bool
    verification_date: Optional[datetime] = None
    days_until_expiry: Optional[int] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Logistics Schemas
class ShipmentBase(BaseModel):
    shipment_number: str = Field(..., min_length=1, max_length=100)
    origin_location: str = Field(..., min_length=1)
    destination_location: str = Field(..., min_length=1)
    planned_departure_date: datetime
    planned_arrival_date: datetime
    actual_departure_date: Optional[datetime] = None
    actual_arrival_date: Optional[datetime] = None
    transport_mode: str = Field(..., min_length=1)
    carrier_name: Optional[str] = None
    vehicle_id: Optional[str] = None
    driver_name: Optional[str] = None
    driver_contact: Optional[str] = None
    total_quantity: float = Field(..., gt=0)
    unit_of_measure: str = Field(..., min_length=1, max_length=50)
    packaging_details: Optional[Dict[str, Any]] = None
    special_handling: Optional[List[str]] = None
    temperature_requirements: Optional[Dict[str, Any]] = None
    humidity_requirements: Optional[Dict[str, Any]] = None
    insurance_coverage: Optional[float] = Field(None, ge=0)
    shipping_cost: Optional[float] = Field(None, ge=0)
    currency: str = Field("KES", min_length=3, max_length=3)
    tracking_number: Optional[str] = None
    customs_documents: Optional[List[str]] = None
    delivery_instructions: Optional[str] = None


class ShipmentCreate(ShipmentBase):
    batch_ids: List[int] = Field(..., min_items=1)
    origin_latitude: Optional[float] = Field(None, ge=-90, le=90)
    origin_longitude: Optional[float] = Field(None, ge=-180, le=180)
    destination_latitude: Optional[float] = Field(None, ge=-90, le=90)
    destination_longitude: Optional[float] = Field(None, ge=-180, le=180)


class ShipmentUpdate(BaseModel):
    actual_departure_date: Optional[datetime] = None
    actual_arrival_date: Optional[datetime] = None
    carrier_name: Optional[str] = None
    vehicle_id: Optional[str] = None
    driver_name: Optional[str] = None
    driver_contact: Optional[str] = None
    shipping_cost: Optional[float] = Field(None, ge=0)
    tracking_number: Optional[str] = None
    delivery_instructions: Optional[str] = None
    status: Optional[str] = None


class ShipmentResponse(ShipmentBase):
    id: int
    batch_ids: List[int]
    shipper_id: int
    origin_latitude: Optional[float] = None
    origin_longitude: Optional[float] = None
    destination_latitude: Optional[float] = None
    destination_longitude: Optional[float] = None
    status: str
    current_location: Optional[Dict[str, Any]] = None
    estimated_arrival: Optional[datetime] = None
    delay_reason: Optional[str] = None
    condition_alerts: Optional[List[str]] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Supply Chain Analytics Schemas
class SupplyChainAnalyticsRequest(BaseModel):
    analysis_type: str = Field(..., regex="^(efficiency|quality|cost|sustainability|traceability)$")
    time_period_months: int = Field(12, ge=1, le=60)
    product_id: Optional[int] = None
    farm_id: Optional[int] = None
    include_benchmarks: bool = False


class SupplyChainEfficiencyAnalysis(BaseModel):
    period: str
    total_batches: int
    average_cycle_time_days: float
    on_time_delivery_percentage: float
    quality_pass_rate: float
    waste_percentage: float
    cost_per_unit: float
    efficiency_score: float = Field(..., ge=0, le=100)
    bottlenecks: List[str]
    improvement_opportunities: List[str]
    recommendations: List[str]


class QualityTrendAnalysis(BaseModel):
    period: str
    average_quality_score: float
    quality_trend: str
    defect_rates: Dict[str, float]
    most_common_defects: List[str]
    quality_improvement_areas: List[str]
    certification_compliance_rate: float
    recommendations: List[str]


# Supply Chain Statistics
class SupplyChainStatistics(BaseModel):
    total_products: int
    active_batches: int
    total_events_recorded: int
    average_traceability_score: float
    quality_pass_rate: float
    on_time_delivery_rate: float
    active_certifications: int
    expired_certifications: int
    total_shipments: int
    in_transit_shipments: int
    average_supply_chain_duration_days: float
    sustainability_score: float = Field(..., ge=0, le=100)