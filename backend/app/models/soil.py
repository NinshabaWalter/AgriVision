from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float, JSON, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from app.database import Base
import enum


class SoilTestType(enum.Enum):
    BASIC = "basic"
    COMPREHENSIVE = "comprehensive"
    NUTRIENT_SPECIFIC = "nutrient_specific"
    MICRONUTRIENT = "micronutrient"
    ORGANIC_MATTER = "organic_matter"
    CONTAMINATION = "contamination"


class SoilTexture(enum.Enum):
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


class DrainageClass(enum.Enum):
    VERY_POOR = "very_poor"
    POOR = "poor"
    SOMEWHAT_POOR = "somewhat_poor"
    MODERATE = "moderate"
    WELL_DRAINED = "well_drained"
    SOMEWHAT_EXCESSIVE = "somewhat_excessive"
    EXCESSIVE = "excessive"


class SoilTest(Base):
    __tablename__ = "soil_tests"
    
    id = Column(Integer, primary_key=True, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=False)
    field_id = Column(Integer, ForeignKey("fields.id"))
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Test information
    test_type = Column(Enum(SoilTestType), nullable=False)
    test_date = Column(DateTime, nullable=False)
    laboratory = Column(String(200))
    lab_reference_number = Column(String(100))
    
    # Sample information
    sample_location = Column(Geometry('POINT'))
    sampling_depth_cm = Column(Float)
    sample_description = Column(Text)
    sampling_method = Column(String(100))
    
    # Physical properties
    soil_texture = Column(Enum(SoilTexture))
    sand_percentage = Column(Float)
    silt_percentage = Column(Float)
    clay_percentage = Column(Float)
    bulk_density = Column(Float)
    porosity_percentage = Column(Float)
    water_holding_capacity = Column(Float)
    drainage_class = Column(Enum(DrainageClass))
    
    # Chemical properties
    ph_level = Column(Float)
    ph_method = Column(String(50))  # water, kcl, cacl2
    electrical_conductivity = Column(Float)  # dS/m
    organic_matter_percentage = Column(Float)
    organic_carbon_percentage = Column(Float)
    cation_exchange_capacity = Column(Float)  # cmol/kg
    
    # Major nutrients (mg/kg or ppm)
    nitrogen_total = Column(Float)
    nitrogen_available = Column(Float)
    phosphorus_available = Column(Float)
    phosphorus_total = Column(Float)
    potassium_available = Column(Float)
    potassium_total = Column(Float)
    
    # Secondary nutrients (mg/kg)
    calcium = Column(Float)
    magnesium = Column(Float)
    sulfur = Column(Float)
    
    # Micronutrients (mg/kg)
    iron = Column(Float)
    manganese = Column(Float)
    zinc = Column(Float)
    copper = Column(Float)
    boron = Column(Float)
    molybdenum = Column(Float)
    chlorine = Column(Float)
    
    # Exchangeable cations (cmol/kg)
    exchangeable_calcium = Column(Float)
    exchangeable_magnesium = Column(Float)
    exchangeable_potassium = Column(Float)
    exchangeable_sodium = Column(Float)
    exchangeable_aluminum = Column(Float)
    exchangeable_hydrogen = Column(Float)
    
    # Base saturation percentages
    calcium_saturation = Column(Float)
    magnesium_saturation = Column(Float)
    potassium_saturation = Column(Float)
    sodium_saturation = Column(Float)
    base_saturation_total = Column(Float)
    
    # Heavy metals and contaminants (mg/kg)
    lead = Column(Float)
    cadmium = Column(Float)
    mercury = Column(Float)
    arsenic = Column(Float)
    chromium = Column(Float)
    nickel = Column(Float)
    
    # Biological properties
    microbial_biomass = Column(Float)
    soil_respiration = Column(Float)
    enzyme_activity = Column(JSON)  # Various enzyme activities
    
    # Test results interpretation
    overall_fertility_rating = Column(String(50))  # very_low, low, medium, high, very_high
    limiting_factors = Column(JSON)  # List of limiting factors
    soil_health_score = Column(Float)  # 0-100
    
    # Quality control
    test_accuracy = Column(String(50))
    quality_control_passed = Column(Boolean, default=True)
    retest_required = Column(Boolean, default=False)
    
    # Cost information
    test_cost = Column(Float)
    currency = Column(String(10), default="KES")
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    farm = relationship("Farm", back_populates="soil_tests")
    field = relationship("Field")
    user = relationship("User")
    recommendations = relationship("SoilRecommendation", back_populates="soil_test")


