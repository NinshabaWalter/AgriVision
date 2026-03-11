from fastapi import APIRouter
from .endpoints import (
    auth,
    users,
    disease_detection,
    # farms,
    # weather,
    # market,
    # soil,
    # finance,
    # supply_chain
)

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(disease_detection.router, prefix="/disease-detection", tags=["Disease Detection"])

# TODO: Re-enable these endpoints after creating the endpoint files
# api_router.include_router(farms.router, prefix="/farms", tags=["Farms"])
# api_router.include_router(weather.router, prefix="/weather", tags=["Weather"])
# api_router.include_router(market.router, prefix="/market", tags=["Market"])
# api_router.include_router(soil.router, prefix="/soil", tags=["Soil"])
# api_router.include_router(finance.router, prefix="/finance", tags=["Finance"])
# api_router.include_router(supply_chain.router, prefix="/supply-chain", tags=["Supply Chain"])