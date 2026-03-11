from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float, JSON, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from app.database import Base
import enum


class DiseaseCategory(enum.Enum):
    FUNGAL = "fungal"
    BACTERIAL = "bacterial"
    VIRAL = "viral"
    PEST = "pest"
    NUTRITIONAL = "nutritional"
    ENVIRONMENTAL = "environmental"
    UNKNOWN = "unknown"


class DiseaseSeverity(enum.Enum):
    NONE = "none"
    MILD = "mild"
    MODERATE = "moderate"
    SEVERE = "severe"
    CRITICAL = "critical"


class DetectionStatus(enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    EXPERT_REVIEW = "expert_review"
    VERIFIED = "verified"


class TreatmentStatus(enum.Enum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    PARTIALLY_EFFECTIVE = "partially_effective"
    INEFFECTIVE = "ineffective"


class DiseaseType(Base):
    __tablename__ = "disease_types"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    scientific_name = Column(String(200))
    common_names = Column(JSON)  # List of common names in different languages
    category = Column(Enum(DiseaseCategory), nullable=False)
    
    # Affected crops
    affected_crops = Column(JSON)  # List of crop types this disease affects
    primary_hosts = Column(JSON)  # Primary host plants
    secondary_hosts = Column(JSON)  # Secondary host plants
    
    # Disease characteristics
    pathogen_type = Column(String(100))
    transmission_method = Column(JSON)  # airborne, soil-borne, vector, etc.
    survival_conditions = Column(Text)
    
    # Environmental conditions favoring disease
    optimal_temperature_min = Column(Float)
    optimal_temperature_max = Column(Float)
    optimal_humidity_min = Column(Float)
    optimal_humidity_max = Column(Float)
    rainfall_correlation = Column(String(50))  # positive, negative, neutral
    
    # Symptoms and identification
    early_symptoms = Column(JSON)  # List of early symptoms
    advanced_symptoms = Column(JSON)  # List of advanced symptoms
    diagnostic_features = Column(JSON)  # Key diagnostic features
    similar_diseases = Column(JSON)  # IDs of similar diseases for differential diagnosis
    
    # Economic impact
    yield_loss_percentage_min = Column(Float)
    yield_loss_percentage_max = Column(Float)
    quality_impact = Column(String(100))
    economic_threshold = Column(Float)
    
    # Management information
    prevention_methods = Column(JSON)
    cultural_controls = Column(JSON)
    biological_controls = Column(JSON)
    chemical_controls = Column(JSON)
    integrated_management = Column(Text)
    
    # Resistance and varieties
    resistant_varieties = Column(JSON)
    tolerance_levels = Column(JSON)
    
    # Geographic distribution
    endemic_regions = Column(JSON)
    seasonal_occurrence = Column(JSON)
    
    # References and resources
    reference_images = Column(JSON)  # URLs to reference images
    research_papers = Column(JSON)
    extension_materials = Column(JSON)
    
    # Metadata
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    detections = relationship("DiseaseDetection", back_populates="disease_type")
    treatment_recommendations = relationship("TreatmentRecommendation", back_populates="disease_type")


class DiseaseDetection(Base):
    __tablename__ = "disease_detections"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    crop_id = Column(Integer, ForeignKey("crops.id"))
    field_id = Column(Integer, ForeignKey("fields.id"))
    
    # Image information
    image_url = Column(String(500), nullable=False)
    image_filename = Column(String(200))
    image_size_bytes = Column(Integer)
    image_format = Column(String(10))
    image_dimensions = Column(String(20))  # "width x height"
    
    # Location information
    location = Column(Geometry('POINT'))
    location_accuracy_meters = Column(Float)
    altitude_meters = Column(Float)
    
    # Environmental conditions at time of detection
    temperature = Column(Float)
    humidity = Column(Float)
    weather_condition = Column(String(100))
    
    # AI/ML Analysis Results
    ai_predictions = Column(JSON)  # List of predictions with confidence scores
    primary_prediction_id = Column(Integer, ForeignKey("disease_types.id"))
    confidence_score = Column(Float)  # 0-1
    severity_assessment = Column(Enum(DiseaseSeverity))
    
    # Image analysis metadata
    model_version = Column(String(50))
    processing_time_seconds = Column(Float)
    image_quality_score = Column(Float)  # 0-1
    
    # Expert verification
    expert_verified = Column(Boolean, default=False)
    expert_id = Column(Integer, ForeignKey("users.id"))
    expert_diagnosis = Column(Integer, ForeignKey("disease_types.id"))
    expert_confidence = Column(Float)
    expert_notes = Column(Text)
    expert_verified_at = Column(DateTime)
    
    # User feedback
    user_confirmed = Column(Boolean)
    user_feedback = Column(Text)
    user_reported_symptoms = Column(JSON)
    
    # Treatment tracking
    treatment_applied = Column(Boolean, default=False)
    treatment_type = Column(String(200))
    treatment_date = Column(DateTime)
    treatment_effectiveness = Column(Enum(TreatmentStatus))
    treatment_notes = Column(Text)
    
    # Follow-up information
    follow_up_required = Column(Boolean, default=False)
    follow_up_date = Column(DateTime)
    follow_up_notes = Column(Text)
    recovery_status = Column(String(100))
    
    # Detection status and workflow
    status = Column(Enum(DetectionStatus), default=DetectionStatus.PENDING)
    priority_level = Column(String(50), default="normal")  # low, normal, high, urgent
    
    # Economic impact estimation
    estimated_affected_area_m2 = Column(Float)
    estimated_yield_loss_kg = Column(Float)
    estimated_economic_loss = Column(Float)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    expert = relationship("User", foreign_keys=[expert_id])
    crop = relationship("Crop", back_populates="disease_detections")
    field = relationship("Field")
    disease_type = relationship("DiseaseType", foreign_keys=[primary_prediction_id], back_populates="detections")
    expert_disease_type = relationship("DiseaseType", foreign_keys=[expert_diagnosis])
    treatment_recommendations = relationship("TreatmentRecommendation", back_populates="detection")
    follow_up_detections = relationship("DiseaseDetectionFollowUp", back_populates="original_detection")


class DiseaseDetectionFollowUp(Base):
    __tablename__ = "disease_detection_followups"
    
    id = Column(Integer, primary_key=True, index=True)
    original_detection_id = Column(Integer, ForeignKey("disease_detections.id"), nullable=False)
    follow_up_detection_id = Column(Integer, ForeignKey("disease_detections.id"))
    
    # Follow-up details
    follow_up_date = Column(DateTime, nullable=False)
    follow_up_type = Column(String(100))  # treatment_check, progress_monitoring, final_assessment
    
    # Progress assessment
    disease_progression = Column(String(100))  # improved, stable, worsened, resolved
    treatment_effectiveness = Column(Enum(TreatmentStatus))
    new_symptoms_observed = Column(JSON)
    
    # Recommendations
    continue_treatment = Column(Boolean)
    modify_treatment = Column(Boolean)
    additional_treatments = Column(JSON)
    
    # Notes
    observations = Column(Text)
    farmer_feedback = Column(Text)
    expert_notes = Column(Text)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    original_detection = relationship("DiseaseDetection", foreign_keys=[original_detection_id], back_populates="follow_up_detections")
    follow_up_detection = relationship("DiseaseDetection", foreign_keys=[follow_up_detection_id])


class TreatmentRecommendation(Base):
    __tablename__ = "treatment_recommendations"
    
    id = Column(Integer, primary_key=True, index=True)
    disease_type_id = Column(Integer, ForeignKey("disease_types.id"), nullable=False)
    detection_id = Column(Integer, ForeignKey("disease_detections.id"))
    
    # Treatment details
    treatment_name = Column(String(200), nullable=False)
    treatment_type = Column(String(100))  # cultural, biological, chemical, integrated
    active_ingredients = Column(JSON)  # For chemical treatments
    
    # Application details
    application_method = Column(String(100))
    dosage = Column(String(200))
    frequency = Column(String(100))
    timing = Column(String(200))
    duration = Column(String(100))
    
    # Conditions and precautions
    weather_conditions = Column(Text)
    safety_precautions = Column(JSON)
    protective_equipment = Column(JSON)
    
    # Effectiveness and resistance
    effectiveness_rating = Column(Float)  # 0-1
    resistance_risk = Column(String(50))  # low, moderate, high
    resistance_management = Column(Text)
    
    # Economic considerations
    cost_per_hectare = Column(Float)
    cost_effectiveness_ratio = Column(Float)
    availability = Column(String(100))
    
    # Environmental impact
    environmental_impact = Column(String(100))  # low, moderate, high
    beneficial_insect_impact = Column(String(100))
    soil_impact = Column(String(100))
    water_impact = Column(String(100))
    
    # Regulatory information
    registration_status = Column(String(100))
    restricted_use = Column(Boolean, default=False)
    pre_harvest_interval_days = Column(Integer)
    re_entry_interval_hours = Column(Integer)
    
    # Alternative treatments
    alternative_treatments = Column(JSON)  # IDs of alternative treatment recommendations
    
    # Success tracking
    success_rate_percentage = Column(Float)
    user_satisfaction_rating = Column(Float)
    
    # Metadata
    is_recommended = Column(Boolean, default=True)
    recommendation_confidence = Column(Float)  # 0-1
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    disease_type = relationship("DiseaseType", back_populates="treatment_recommendations")
    detection = relationship("DiseaseDetection", back_populates="treatment_recommendations")
    applications = relationship("TreatmentApplication", back_populates="recommendation")


class TreatmentApplication(Base):
    __tablename__ = "treatment_applications"
    
    id = Column(Integer, primary_key=True, index=True)
    detection_id = Column(Integer, ForeignKey("disease_detections.id"), nullable=False)
    recommendation_id = Column(Integer, ForeignKey("treatment_recommendations.id"))
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Application details
    application_date = Column(DateTime, nullable=False)
    treatment_name = Column(String(200), nullable=False)
    dosage_applied = Column(String(200))
    area_treated_m2 = Column(Float)
    
    # Application conditions
    weather_at_application = Column(JSON)
    equipment_used = Column(String(200))
    application_quality = Column(String(50))  # poor, fair, good, excellent
    
    # Costs
    material_cost = Column(Float)
    labor_cost = Column(Float)
    equipment_cost = Column(Float)
    total_cost = Column(Float)
    
    # Effectiveness tracking
    initial_assessment_date = Column(DateTime)
    initial_effectiveness = Column(String(100))
    final_assessment_date = Column(DateTime)
    final_effectiveness = Column(Enum(TreatmentStatus))
    
    # Side effects and issues
    phytotoxicity_observed = Column(Boolean, default=False)
    resistance_observed = Column(Boolean, default=False)
    environmental_issues = Column(Text)
    
    # User feedback
    user_satisfaction = Column(Integer)  # 1-5 rating
    would_recommend = Column(Boolean)
    user_notes = Column(Text)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    detection = relationship("DiseaseDetection")
    recommendation = relationship("TreatmentRecommendation", back_populates="applications")
    user = relationship("User")