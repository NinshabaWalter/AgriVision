"""
SMS and USSD API endpoints for Agricultural Intelligence Platform
Handles basic phone communication for farmers without smartphones
"""

from fastapi import APIRouter, HTTPException, Depends, Request
from fastapi.responses import PlainTextResponse
from typing import Dict, Any, Optional
import logging

from ...services.sms_service import sms_service, ussd_service
from ...services.enhanced_weather_service import enhanced_weather_service
from ...services.mobile_money_service import mobile_money_service
from ...models.user import User
from ...core.deps import get_current_user

logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/sms/send")
async def send_sms(
    phone_number: str,
    message: str,
    language: str = "en",
    current_user: User = Depends(get_current_user)
):
    """Send SMS message"""
    try:
        success = await sms_service.send_sms(phone_number, message, language)
        
        if success:
            return {"success": True, "message": "SMS sent successfully"}
        else:
            raise HTTPException(status_code=500, detail="Failed to send SMS")
            
    except Exception as e:
        logger.error(f"Error sending SMS: {str(e)}")
        raise HTTPException(status_code=500, detail="SMS service error")

@router.post("/sms/weather-alert")
async def send_weather_alert_sms(
    phone_number: str,
    latitude: float,
    longitude: float,
    language: str = "en",
    current_user: User = Depends(get_current_user)
):
    """Send weather alert via SMS"""
    try:
        # Get weather alerts
        alerts = await enhanced_weather_service.check_weather_alerts(
            latitude, longitude, current_user.id, phone_number, language
        )
        
        if alerts:
            success = await enhanced_weather_service.send_weather_alerts(
                phone_number, alerts, language
            )
            
            return {
                "success": success,
                "alerts_count": len(alerts),
                "message": "Weather alerts sent" if success else "Failed to send alerts"
            }
        else:
            return {
                "success": True,
                "alerts_count": 0,
                "message": "No weather alerts at this time"
            }
            
    except Exception as e:
        logger.error(f"Error sending weather alert SMS: {str(e)}")
        raise HTTPException(status_code=500, detail="Weather alert service error")

@router.post("/sms/market-prices")
async def send_market_prices_sms(
    phone_number: str,
    location: str,
    language: str = "en",
    current_user: User = Depends(get_current_user)
):
    """Send market prices via SMS"""
    try:
        # Mock market prices - in production, fetch from market service
        market_prices = [
            {"commodity": "Maize", "price_per_unit": 45, "unit": "kg", "currency": "KSh"},
            {"commodity": "Beans", "price_per_unit": 120, "unit": "kg", "currency": "KSh"},
            {"commodity": "Rice", "price_per_unit": 85, "unit": "kg", "currency": "KSh"}
        ]
        
        success = await sms_service.send_market_update(
            current_user, market_prices
        )
        
        return {
            "success": success,
            "message": "Market prices sent" if success else "Failed to send market prices"
        }
        
    except Exception as e:
        logger.error(f"Error sending market prices SMS: {str(e)}")
        raise HTTPException(status_code=500, detail="Market prices service error")

@router.post("/ussd", response_class=PlainTextResponse)
async def handle_ussd_request(request: Request):
    """Handle USSD requests"""
    try:
        form_data = await request.form()
        
        session_id = form_data.get("sessionId", "")
        phone_number = form_data.get("phoneNumber", "")
        text = form_data.get("text", "")
        
        # Process USSD request
        response = await ussd_service.handle_ussd_request(session_id, phone_number, text)
        
        return response.get("response", "END Service temporarily unavailable")
        
    except Exception as e:
        logger.error(f"Error handling USSD request: {str(e)}")
        return "END Service temporarily unavailable. Please try again later."

@router.get("/ussd/weather/{phone_number}")
async def get_ussd_weather(phone_number: str, latitude: float = -1.2921, longitude: float = 36.8219):
    """Get weather info for USSD (default to Nairobi coordinates)"""
    try:
        weather = await enhanced_weather_service.get_current_weather(latitude, longitude)
        
        if weather:
            response = (
                f"Weather Update\n"
                f"🌡️ {weather['temperature']:.1f}°C\n"
                f"💧 Humidity: {weather['humidity']}%\n"
                f"🌤️ {weather['description'].title()}\n"
                f"🌬️ Wind: {weather['wind_speed']:.1f} km/h"
            )
        else:
            response = "Weather data unavailable"
        
        return {"response": response}
        
    except Exception as e:
        logger.error(f"Error getting USSD weather: {str(e)}")
        return {"response": "Weather service unavailable"}

@router.get("/ussd/market-prices/{phone_number}")
async def get_ussd_market_prices(phone_number: str):
    """Get market prices for USSD"""
    try:
        # Mock market prices - in production, fetch from market service
        prices = [
            {"commodity": "Maize", "price": 45, "unit": "kg"},
            {"commodity": "Beans", "price": 120, "unit": "kg"},
            {"commodity": "Rice", "price": 85, "unit": "kg"}
        ]
        
        response = "Market Prices (KSh)\n"
        for price in prices:
            response += f"{price['commodity']}: {price['price']}/{price['unit']}\n"
        
        return {"response": response}
        
    except Exception as e:
        logger.error(f"Error getting USSD market prices: {str(e)}")
        return {"response": "Market prices unavailable"}

