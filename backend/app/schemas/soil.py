from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class SoilTestTypeEnum(str, Enum):
    BASIC = "basic"
    COMPREHENSIVE = "comprehensive"
    NUTRIENT_SPECIFIC = "nutrient_specific"
    MICRONUTRIENT = "micronutrient"
    ORGANIC_MATTER = "organic_matter"
    CONTAMINATION = "contamination"


class SoilTextureEnum(str, Enum):
    SAND = "sand"
    LOAMY_SAND = "loamy_sand"
    SANDY_LOAM = "sandy_loam"
    LOAM = "loam"
    SILT_LOAM = "silt_loam"
    SILT = "silt"
    CLAY_LOAM = "clay_loam"
    SILTY_CLAY_LOAM = "silty_clay_loam"
    SANDY_CLAY = "sandy_clay"
    SILTY_CLAY = "silty_clay"
    CLAY = "clay"


class DrainageClassEnum(str, Enum):
    VERY_POOR = "very_poor"
    POOR = "poor"
    SOMEWHAT_POOR = "somewhat_poor"
    MODERATE = "moderate"
    WELL_DRAINED = "well_drained"
    SOMEWHAT_EXCESSIVE = "somewhat_excessive"
    EXCESSIVE = "excessive"


# Soil Test Schemas
class SoilTestBase(BaseModel):
    test_type: SoilTestTypeEnum
    test_date: datetime
    laboratory: Optional[str] = None
    lab_reference_number: Optional[str] = None
    sampling_depth_cm: Optional[float] = Field(None, gt=0)
    sample_description: Optional[str] = None
    sampling_method: Optional[str] = None
    soil_texture: Optional[SoilTextureEnum] = None
    sand_percentage: Optional[float] = Field(None, ge=0, le=100)
    silt_percentage: Optional[float] = Field(None, ge=0, le=100)
    clay_percentage: Optional[float] = Field(None, ge=0, le=100)
    bulk_density: Optional[float] = Field(None, gt=0)
    porosity_percentage: Optional[float] = Field(None, ge=0, le=100)
    water_holding_capacity: Optional[float] = Field(None, ge=0)
    drainage_class: Optional[DrainageClassEnum] = None
    ph_level: Optional[float] = Field(None, ge=0, le=14)
    ph_method: Optional[str] = None
    electrical_conductivity: Optional[float] = Field(None, ge=0)
    organic_matter_percentage: Optional[float] = Field(None, ge=0, le=100)
    organic_carbon_percentage: Optional[float] = Field(None, ge=0, le=100)
    cation_exchange_capacity: Optional[float] = Field(None, ge=0)
    nitrogen_total: Optional[float] = Field(None, ge=0)
    nitrogen_available: Optional[float] = Field(None, ge=0)
    phosphorus_available: Optional[float] = Field(None, ge=0)
    phosphorus_total: Optional[float] = Field(None, ge=0)
    potassium_available: Optional[float] = Field(None, ge=0)
    potassium_total: Optional[float] = Field(None, ge=0)
    calcium: Optional[float] = Field(None, ge=0)
    magnesium: Optional[float] = Field(None, ge=0)
    sulfur: Optional[float] = Field(None, ge=0)
    iron: Optional[float] = Field(None, ge=0)
    manganese: Optional[float] = Field(None, ge=0)
    zinc: Optional[float] = Field(None, ge=0)
    copper: Optional[float] = Field(None, ge=0)
    boron: Optional[float] = Field(None, ge=0)
    molybdenum: Optional[float] = Field(None, ge=0)
    chlorine: Optional[float] = Field(None, ge=0)
    test_cost: Optional[float] = Field(None, ge=0)
    currency: str = Field("KES", min_length=3, max_length=3)

    @validator('sand_percentage', 'silt_percentage', 'clay_percentage')
    def validate_texture_percentages(cls, v, values):
        # Ensure texture percentages add up to approximately 100%
        if all(key in values for key in ['sand_percentage', 'silt_percentage']) and v is not None:
            total = sum(filter(None, [values.get('sand_percentage'), values.get('silt_percentage'), v]))
            if total > 105:  # Allow some tolerance
                raise ValueError('Texture percentages cannot exceed 100%')
        return v


class SoilTestCreate(SoilTestBase):
    farm_id: int
    field_id: Optional[int] = None
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)