class SoilRecommendation(Base):
    __tablename__ = "soil_recommendations"
    
    id = Column(Integer, primary_key=True, index=True)
    soil_test_id = Column(Integer, ForeignKey("soil_tests.id"), nullable=False)
    crop_id = Column(Integer, ForeignKey("crops.id"))
    target_crop = Column(String(200))  # If crop_id not available
    
    # Lime recommendations
    lime_requirement_kg_per_ha = Column(Float)
    lime_type = Column(String(100))
    target_ph = Column(Float)
    lime_application_timing = Column(String(200))
    
    # Fertilizer recommendations
    nitrogen_kg_per_ha = Column(Float)
    phosphorus_kg_per_ha = Column(Float)
    potassium_kg_per_ha = Column(Float)
    
    # Secondary nutrient recommendations
    calcium_kg_per_ha = Column(Float)
    magnesium_kg_per_ha = Column(Float)
    sulfur_kg_per_ha = Column(Float)
    
    # Micronutrient recommendations
    micronutrient_recommendations = Column(JSON)  # Detailed micronutrient needs
    
    # Organic matter recommendations
    organic_matter_target_percentage = Column(Float)
    compost_recommendation_tons_per_ha = Column(Float)
    manure_recommendation_tons_per_ha = Column(Float)
    green_manure_recommendations = Column(JSON)
    
    # Specific fertilizer products
    recommended_fertilizers = Column(JSON)  # List of specific fertilizer products
    application_schedule = Column(JSON)  # Timing and split applications
    application_methods = Column(JSON)  # How to apply each fertilizer
    
    # Soil management practices
    tillage_recommendations = Column(JSON)
    cover_crop_recommendations = Column(JSON)
    crop_rotation_suggestions = Column(JSON)
    water_management_advice = Column(Text)
    
    # Expected outcomes
    expected_yield_increase_percentage = Column(Float)
    expected_soil_improvement_timeline = Column(String(200))
    monitoring_schedule = Column(JSON)
    
    # Economic analysis
    total_input_cost = Column(Float)
    expected_additional_revenue = Column(Float)
    return_on_investment = Column(Float)
    payback_period_months = Column(Integer)
    
    # Implementation priority
    priority_level = Column(String(50))  # critical, high, medium, low
    implementation_order = Column(JSON)  # Sequence of recommended actions
    
    # Sustainability considerations
    environmental_impact = Column(Text)
    sustainability_rating = Column(String(50))
    long_term_soil_health_impact = Column(Text)
    
    # Validity and updates
    valid_until = Column(DateTime)
    requires_retest_after_months = Column(Integer)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    soil_test = relationship("SoilTest", back_populates="recommendations")
    crop = relationship("Crop")
    applications = relationship("FertilizerApplication", back_populates="recommendation")


class FertilizerApplication(Base):
    __tablename__ = "fertilizer_applications"
    
    id = Column(Integer, primary_key=True, index=True)
    recommendation_id = Column(Integer, ForeignKey("soil_recommendations.id"))
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Application details
    application_date = Column(DateTime, nullable=False)
    fertilizer_type = Column(String(200), nullable=False)
    fertilizer_grade = Column(String(50))  # e.g., 20-10-10
    brand = Column(String(100))
    
    # Quantities applied
    quantity_kg = Column(Float, nullable=False)
    area_applied_ha = Column(Float, nullable=False)
    rate_kg_per_ha = Column(Float)
    
    # Application method
    application_method = Column(String(100))  # broadcast, banding, foliar, fertigation
    equipment_used = Column(String(200))
    incorporation_method = Column(String(100))  # plowed, disked, none
    
    # Environmental conditions
    weather_conditions = Column(JSON)
    soil_moisture_condition = Column(String(50))
    temperature_at_application = Column(Float)
    
    # Costs
    fertilizer_cost = Column(Float)
    application_cost = Column(Float)
    total_cost = Column(Float)
    currency = Column(String(10), default="KES")
    
    # Effectiveness tracking
    crop_response_observed = Column(Boolean)
    response_description = Column(Text)
    yield_impact = Column(Float)  # Percentage change
    quality_impact = Column(Text)
    
    # Issues and observations
    application_issues = Column(Text)
    crop_damage_observed = Column(Boolean, default=False)
    environmental_concerns = Column(Text)
    
    # Follow-up
    follow_up_required = Column(Boolean, default=False)
    follow_up_date = Column(DateTime)
    follow_up_notes = Column(Text)
    
    # Metadata
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    recommendation = relationship("SoilRecommendation", back_populates="applications")
    field = relationship("Field")
    user = relationship("User")


