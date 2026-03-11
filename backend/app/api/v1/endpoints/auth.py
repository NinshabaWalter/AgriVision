from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
import json

from app.database import get_db
from app.core.security import authenticate_user, create_access_token, get_current_user
from app.schemas.auth import Token, LoginRequest, PasswordReset, ChangePassword
from app.schemas.user import UserCreate, UserResponse
from app.services.user_service import UserService
from app.services.notification_service import NotificationService
from app.config import settings

router = APIRouter()


def format_user_for_mobile(user):
    """Format user data for mobile app compatibility"""
    # Get user profile data
    profile = user.profile if user.profile else None
    
    # Format name
    name = ""
    if profile:
        name = f"{profile.first_name} {profile.last_name}".strip()
    
    # Format location
    location = ""
    if profile:
        location_parts = []
        if profile.village:
            location_parts.append(profile.village)
        if profile.district:
            location_parts.append(profile.district)
        if profile.region:
            location_parts.append(profile.region)
        location = ", ".join(location_parts)
    
    # Format farm size
    farm_size = ""
    if profile and profile.farm_size_hectares:
        farm_size = f"{profile.farm_size_hectares} hectares"
    
    return {
        "id": user.id,
        "name": name,
        "email": user.email,
        "phone": user.phone_number,
        "location": location,
        "farm_size": farm_size
    }


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    """Register a new user"""
    user_service = UserService(db)
    
    # Check if user already exists
    if user_service.get_user_by_email(user_data.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    if user_data.phone_number and user_service.get_user_by_phone(user_data.phone_number):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered"
        )
    
    # Create user
    user = user_service.create_user(user_data)
    
    # Send welcome notification
    notification_service = NotificationService()
    await notification_service.send_welcome_message(user)
    
    # Create access token for immediate login
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )
    
    # Format response for mobile app compatibility
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
        "user_id": user.id,
        "user": format_user_for_mobile(user)
    }


@router.post("/login")
async def login(
    login_data: LoginRequest,
    db: Session = Depends(get_db)
):
    """Authenticate user and return access token"""
    user = authenticate_user(db, login_data.email, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user account"
        )
    
    # Update last login
    user_service = UserService(db)
    user_service.update_last_login(user.id)
    
    # Create access token
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )
    
    # Format response for mobile app compatibility
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
        "user_id": user.id,
        "user": format_user_for_mobile(user)
    }


@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """OAuth2 compatible token endpoint"""
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_minutes * 60,
        "user_id": user.id
    }


@router.post("/password-reset")
async def request_password_reset(
    reset_data: PasswordReset,
    db: Session = Depends(get_db)
):
    """Request password reset"""
    user_service = UserService(db)
    user = user_service.get_user_by_email(reset_data.email)
    
    if not user:
        # Don't reveal if email exists or not
        return {"message": "If the email exists, a reset link has been sent"}
    
    # Generate reset token and send email
    notification_service = NotificationService()
    await notification_service.send_password_reset(user)
    
    return {"message": "If the email exists, a reset link has been sent"}


@router.post("/change-password")
async def change_password(
    password_data: ChangePassword,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Change user password"""
    user_service = UserService(db)
    
    # Verify current password
    if not authenticate_user(db, current_user.email, password_data.current_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect current password"
        )
    
    # Update password
    user_service.update_password(current_user.id, password_data.new_password)
    
    return {"message": "Password updated successfully"}


@router.post("/logout")
async def logout(current_user = Depends(get_current_user)):
    """Logout user (client should discard token)"""
    return {"message": "Successfully logged out"}


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user = Depends(get_current_user)):
    """Get current user information"""
    return current_user


@router.post("/create-demo-user")
async def create_demo_user(db: Session = Depends(get_db)):
    """Create demo user for testing (development only)"""
    user_service = UserService(db)
    
    try:
        demo_user = user_service.create_demo_user()
        return {
            "message": "Demo user created successfully",
            "user": format_user_for_mobile(demo_user),
            "credentials": {
                "email": "farmer@example.com",
                "password": "password123"
            }
        }
    except Exception as e:
        return {
            "message": "Demo user already exists or creation failed",
            "error": str(e)
        }