class SoilTestUpdate(BaseModel):
    laboratory: Optional[str] = None
    lab_reference_number: Optional[str] = None
    ph_level: Optional[float] = Field(None, ge=0, le=14)
    organic_matter_percentage: Optional[float] = Field(None, ge=0, le=100)
    nitrogen_available: Optional[float] = Field(None, ge=0)
    phosphorus_available: Optional[float] = Field(None, ge=0)
    potassium_available: Optional[float] = Field(None, ge=0)
    overall_fertility_rating: Optional[str] = None
    limiting_factors: Optional[List[str]] = None
    soil_health_score: Optional[float] = Field(None, ge=0, le=100)
    quality_control_passed: Optional[bool] = None
    retest_required: Optional[bool] = None


class SoilTestResponse(SoilTestBase):
    id: int
    farm_id: int
    field_id: Optional[int] = None
    user_id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    exchangeable_calcium: Optional[float] = None
    exchangeable_magnesium: Optional[float] = None
    exchangeable_potassium: Optional[float] = None
    exchangeable_sodium: Optional[float] = None
    exchangeable_aluminum: Optional[float] = None
    exchangeable_hydrogen: Optional[float] = None
    calcium_saturation: Optional[float] = None
    magnesium_saturation: Optional[float] = None
    potassium_saturation: Optional[float] = None
    sodium_saturation: Optional[float] = None
    base_saturation_total: Optional[float] = None
    lead: Optional[float] = None
    cadmium: Optional[float] = None
    mercury: Optional[float] = None
    arsenic: Optional[float] = None
    chromium: Optional[float] = None
    nickel: Optional[float] = None
    microbial_biomass: Optional[float] = None
    soil_respiration: Optional[float] = None
    enzyme_activity: Optional[Dict[str, Any]] = None
    overall_fertility_rating: Optional[str] = None
    limiting_factors: Optional[List[str]] = None
    soil_health_score: Optional[float] = None
    test_accuracy: Optional[str] = None
    quality_control_passed: bool
    retest_required: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Soil Recommendation Schemas
class SoilRecommendationBase(BaseModel):
    target_crop: Optional[str] = None
    lime_requirement_kg_per_ha: Optional[float] = Field(None, ge=0)
    lime_type: Optional[str] = None
    target_ph: Optional[float] = Field(None, ge=0, le=14)
    lime_application_timing: Optional[str] = None
    nitrogen_kg_per_ha: Optional[float] = Field(None, ge=0)
    phosphorus_kg_per_ha: Optional[float] = Field(None, ge=0)
    potassium_kg_per_ha: Optional[float] = Field(None, ge=0)
    calcium_kg_per_ha: Optional[float] = Field(None, ge=0)
    magnesium_kg_per_ha: Optional[float] = Field(None, ge=0)
    sulfur_kg_per_ha: Optional[float] = Field(None, ge=0)
    micronutrient_recommendations: Optional[Dict[str, Any]] = None
    organic_matter_target_percentage: Optional[float] = Field(None, ge=0, le=100)
    compost_recommendation_tons_per_ha: Optional[float] = Field(None, ge=0)
    manure_recommendation_tons_per_ha: Optional[float] = Field(None, ge=0)
    green_manure_recommendations: Optional[List[str]] = None
    recommended_fertilizers: Optional[List[Dict[str, Any]]] = None
    application_schedule: Optional[Dict[str, Any]] = None
    application_methods: Optional[Dict[str, Any]] = None
    tillage_recommendations: Optional[List[str]] = None
    cover_crop_recommendations: Optional[List[str]] = None
    crop_rotation_suggestions: Optional[List[str]] = None
    water_management_advice: Optional[str] = None
    expected_yield_increase_percentage: Optional[float] = Field(None, ge=0)
    expected_soil_improvement_timeline: Optional[str] = None
    monitoring_schedule: Optional[Dict[str, Any]] = None
    total_input_cost: Optional[float] = Field(None, ge=0)
    expected_additional_revenue: Optional[float] = Field(None, ge=0)
    return_on_investment: Optional[float] = None
    payback_period_months: Optional[int] = Field(None, gt=0)
    priority_level: Optional[str] = None
    implementation_order: Optional[List[str]] = None
    environmental_impact: Optional[str] = None
    sustainability_rating: Optional[str] = None
    long_term_soil_health_impact: Optional[str] = None
    requires_retest_after_months: Optional[int] = Field(None, gt=0)


