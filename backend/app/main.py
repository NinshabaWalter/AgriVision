from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.security import HTTPBearer
import structlog
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration

from app.config import settings
from app.database import create_tables
from app.api.v1 import api_router
from app.core.middleware import LoggingMiddleware, TimingMiddleware

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Initialize Sentry for error tracking
if settings.sentry_dsn:
    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        integrations=[
            FastApiIntegration(auto_enabling=True),
            SqlalchemyIntegration(),
        ],
        traces_sample_rate=0.1,
        environment=settings.environment,
    )

# Create FastAPI application
app = FastAPI(
    title="Agricultural Intelligence Platform API",
    description="""
    A comprehensive API for agricultural intelligence platform providing:
    
    - 🌤️ Weather predictions and climate data
    - 🔍 Crop disease identification using AI
    - 📈 Market price tracking and buyer connections
    - 🌱 Soil health monitoring and recommendations
    - 💰 Microfinance and insurance services
    - 📦 Supply chain tracking from farm to market
    
    Built for farmers in East Africa with offline-first capabilities.
    """,
    version="1.0.0",
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
    openapi_url="/openapi.json" if settings.debug else None,
)

# Security
security = HTTPBearer()

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["*"] if settings.debug else ["yourdomain.com", "*.yourdomain.com"]
)

app.add_middleware(LoggingMiddleware)
app.add_middleware(TimingMiddleware)

# Include API routes
app.include_router(api_router, prefix="/api/v1")


@app.on_event("startup")
async def startup_event():
    """Initialize application on startup"""
    logger.info("Starting Agricultural Intelligence Platform API")
    
    # Create database tables
    create_tables()
    logger.info("Database tables created/verified")
    
    # Create demo user for development/testing
    if settings.debug:
        try:
            from app.services.user_service import UserService
            from app.database import SessionLocal
            
            db = SessionLocal()
            try:
                user_service = UserService(db)
                demo_user = user_service.create_demo_user()
                logger.info(f"Demo user created/verified: {demo_user.email}")
            finally:
                db.close()
        except Exception as e:
            logger.warning(f"Failed to create demo user: {str(e)}")
    
    # Additional startup tasks can be added here
    # - Initialize ML models
    # - Setup background tasks
    # - Verify external service connections


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on application shutdown"""
    logger.info("Shutting down Agricultural Intelligence Platform API")


@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Agricultural Intelligence Platform API",
        "version": "1.0.0",
        "status": "operational",
        "environment": settings.environment,
        "docs": "/docs" if settings.debug else "Contact admin for API documentation"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy",
        "timestamp": "2024-01-01T00:00:00Z",
        "version": "1.0.0",
        "environment": settings.environment
    }


@app.get("/metrics")
async def metrics():
    """Basic metrics endpoint"""
    # This would typically integrate with Prometheus or similar
    return {
        "active_users": 0,
        "total_farms": 0,
        "disease_detections_today": 0,
        "weather_updates_today": 0
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.debug,
        log_level=settings.log_level.lower()
    )