#!/usr/bin/env python3
"""
Simple test script to verify basic backend functionality
"""
import sys
import os

# Add the app directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

def test_imports():
    """Test if we can import the basic modules"""
    print("Testing imports...")
    try:
        from app.config import settings
        print("✅ Config imported successfully")
        
        from app.database import Base
        print("✅ Database models imported successfully")
        
        from app.services.user_service import UserService
        print("✅ UserService imported successfully")
        
        from app.services.notification_service import NotificationService
        print("✅ NotificationService imported successfully")
        
        from app.core.security import get_password_hash, verify_password
        print("✅ Security functions imported successfully")
        
        return True
    except Exception as e:
        print(f"❌ Import failed: {e}")
        return False

def test_password_hashing():
    """Test password hashing functionality"""
    print("Testing password hashing...")
    try:
        from app.core.security import get_password_hash, verify_password
        
        password = "password123"
        hashed = get_password_hash(password)
        
        if verify_password(password, hashed):
            print("✅ Password hashing works correctly")
            return True
        else:
            print("❌ Password verification failed")
            return False
    except Exception as e:
        print(f"❌ Password hashing test failed: {e}")
        return False

def test_config():
    """Test configuration"""
    print("Testing configuration...")
    try:
        from app.config import settings
        
        print(f"Debug mode: {settings.debug}")
        print(f"Database URL: {settings.database_url}")
        print(f"Environment: {settings.environment}")
        print("✅ Configuration loaded successfully")
        return True
    except Exception as e:
        print(f"❌ Configuration test failed: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 Starting Simple Backend Test")
    print("=" * 40)
    
    success = True
    
    # Test imports
    if not test_imports():
        success = False
    
    # Test password hashing
    if not test_password_hashing():
        success = False
    
    # Test configuration
    if not test_config():
        success = False
    
    print("=" * 40)
    if success:
        print("✅ All basic tests passed!")
        print("\nNext steps:")
        print("1. Install remaining dependencies if needed")
        print("2. Set up database (PostgreSQL or SQLite)")
        print("3. Run the full test with: python test_setup.py")
        print("4. Start the server with: python -m uvicorn app.main:app --reload")
    else:
        print("❌ Some tests failed. Check the errors above.")
    
    return success

if __name__ == "__main__":
    main()