class SoilRecommendationCreate(SoilRecommendationBase):
    soil_test_id: int
    crop_id: Optional[int] = None


class SoilRecommendationUpdate(BaseModel):
    target_crop: Optional[str] = None
    lime_requirement_kg_per_ha: Optional[float] = Field(None, ge=0)
    nitrogen_kg_per_ha: Optional[float] = Field(None, ge=0)
    phosphorus_kg_per_ha: Optional[float] = Field(None, ge=0)
    potassium_kg_per_ha: Optional[float] = Field(None, ge=0)
    total_input_cost: Optional[float] = Field(None, ge=0)
    expected_additional_revenue: Optional[float] = Field(None, ge=0)
    priority_level: Optional[str] = None


class SoilRecommendationResponse(SoilRecommendationBase):
    id: int
    soil_test_id: int
    crop_id: Optional[int] = None
    valid_until: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Fertilizer Application Schemas
class FertilizerApplicationBase(BaseModel):
    application_date: datetime
    fertilizer_type: str = Field(..., min_length=1, max_length=200)
    fertilizer_grade: Optional[str] = None
    brand: Optional[str] = None
    quantity_kg: float = Field(..., gt=0)
    area_applied_ha: float = Field(..., gt=0)
    application_method: Optional[str] = None
    equipment_used: Optional[str] = None
    incorporation_method: Optional[str] = None
    weather_conditions: Optional[Dict[str, Any]] = None
    soil_moisture_condition: Optional[str] = None
    temperature_at_application: Optional[float] = None
    fertilizer_cost: Optional[float] = Field(None, ge=0)
    application_cost: Optional[float] = Field(None, ge=0)
    currency: str = Field("KES", min_length=3, max_length=3)
    crop_response_observed: Optional[bool] = None
    response_description: Optional[str] = None
    yield_impact: Optional[float] = None
    quality_impact: Optional[str] = None
    application_issues: Optional[str] = None
    crop_damage_observed: bool = False
    environmental_concerns: Optional[str] = None
    follow_up_required: bool = False
    follow_up_date: Optional[datetime] = None
    follow_up_notes: Optional[str] = None
    notes: Optional[str] = None


class FertilizerApplicationCreate(FertilizerApplicationBase):
    field_id: int
    recommendation_id: Optional[int] = None


class FertilizerApplicationUpdate(BaseModel):
    crop_response_observed: Optional[bool] = None
    response_description: Optional[str] = None
    yield_impact: Optional[float] = None
    quality_impact: Optional[str] = None
    application_issues: Optional[str] = None
    crop_damage_observed: Optional[bool] = None
    environmental_concerns: Optional[str] = None
    follow_up_required: Optional[bool] = None
    follow_up_date: Optional[datetime] = None
    follow_up_notes: Optional[str] = None
    notes: Optional[str] = None


class FertilizerApplicationResponse(FertilizerApplicationBase):
    id: int
    field_id: int
    user_id: int
    recommendation_id: Optional[int] = None
    rate_kg_per_ha: Optional[float] = None
    total_cost: Optional[float] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Soil Monitoring Schemas
class SoilMonitoringBase(BaseModel):
    monitoring_date: datetime
    monitoring_type: Optional[str] = None
    soil_color: Optional[str] = None
    soil_structure: Optional[str] = None
    compaction_level: Optional[str] = None
    erosion_signs: Optional[str] = None
    organic_matter_visible: Optional[str] = None
    earthworm_count: Optional[int] = Field(None, ge=0)
    root_development: Optional[str] = None
    microbial_activity_signs: Optional[str] = None
    beneficial_insects_present: Optional[bool] = None
    penetration_resistance: Optional[float] = Field(None, ge=0)
    infiltration_rate: Optional[float] = Field(None, ge=0)
    surface_crusting: bool = False
    ph_field_test: Optional[float] = Field(None, ge=0, le=14)
    conductivity_field_test: Optional[float] = Field(None, ge=0)
    nitrate_quick_test: Optional[str] = None
    plant_vigor: Optional[str] = None
    nutrient_deficiency_symptoms: Optional[List[str]] = None
    pest_disease_pressure: Optional[str] = None
    recent_weather_impact: Optional[str] = None
    irrigation_status: Optional[str] = None
    traffic_compaction: bool = False
    soil_health_rating: Optional[str] = None
    improvement_needed: bool = False
    urgent_action_required: bool = False
    immediate_actions: Optional[List[str]] = None
    long_term_recommendations: Optional[List[str]] = None
    next_monitoring_date: Optional[datetime] = None
    photo_urls: Optional[List[str]] = None
    notes: Optional[str] = None


