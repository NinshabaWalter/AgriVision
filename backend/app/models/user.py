from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from app.database import Base


class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone_number = Column(String(20), unique=True, index=True)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    last_login = Column(DateTime(timezone=True))
    
    # Relationships
    profile = relationship("UserProfile", back_populates="user", uselist=False)
    farms = relationship("Farm", back_populates="owner")
    loan_applications = relationship("LoanApplication", back_populates="applicant")


class UserProfile(Base):
    __tablename__ = "user_profiles"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    date_of_birth = Column(DateTime)
    gender = Column(String(10))
    
    # Location information
    country = Column(String(100))
    region = Column(String(100))
    district = Column(String(100))
    village = Column(String(100))
    address = Column(Text)
    location = Column(Geometry('POINT'))  # PostGIS point for exact coordinates
    
    # Farming information
    farming_experience_years = Column(Integer)
    primary_crops = Column(Text)  # JSON string of crop types
    farm_size_hectares = Column(Float)
    farming_type = Column(String(50))  # organic, conventional, mixed
    
    # Communication preferences
    preferred_language = Column(String(10), default='en')
    sms_notifications = Column(Boolean, default=True)
    email_notifications = Column(Boolean, default=True)
    push_notifications = Column(Boolean, default=True)
    
    # Profile completion and verification
    profile_completion_percentage = Column(Integer, default=0)
    identity_verified = Column(Boolean, default=False)
    identity_document_type = Column(String(50))
    identity_document_number = Column(String(100))
    
    # Avatar and additional info
    avatar_url = Column(String(500))
    bio = Column(Text)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="profile")