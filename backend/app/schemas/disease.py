from pydantic import BaseModel, validator
from typing import Optional, List, Dict, Any
from datetime import datetime


class DiseaseDetectionCreate(BaseModel):
    crop_id: Optional[int] = None
    image_data: str  # Base64 encoded image
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    
    @validator('image_data')
    def validate_image_data(cls, v):
        if not v or len(v) < 100:  # Basic validation
            raise ValueError('Invalid image data')
        return v


class DiseaseDetectionResponse(BaseModel):
    id: int
    user_id: int
    crop_id: Optional[int]
    disease_type_id: Optional[int]
    image_url: str
    ai_confidence_score: Optional[float]
    ai_predictions: Optional[List[Dict[str, Any]]]
    expert_verified: bool
    expert_diagnosis: Optional[str]
    severity_level: Optional[str]
    affected_area_percentage: Optional[float]
    disease_stage: Optional[str]
    treatment_applied: bool
    treatment_type: Optional[str]
    status: str
    detected_at: datetime
    
    class Config:
        from_attributes = True


class DiseaseTypeResponse(BaseModel):
    id: int
    name: str
    scientific_name: Optional[str]
    common_names: Optional[List[str]]
    category: Optional[str]
    affected_crops: Optional[List[str]]
    symptoms: Optional[List[str]]
    treatment_methods: Optional[List[str]]
    prevention_methods: Optional[List[str]]
    severity_levels: Optional[Dict[str, str]]
    
    class Config:
        from_attributes = True


class DiseaseDetectionUpdate(BaseModel):
    expert_diagnosis: Optional[str] = None
    expert_notes: Optional[str] = None
    severity_level: Optional[str] = None
    treatment_applied: Optional[bool] = None
    treatment_type: Optional[str] = None
    treatment_effectiveness: Optional[str] = None