class SoilMonitoringCreate(SoilMonitoringBase):
    field_id: int
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)


class SoilMonitoringUpdate(BaseModel):
    soil_health_rating: Optional[str] = None
    improvement_needed: Optional[bool] = None
    urgent_action_required: Optional[bool] = None
    immediate_actions: Optional[List[str]] = None
    long_term_recommendations: Optional[List[str]] = None
    next_monitoring_date: Optional[datetime] = None
    notes: Optional[str] = None


class SoilMonitoringResponse(SoilMonitoringBase):
    id: int
    field_id: int
    user_id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    created_at: datetime

    class Config:
        from_attributes = True


# Soil Health Index Schemas
class SoilHealthIndexBase(BaseModel):
    calculation_date: datetime
    chemical_score: Optional[float] = Field(None, ge=0, le=100)
    physical_score: Optional[float] = Field(None, ge=0, le=100)
    biological_score: Optional[float] = Field(None, ge=0, le=100)
    ph_score: Optional[float] = Field(None, ge=0, le=100)
    organic_matter_score: Optional[float] = Field(None, ge=0, le=100)
    nutrient_balance_score: Optional[float] = Field(None, ge=0, le=100)
    cation_exchange_score: Optional[float] = Field(None, ge=0, le=100)
    bulk_density_score: Optional[float] = Field(None, ge=0, le=100)
    water_holding_capacity_score: Optional[float] = Field(None, ge=0, le=100)
    aggregate_stability_score: Optional[float] = Field(None, ge=0, le=100)
    infiltration_score: Optional[float] = Field(None, ge=0, le=100)
    microbial_biomass_score: Optional[float] = Field(None, ge=0, le=100)
    enzyme_activity_score: Optional[float] = Field(None, ge=0, le=100)
    earthworm_score: Optional[float] = Field(None, ge=0, le=100)
    root_health_score: Optional[float] = Field(None, ge=0, le=100)
    overall_soil_health_index: float = Field(..., ge=0, le=100)
    health_category: Optional[str] = None
    trend_direction: Optional[str] = None
    change_rate: Optional[float] = None
    regional_percentile: Optional[float] = Field(None, ge=0, le=100)
    crop_specific_rating: Optional[str] = None
    primary_limiting_factor: Optional[str] = None
    secondary_limiting_factors: Optional[List[str]] = None
    improvement_potential: Optional[float] = Field(None, ge=0)
    calculation_method: Optional[str] = None
    data_sources: Optional[List[str]] = None
    confidence_level: Optional[float] = Field(None, ge=0, le=1)


class SoilHealthIndexCreate(SoilHealthIndexBase):
    field_id: int


class SoilHealthIndexResponse(SoilHealthIndexBase):
    id: int
    field_id: int
    created_at: datetime

    class Config:
        from_attributes = True


# Soil Analysis Request Schemas
class SoilAnalysisRequest(BaseModel):
    field_id: Optional[int] = None
    farm_id: Optional[int] = None
    analysis_type: str = Field(..., regex="^(fertility|health|trend|comparison)$")
    time_period_months: int = Field(12, ge=1, le=120)
    include_recommendations: bool = True
    crop_type: Optional[str] = None


class SoilTrendAnalysis(BaseModel):
    field_id: int
    analysis_period: str
    ph_trend: Dict[str, Any]
    organic_matter_trend: Dict[str, Any]
    nutrient_trends: Dict[str, Any]
    soil_health_trend: Dict[str, Any]
    improvement_areas: List[str]
    recommendations: List[str]
    confidence_score: float = Field(..., ge=0, le=1)


# Soil Statistics
class SoilStatistics(BaseModel):
    total_soil_tests: int
    recent_tests_30_days: int
    average_ph: Optional[float] = None
    average_organic_matter: Optional[float] = None
    average_soil_health_score: Optional[float] = None
    fields_needing_lime: int
    fields_needing_fertilizer: int
    total_fertilizer_applications: int
    average_fertilizer_cost_per_ha: Optional[float] = None
    soil_health_distribution: Dict[str, int]
    most_common_limiting_factors: List[Dict[str, Any]]