from pydantic import BaseModel, EmailStr, validator
from typing import Optional, List
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    phone_number: Optional[str] = None


class UserCreate(UserBase):
    password: str
    first_name: str
    last_name: str
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        return v


class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None


class UserProfileUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    date_of_birth: Optional[datetime] = None
    gender: Optional[str] = None
    country: Optional[str] = None
    region: Optional[str] = None
    district: Optional[str] = None
    village: Optional[str] = None
    address: Optional[str] = None
    farming_experience_years: Optional[int] = None
    primary_crops: Optional[List[str]] = None
    farm_size_hectares: Optional[float] = None
    farming_type: Optional[str] = None
    preferred_language: Optional[str] = None
    sms_notifications: Optional[bool] = None
    email_notifications: Optional[bool] = None
    push_notifications: Optional[bool] = None
    bio: Optional[str] = None


class UserProfileResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    date_of_birth: Optional[datetime]
    gender: Optional[str]
    country: Optional[str]
    region: Optional[str]
    district: Optional[str]
    village: Optional[str]
    address: Optional[str]
    farming_experience_years: Optional[int]
    primary_crops: Optional[List[str]]
    farm_size_hectares: Optional[float]
    farming_type: Optional[str]
    preferred_language: str
    sms_notifications: bool
    email_notifications: bool
    push_notifications: bool
    profile_completion_percentage: int
    identity_verified: bool
    avatar_url: Optional[str]
    bio: Optional[str]
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class UserResponse(BaseModel):
    id: int
    email: str
    phone_number: Optional[str]
    is_active: bool
    is_verified: bool
    created_at: datetime
    last_login: Optional[datetime]
    profile: Optional[UserProfileResponse]
    
    class Config:
        from_attributes = True