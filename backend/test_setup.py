#!/usr/bin/env python3
"""
Test script to verify backend setup and create demo user
"""
import sys
import os
import asyncio
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Add the app directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

from app.config import settings
from app.database import Base, create_tables
from app.services.user_service import UserService
from app.services.notification_service import NotificationService


def test_database_connection():
    """Test database connection"""
    print("Testing database connection...")
    try:
        # Use SQLite for testing if PostgreSQL is not available
        if "postgresql" in settings.database_url:
            # Try to connect to PostgreSQL
            engine = create_engine(settings.database_url)
            with engine.connect() as conn:
                result = conn.execute(text("SELECT 1"))
                print("✅ PostgreSQL connection successful")
        else:
            # Fallback to SQLite
            sqlite_url = "sqlite:///./test_agri_platform.db"
            engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})
            with engine.connect() as conn:
                result = conn.execute(text("SELECT 1"))
                print("✅ SQLite connection successful")
            # Update settings for testing
            settings.database_url = sqlite_url
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        print("Falling back to SQLite...")
        try:
            sqlite_url = "sqlite:///./test_agri_platform.db"
            engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})
            with engine.connect() as conn:
                result = conn.execute(text("SELECT 1"))
                print("✅ SQLite fallback connection successful")
            # Update settings for testing
            settings.database_url = sqlite_url
            return True
        except Exception as e2:
            print(f"❌ SQLite fallback also failed: {e2}")
            return False


def test_create_tables():
    """Test table creation"""
    print("Creating database tables...")
    try:
        create_tables()
        print("✅ Database tables created successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to create tables: {e}")
        return False


async def test_demo_user_creation():
    """Test demo user creation"""
    print("Creating demo user...")
    try:
        from app.database import SessionLocal
        
        db = SessionLocal()
        try:
            user_service = UserService(db)
            demo_user = user_service.create_demo_user()
            print(f"✅ Demo user created: {demo_user.email}")
            
            # Test notification service
            notification_service = NotificationService()
            await notification_service.send_welcome_message(demo_user)
            print("✅ Welcome notification sent")
            
            return True
        finally:
            db.close()
    except Exception as e:
        print(f"❌ Failed to create demo user: {e}")
        return False


def test_authentication():
    """Test authentication"""
    print("Testing authentication...")
    try:
        from app.database import SessionLocal
        from app.core.security import authenticate_user
        
        db = SessionLocal()
        try:
            user = authenticate_user(db, "farmer@example.com", "password123")
            if user:
                print(f"✅ Authentication successful for {user.email}")
                return True
            else:
                print("❌ Authentication failed")
                return False
        finally:
            db.close()
    except Exception as e:
        print(f"❌ Authentication test failed: {e}")
        return False


async def main():
    """Main test function"""
    print("🚀 Starting AgriVision Backend Setup Test")
    print("=" * 50)
    
    # Test database connection
    if not test_database_connection():
        print("❌ Database connection failed. Exiting.")
        return False
    
    # Test table creation
    if not test_create_tables():
        print("❌ Table creation failed. Exiting.")
        return False
    
    # Test demo user creation
    if not await test_demo_user_creation():
        print("❌ Demo user creation failed. Exiting.")
        return False
    
    # Test authentication
    if not test_authentication():
        print("❌ Authentication test failed. Exiting.")
        return False
    
    print("=" * 50)
    print("✅ All tests passed! Backend setup is ready.")
    print("\nDemo User Credentials:")
    print("Email: farmer@example.com")
    print("Password: password123")
    print("\nYou can now start the backend server with:")
    print("cd backend && python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
    
    return True


if __name__ == "__main__":
    asyncio.run(main())