class SoilMonitoring(Base):
    __tablename__ = "soil_monitoring"
    
    id = Column(Integer, primary_key=True, index=True)
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Monitoring details
    monitoring_date = Column(DateTime, nullable=False)
    monitoring_type = Column(String(100))  # routine, post_treatment, problem_investigation
    location = Column(Geometry('POINT'))
    
    # Visual observations
    soil_color = Column(String(100))
    soil_structure = Column(String(100))
    compaction_level = Column(String(50))  # none, light, moderate, severe
    erosion_signs = Column(String(100))
    organic_matter_visible = Column(String(50))
    
    # Biological indicators
    earthworm_count = Column(Integer)
    root_development = Column(String(100))
    microbial_activity_signs = Column(Text)
    beneficial_insects_present = Column(Boolean)
    
    # Physical measurements
    penetration_resistance = Column(Float)  # kg/cm²
    infiltration_rate = Column(Float)  # mm/hour
    surface_crusting = Column(Boolean, default=False)
    
    # Quick chemical tests
    ph_field_test = Column(Float)
    conductivity_field_test = Column(Float)
    nitrate_quick_test = Column(String(50))  # low, medium, high
    
    # Crop performance indicators
    plant_vigor = Column(String(50))  # poor, fair, good, excellent
    nutrient_deficiency_symptoms = Column(JSON)
    pest_disease_pressure = Column(String(50))
    
    # Environmental factors
    recent_weather_impact = Column(Text)
    irrigation_status = Column(String(100))
    traffic_compaction = Column(Boolean, default=False)
    
    # Overall assessment
    soil_health_rating = Column(String(50))  # poor, fair, good, excellent
    improvement_needed = Column(Boolean, default=False)
    urgent_action_required = Column(Boolean, default=False)
    
    # Recommendations
    immediate_actions = Column(JSON)
    long_term_recommendations = Column(JSON)
    next_monitoring_date = Column(DateTime)
    
    # Photos and documentation
    photo_urls = Column(JSON)
    notes = Column(Text)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    field = relationship("Field")
    user = relationship("User")


class SoilHealthIndex(Base):
    __tablename__ = "soil_health_indices"
    
    id = Column(Integer, primary_key=True, index=True)
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=False)
    calculation_date = Column(DateTime, nullable=False)
    
    # Component scores (0-100)
    chemical_score = Column(Float)
    physical_score = Column(Float)
    biological_score = Column(Float)
    
    # Individual indicators
    ph_score = Column(Float)
    organic_matter_score = Column(Float)
    nutrient_balance_score = Column(Float)
    cation_exchange_score = Column(Float)
    
    bulk_density_score = Column(Float)
    water_holding_capacity_score = Column(Float)
    aggregate_stability_score = Column(Float)
    infiltration_score = Column(Float)
    
    microbial_biomass_score = Column(Float)
    enzyme_activity_score = Column(Float)
    earthworm_score = Column(Float)
    root_health_score = Column(Float)
    
    # Overall index
    overall_soil_health_index = Column(Float)  # 0-100
    health_category = Column(String(50))  # poor, fair, good, excellent
    
    # Trends
    trend_direction = Column(String(50))  # improving, stable, declining
    change_rate = Column(Float)  # Points per year
    
    # Benchmarking
    regional_percentile = Column(Float)  # How this field compares regionally
    crop_specific_rating = Column(String(50))
    
    # Limiting factors
    primary_limiting_factor = Column(String(200))
    secondary_limiting_factors = Column(JSON)
    improvement_potential = Column(Float)  # Potential points gain
    
    # Metadata
    calculation_method = Column(String(100))
    data_sources = Column(JSON)
    confidence_level = Column(Float)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    field = relationship("Field")