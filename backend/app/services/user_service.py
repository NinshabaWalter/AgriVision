from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from datetime import datetime

from app.models.user import User, UserProfile
from app.schemas.user import UserCreate, UserUpdate, UserProfileUpdate
from app.core.security import get_password_hash


class UserService:
    def __init__(self, db: Session):
        self.db = db

    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID"""
        return self.db.query(User).filter(User.id == user_id).first()

    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        return self.db.query(User).filter(User.email == email).first()

    def get_user_by_phone(self, phone_number: str) -> Optional[User]:
        """Get user by phone number"""
        return self.db.query(User).filter(User.phone_number == phone_number).first()

    def create_user(self, user_data: UserCreate) -> User:
        """Create a new user with profile"""
        # Create user
        hashed_password = get_password_hash(user_data.password)
        db_user = User(
            email=user_data.email,
            phone_number=user_data.phone_number,
            hashed_password=hashed_password,
            is_active=True,
            is_verified=False
        )
        
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)

        # Create user profile
        db_profile = UserProfile(
            user_id=db_user.id,
            first_name=user_data.first_name,
            last_name=user_data.last_name,
            preferred_language='en',
            sms_notifications=True,
            email_notifications=True,
            push_notifications=True,
            profile_completion_percentage=30  # Basic info completed
        )
        
        self.db.add(db_profile)
        self.db.commit()
        self.db.refresh(db_profile)

        # Refresh user to include profile
        self.db.refresh(db_user)
        return db_user

    def update_user(self, user_id: int, user_data: UserUpdate) -> Optional[User]:
        """Update user information"""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return None

        update_data = user_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_user, field, value)

        db_user.updated_at = func.now()
        self.db.commit()
        self.db.refresh(db_user)
        return db_user

    def update_user_profile(self, user_id: int, profile_data: UserProfileUpdate) -> Optional[UserProfile]:
        """Update user profile information"""
        db_profile = self.db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        if not db_profile:
            return None

        update_data = profile_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            if field == 'primary_crops' and value:
                # Convert list to JSON string
                import json
                setattr(db_profile, field, json.dumps(value))
            else:
                setattr(db_profile, field, value)

        # Update profile completion percentage
        db_profile.profile_completion_percentage = self._calculate_profile_completion(db_profile)
        db_profile.updated_at = func.now()
        
        self.db.commit()
        self.db.refresh(db_profile)
        return db_profile

    def update_last_login(self, user_id: int) -> None:
        """Update user's last login timestamp"""
        db_user = self.get_user_by_id(user_id)
        if db_user:
            db_user.last_login = func.now()
            self.db.commit()

    def update_password(self, user_id: int, new_password: str) -> bool:
        """Update user password"""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return False

        db_user.hashed_password = get_password_hash(new_password)
        db_user.updated_at = func.now()
        self.db.commit()
        return True

    def deactivate_user(self, user_id: int) -> bool:
        """Deactivate a user account"""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return False

        db_user.is_active = False
        db_user.updated_at = func.now()
        self.db.commit()
        return True

    def verify_user(self, user_id: int) -> bool:
        """Mark user as verified"""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return False

        db_user.is_verified = True
        db_user.updated_at = func.now()
        self.db.commit()
        return True

    def _calculate_profile_completion(self, profile: UserProfile) -> int:
        """Calculate profile completion percentage"""
        total_fields = 15  # Total important fields
        completed_fields = 0

        # Check required fields
        if profile.first_name:
            completed_fields += 1
        if profile.last_name:
            completed_fields += 1
        if profile.date_of_birth:
            completed_fields += 1
        if profile.gender:
            completed_fields += 1
        if profile.country:
            completed_fields += 1
        if profile.region:
            completed_fields += 1
        if profile.district:
            completed_fields += 1
        if profile.village:
            completed_fields += 1
        if profile.address:
            completed_fields += 1
        if profile.farming_experience_years:
            completed_fields += 1
        if profile.primary_crops:
            completed_fields += 1
        if profile.farm_size_hectares:
            completed_fields += 1
        if profile.farming_type:
            completed_fields += 1
        if profile.identity_document_type:
            completed_fields += 1
        if profile.identity_document_number:
            completed_fields += 1

        return int((completed_fields / total_fields) * 100)

    def create_demo_user(self) -> User:
        """Create a demo user for testing purposes"""
        # Check if demo user already exists
        existing_user = self.get_user_by_email("farmer@example.com")
        if existing_user:
            return existing_user

        # Create demo user
        demo_user_data = UserCreate(
            email="farmer@example.com",
            password="password123",
            first_name="Demo",
            last_name="Farmer",
            phone_number="+254700000000"
        )

        demo_user = self.create_user(demo_user_data)
        
        # Update profile with more demo data
        demo_profile_data = UserProfileUpdate(
            country="Kenya",
            region="Central",
            district="Kiambu",
            village="Limuru",
            address="Demo Farm, Limuru",
            farming_experience_years=5,
            primary_crops=["maize", "beans", "potatoes"],
            farm_size_hectares=2.5,
            farming_type="mixed",
            preferred_language="en",
            bio="Demo farmer account for testing the AgriVision platform"
        )
        
        self.update_user_profile(demo_user.id, demo_profile_data)
        
        # Mark as verified
        self.verify_user(demo_user.id)
        
        return demo_user