@router.post("/ussd/payment")
async def initiate_ussd_payment(
    phone_number: str,
    amount: float,
    service_type: str,  # "loan", "insurance", "market"
    payment_method: str = "mpesa"
):
    """Initiate payment via USSD"""
    try:
        if service_type == "loan":
            # Mock loan application
            result = await mobile_money_service.initiate_mpesa_payment(
                phone_number=phone_number,
                amount=amount,
                account_reference=f"LOAN_PAYMENT_{phone_number}",
                transaction_desc="Agricultural loan payment"
            )
        elif service_type == "insurance":
            result = await mobile_money_service.initiate_mpesa_payment(
                phone_number=phone_number,
                amount=amount,
                account_reference=f"INSURANCE_{phone_number}",
                transaction_desc="Crop insurance premium"
            )
        else:
            raise HTTPException(status_code=400, detail="Invalid service type")
        
        if result["success"]:
            return {
                "success": True,
                "message": "Payment initiated. Complete on your phone.",
                "checkout_request_id": result.get("checkout_request_id")
            }
        else:
            return {
                "success": False,
                "message": result.get("error", "Payment failed")
            }
            
    except Exception as e:
        logger.error(f"Error initiating USSD payment: {str(e)}")
        raise HTTPException(status_code=500, detail="Payment service error")

@router.get("/sms/agricultural-tips")
async def get_agricultural_tips_sms(
    phone_number: str,
    crop_type: str = "maize",
    language: str = "en"
):
    """Get agricultural tips via SMS"""
    try:
        tips = {
            "maize": {
                "en": "🌽 MAIZE TIPS:\n1. Plant at 75cm x 25cm spacing\n2. Apply DAP at planting\n3. Top dress with CAN after 6 weeks\n4. Weed 2-3 times\n5. Harvest at 18-20% moisture",
                "sw": "🌽 VIDOKEZO VYA MAHINDI:\n1. Panda kwa umbali wa sm 75 x 25\n2. Tumia DAP wakati wa kupanda\n3. Ongeza CAN baada ya wiki 6\n4. Palilia mara 2-3\n5. Vuna kwa unyevu wa 18-20%"
            },
            "beans": {
                "en": "🫘 BEAN TIPS:\n1. Plant at 30cm x 10cm spacing\n2. Use certified seeds\n3. Apply DAP fertilizer\n4. Weed regularly\n5. Harvest when pods are dry",
                "sw": "🫘 VIDOKEZO VYA MAHARAGWE:\n1. Panda kwa umbali wa sm 30 x 10\n2. Tumia mbegu zilizoidhinishwa\n3. Tumia mbolea ya DAP\n4. Palilia mara kwa mara\n5. Vuna maganda yanapokausha"
            }
        }
        
        tip_message = tips.get(crop_type, {}).get(language, tips["maize"]["en"])
        
        success = await sms_service.send_sms(phone_number, tip_message, language)
        
        return {
            "success": success,
            "message": "Agricultural tips sent" if success else "Failed to send tips"
        }
        
    except Exception as e:
        logger.error(f"Error sending agricultural tips SMS: {str(e)}")
        raise HTTPException(status_code=500, detail="Agricultural tips service error")

@router.post("/sms/disease-alert")
async def send_disease_alert_sms(
    phone_number: str,
    disease_info: Dict[str, Any],
    language: str = "en"
):
    """Send crop disease alert via SMS"""
    try:
        success = await sms_service.send_disease_alert(
            phone_number, disease_info, language
        )
        
        return {
            "success": success,
            "message": "Disease alert sent" if success else "Failed to send disease alert"
        }
        
    except Exception as e:
        logger.error(f"Error sending disease alert SMS: {str(e)}")
        raise HTTPException(status_code=500, detail="Disease alert service error")

@router.get("/ussd/emergency-contacts")
async def get_emergency_contacts():
    """Get emergency contacts for USSD"""
    try:
        contacts = {
            "response": (
                "Emergency Contacts\n"
                "🚨 Agricultural Emergency: 123\n"
                "🌾 Extension Officer: 456\n"
                "🏥 Veterinary Services: 789\n"
                "💰 Cooperative Society: 101\n"
                "📞 AgriPlatform Support: 112"
            )
        }
        
        return contacts
        
    except Exception as e:
        logger.error(f"Error getting emergency contacts: {str(e)}")
        return {"response": "Emergency contacts unavailable"}

@router.post("/sms/bulk-weather-alerts")
async def send_bulk_weather_alerts(
    phone_numbers: list[str],
    latitude: float,
    longitude: float,
    language: str = "en",
    current_user: User = Depends(get_current_user)
):
    """Send weather alerts to multiple phone numbers"""
    try:
        # Get weather alerts
        alerts = await enhanced_weather_service.check_weather_alerts(
            latitude, longitude, current_user.id, "", language
        )
        
        if not alerts:
            return {
                "success": True,
                "sent_count": 0,
                "message": "No weather alerts to send"
            }
        
        sent_count = 0
        failed_count = 0
        
        for phone_number in phone_numbers:
            try:
                success = await enhanced_weather_service.send_weather_alerts(
                    phone_number, alerts, language
                )
                if success:
                    sent_count += 1
                else:
                    failed_count += 1
            except Exception as e:
                logger.error(f"Failed to send alert to {phone_number}: {str(e)}")
                failed_count += 1
        
        return {
            "success": True,
            "sent_count": sent_count,
            "failed_count": failed_count,
            "total_alerts": len(alerts),
            "message": f"Sent alerts to {sent_count} recipients"
        }
        
    except Exception as e:
        logger.error(f"Error sending bulk weather alerts: {str(e)}")
        raise HTTPException(status_code=500, detail="Bulk alert service error")

@router.get("/sms/status/{phone_number}")
async def get_sms_status(phone_number: str):
    """Get SMS delivery status"""
    try:
        # In production, check with Twilio API for delivery status
        # For now, return mock status
        return {
            "phone_number": phone_number,
            "status": "delivered",
            "last_sent": "2024-01-15T10:30:00Z",
            "message_count": 5
        }
        
    except Exception as e:
        logger.error(f"Error getting SMS status: {str(e)}")
        raise HTTPException(status_code=500, detail="SMS status service error")