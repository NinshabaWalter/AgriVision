"""
SMS Service for Agricultural Intelligence Platform
Handles SMS notifications, USSD integration, and basic phone communication
"""

import logging
from typing import Dict, List, Optional, Any
from twilio.rest import Client
from twilio.base.exceptions import TwilioException
import requests
import json
from datetime import datetime, timedelta

from ..core.config import settings
from ..models.user import User
from ..models.weather import WeatherAlert
from ..models.market import MarketPrice

logger = logging.getLogger(__name__)

class SMSService:
    """Service for handling SMS communications"""
    
    def __init__(self):
        self.twilio_client = None
        if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN:
            self.twilio_client = Client(
                settings.TWILIO_ACCOUNT_SID,
                settings.TWILIO_AUTH_TOKEN
            )
    
    async def send_sms(self, phone_number: str, message: str, language: str = "en") -> bool:
        """Send SMS message to phone number"""
        try:
            if not self.twilio_client:
                logger.error("Twilio client not configured")
                return False
            
            # Format phone number for international format
            if not phone_number.startswith('+'):
                # Assume East African numbers, add country codes
                if phone_number.startswith('07') or phone_number.startswith('01'):
                    phone_number = '+254' + phone_number[1:]  # Kenya
                elif phone_number.startswith('06') or phone_number.startswith('07'):
                    phone_number = '+255' + phone_number[1:]  # Tanzania
                elif phone_number.startswith('07') or phone_number.startswith('03'):
                    phone_number = '+256' + phone_number[1:]  # Uganda
                elif phone_number.startswith('09') or phone_number.startswith('07'):
                    phone_number = '+251' + phone_number[1:]  # Ethiopia
            
            # Translate message if needed
            translated_message = await self._translate_message(message, language)
            
            message = self.twilio_client.messages.create(
                body=translated_message,
                from_=settings.TWILIO_PHONE_NUMBER,
                to=phone_number
            )
            
            logger.info(f"SMS sent successfully to {phone_number}, SID: {message.sid}")
            return True
            
        except TwilioException as e:
            logger.error(f"Twilio error sending SMS to {phone_number}: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"Error sending SMS to {phone_number}: {str(e)}")
            return False
    
    async def send_weather_alert(self, user: User, weather_alert: WeatherAlert) -> bool:
        """Send weather alert via SMS"""
        try:
            # Create weather alert message
            message = await self._create_weather_message(weather_alert, user.language)
            
            return await self.send_sms(user.phone_number, message, user.language)
            
        except Exception as e:
            logger.error(f"Error sending weather alert to user {user.id}: {str(e)}")
            return False
    
    async def send_market_update(self, user: User, market_prices: List[MarketPrice]) -> bool:
        """Send market price update via SMS"""
        try:
            message = await self._create_market_message(market_prices, user.language)
            
            return await self.send_sms(user.phone_number, message, user.language)
            
        except Exception as e:
            logger.error(f"Error sending market update to user {user.id}: {str(e)}")
            return False
    
    async def send_disease_alert(self, user: User, disease_info: Dict[str, Any]) -> bool:
        """Send crop disease alert via SMS"""
        try:
            message = await self._create_disease_message(disease_info, user.language)
            
            return await self.send_sms(user.phone_number, message, user.language)
            
        except Exception as e:
            logger.error(f"Error sending disease alert to user {user.id}: {str(e)}")
            return False
    
    async def _create_weather_message(self, alert: WeatherAlert, language: str) -> str:
        """Create weather alert message"""
        messages = {
            "en": f"🌤️ WEATHER ALERT: {alert.alert_type.upper()}\n"
                  f"📍 {alert.location}\n"
                  f"📅 {alert.start_date.strftime('%d/%m %H:%M')}\n"
                  f"⚠️ {alert.description}\n"
                  f"💡 Action: {alert.recommendation}",
            
            "sw": f"🌤️ ONYO LA HALI YA HEWA: {alert.alert_type.upper()}\n"
                  f"📍 {alert.location}\n"
                  f"📅 {alert.start_date.strftime('%d/%m %H:%M')}\n"
                  f"⚠️ {alert.description}\n"
                  f"💡 Hatua: {alert.recommendation}",
            
            "am": f"🌤️ የአየር ሁኔታ ማስጠንቀቂያ: {alert.alert_type.upper()}\n"
                  f"📍 {alert.location}\n"
                  f"📅 {alert.start_date.strftime('%d/%m %H:%M')}\n"
                  f"⚠️ {alert.description}\n"
                  f"💡 እርምጃ: {alert.recommendation}",
            
            "fr": f"🌤️ ALERTE MÉTÉO: {alert.alert_type.upper()}\n"
                  f"📍 {alert.location}\n"
                  f"📅 {alert.start_date.strftime('%d/%m %H:%M')}\n"
                  f"⚠️ {alert.description}\n"
                  f"💡 Action: {alert.recommendation}"
        }
        
        return messages.get(language, messages["en"])
    
    async def _create_market_message(self, prices: List[MarketPrice], language: str) -> str:
        """Create market price message"""
        price_text = ""
        for price in prices[:5]:  # Limit to 5 items for SMS
            price_text += f"{price.commodity}: {price.currency}{price.price_per_unit}/{price.unit}\n"
        
        messages = {
            "en": f"📈 MARKET PRICES UPDATE\n"
                  f"📅 {datetime.now().strftime('%d/%m/%Y')}\n"
                  f"{price_text}"
                  f"📞 Call *123# for more prices",
            
            "sw": f"📈 MABADILIKO YA BEI ZA SOKONI\n"
                  f"📅 {datetime.now().strftime('%d/%m/%Y')}\n"
                  f"{price_text}"
                  f"📞 Piga *123# kwa bei zaidi",
            
            "am": f"📈 የገበያ ዋጋ ዝማኔ\n"
                  f"📅 {datetime.now().strftime('%d/%m/%Y')}\n"
                  f"{price_text}"
                  f"📞 ለተጨማሪ ዋጋዎች *123# ይደውሉ",
            
            "fr": f"📈 MISE À JOUR DES PRIX DU MARCHÉ\n"
                  f"📅 {datetime.now().strftime('%d/%m/%Y')}\n"
                  f"{price_text}"
                  f"📞 Composez *123# pour plus de prix"
        }
        
        return messages.get(language, messages["en"])
    
    async def _create_disease_message(self, disease_info: Dict[str, Any], language: str) -> str:
        """Create disease alert message"""
        messages = {
            "en": f"🚨 CROP DISEASE DETECTED\n"
                  f"🌱 Crop: {disease_info.get('crop', 'Unknown')}\n"
                  f"🦠 Disease: {disease_info.get('disease_name', 'Unknown')}\n"
                  f"📊 Confidence: {disease_info.get('confidence', 0):.0%}\n"
                  f"💊 Treatment: {disease_info.get('treatment', 'Consult expert')}\n"
                  f"📞 Call extension officer for help",
            
            "sw": f"🚨 UGONJWA WA MAZAO UMEGUNDULIWA\n"
                  f"🌱 Mazao: {disease_info.get('crop', 'Hayajulikani')}\n"
                  f"🦠 Ugonjwa: {disease_info.get('disease_name', 'Haujulikani')}\n"
                  f"📊 Uhakika: {disease_info.get('confidence', 0):.0%}\n"
                  f"💊 Matibabu: {disease_info.get('treatment', 'Wasiliana na mtaalamu')}\n"
                  f"📞 Piga simu kwa afisa wa kilimo",
            
            "am": f"🚨 የሰብል በሽታ ተገኝቷል\n"
                  f"🌱 ሰብል: {disease_info.get('crop', 'አልታወቀም')}\n"
                  f"🦠 በሽታ: {disease_info.get('disease_name', 'አልታወቀም')}\n"
                  f"📊 እርግጠኝነት: {disease_info.get('confidence', 0):.0%}\n"
                  f"💊 ሕክምና: {disease_info.get('treatment', 'ባለሙያን ያማክሩ')}\n"
                  f"📞 ለእርዳታ የማራዘሚያ ኦፊሰርን ይደውሉ",
            
            "fr": f"🚨 MALADIE DES CULTURES DÉTECTÉE\n"
                  f"🌱 Culture: {disease_info.get('crop', 'Inconnue')}\n"
                  f"🦠 Maladie: {disease_info.get('disease_name', 'Inconnue')}\n"
                  f"📊 Confiance: {disease_info.get('confidence', 0):.0%}\n"
                  f"💊 Traitement: {disease_info.get('treatment', 'Consulter un expert')}\n"
                  f"📞 Appelez l'agent de vulgarisation pour de l'aide"
        }
        
        return messages.get(language, messages["en"])
    
    async def _translate_message(self, message: str, language: str) -> str:
        """Translate message to target language (basic implementation)"""
        # This is a basic implementation. In production, you'd use a proper translation service
        if language == "en":
            return message
        
        # For now, return the original message
        # TODO: Implement proper translation service integration
        return message


class USSDService:
    """Service for handling USSD interactions"""
    
    def __init__(self):
        self.session_data = {}  # In production, use Redis or database
    
    async def handle_ussd_request(self, session_id: str, phone_number: str, text: str) -> Dict[str, Any]:
        """Handle USSD request and return response"""
        try:
            # Initialize session if new
            if session_id not in self.session_data:
                self.session_data[session_id] = {
                    "phone_number": phone_number,
                    "step": 0,
                    "data": {}
                }
            
            session = self.session_data[session_id]
            
            if text == "":
                # Initial request
                return await self._show_main_menu(session_id)
            
            # Parse user input
            user_input = text.split('*')[-1] if '*' in text else text
            
            return await self._process_user_input(session_id, user_input)
            
        except Exception as e:
            logger.error(f"Error handling USSD request: {str(e)}")
            return {
                "response": "CON Service temporarily unavailable. Please try again later.",
                "continue": True
            }
    
    async def _show_main_menu(self, session_id: str) -> Dict[str, Any]:
        """Show main USSD menu"""
        menu = (
            "CON Welcome to AgriPlatform\n"
            "1. Weather Info\n"
            "2. Market Prices\n"
            "3. Crop Diseases\n"
            "4. Agricultural Tips\n"
            "5. Emergency Contacts\n"
            "0. Exit"
        )
        
        return {
            "response": menu,
            "continue": True
        }
    
    async def _process_user_input(self, session_id: str, user_input: str) -> Dict[str, Any]:
        """Process user input and return appropriate response"""
        session = self.session_data[session_id]
        
        if session["step"] == 0:  # Main menu
            if user_input == "1":
                return await self._show_weather_menu(session_id)
            elif user_input == "2":
                return await self._show_market_menu(session_id)
            elif user_input == "3":
                return await self._show_disease_menu(session_id)
            elif user_input == "4":
                return await self._show_tips_menu(session_id)
            elif user_input == "5":
                return await self._show_emergency_contacts(session_id)
            elif user_input == "0":
                return {"response": "END Thank you for using AgriPlatform!", "continue": False}
            else:
                return await self._show_main_menu(session_id)
        
        # Handle sub-menus based on current step
        return await self._handle_submenu(session_id, user_input)
    
    async def _show_weather_menu(self, session_id: str) -> Dict[str, Any]:
        """Show weather information menu"""
        self.session_data[session_id]["step"] = 1
        self.session_data[session_id]["data"]["menu"] = "weather"
        
        menu = (
            "CON Weather Information\n"
            "1. Today's Weather\n"
            "2. 3-Day Forecast\n"
            "3. Rainfall Prediction\n"
            "4. Weather Alerts\n"
            "0. Back to Main Menu"
        )
        
        return {
            "response": menu,
            "continue": True
        }
    
    async def _show_market_menu(self, session_id: str) -> Dict[str, Any]:
        """Show market prices menu"""
        self.session_data[session_id]["step"] = 1
        self.session_data[session_id]["data"]["menu"] = "market"
        
        menu = (
            "CON Market Prices\n"
            "1. Maize Prices\n"
            "2. Bean Prices\n"
            "3. Rice Prices\n"
            "4. Vegetable Prices\n"
            "5. Livestock Prices\n"
            "0. Back to Main Menu"
        )
        
        return {
            "response": menu,
            "continue": True
        }
    
    async def _show_disease_menu(self, session_id: str) -> Dict[str, Any]:
        """Show crop disease menu"""
        self.session_data[session_id]["step"] = 1
        self.session_data[session_id]["data"]["menu"] = "disease"
        
        menu = (
            "CON Crop Disease Info\n"
            "1. Common Maize Diseases\n"
            "2. Bean Disease Symptoms\n"
            "3. Treatment Options\n"
            "4. Prevention Tips\n"
            "0. Back to Main Menu"
        )
        
        return {
            "response": menu,
            "continue": True
        }
    
    async def _show_tips_menu(self, session_id: str) -> Dict[str, Any]:
        """Show agricultural tips menu"""
        self.session_data[session_id]["step"] = 1
        self.session_data[session_id]["data"]["menu"] = "tips"
        
        menu = (
            "CON Agricultural Tips\n"
            "1. Planting Calendar\n"
            "2. Fertilizer Guide\n"
            "3. Pest Control\n"
            "4. Harvest Tips\n"
            "0. Back to Main Menu"
        )
        
        return {
            "response": menu,
            "continue": True
        }
    
    async def _show_emergency_contacts(self, session_id: str) -> Dict[str, Any]:
        """Show emergency contacts"""
        contacts = (
            "END Emergency Contacts\n"
            "🚨 Agricultural Emergency: 123\n"
            "🌾 Extension Officer: 456\n"
            "🏥 Veterinary Services: 789\n"
            "💰 Cooperative Society: 101\n"
            "📞 AgriPlatform Support: 112"
        )
        
        return {
            "response": contacts,
            "continue": False
        }
    
    async def _handle_submenu(self, session_id: str, user_input: str) -> Dict[str, Any]:
        """Handle submenu selections"""
        session = self.session_data[session_id]
        menu_type = session["data"].get("menu")
        
        if user_input == "0":
            # Back to main menu
            session["step"] = 0
            return await self._show_main_menu(session_id)
        
        if menu_type == "weather":
            return await self._handle_weather_selection(session_id, user_input)
        elif menu_type == "market":
            return await self._handle_market_selection(session_id, user_input)
        elif menu_type == "disease":
            return await self._handle_disease_selection(session_id, user_input)
        elif menu_type == "tips":
            return await self._handle_tips_selection(session_id, user_input)
        
        return await self._show_main_menu(session_id)
    
    async def _handle_weather_selection(self, session_id: str, selection: str) -> Dict[str, Any]:
        """Handle weather menu selections"""
        if selection == "1":
            # Today's weather - in production, fetch from weather service
            response = (
                "END Today's Weather\n"
                "🌤️ Partly Cloudy\n"
                "🌡️ 28°C (High: 32°C, Low: 22°C)\n"
                "💧 Humidity: 65%\n"
                "🌬️ Wind: 15 km/h\n"
                "☔ Rain Chance: 30%"
            )
        elif selection == "2":
            response = (
                "END 3-Day Forecast\n"
                "Today: Partly Cloudy 28°C\n"
                "Tomorrow: Sunny 30°C\n"
                "Day 3: Light Rain 25°C\n"
                "💡 Good for planting tomorrow!"
            )
        elif selection == "3":
            response = (
                "END Rainfall Prediction\n"
                "📅 Next 7 Days:\n"
                "Mon-Wed: No rain expected\n"
                "Thu-Fri: Light showers\n"
                "Weekend: Heavy rain likely\n"
                "💡 Plan irrigation accordingly"
            )
        elif selection == "4":
            response = (
                "END Weather Alerts\n"
                "⚠️ No active alerts\n"
                "📱 SMS alerts enabled\n"
                "🔔 Next update: 6:00 AM\n"
                "Stay safe!"
            )
        else:
            return await self._show_weather_menu(session_id)
        
        return {"response": response, "continue": False}
    
    async def _handle_market_selection(self, session_id: str, selection: str) -> Dict[str, Any]:
        """Handle market menu selections"""
        # In production, fetch real market data
        prices = {
            "1": "END Maize Prices\n📍 Local Market\n🌽 White Maize: KSh 45/kg\n🌽 Yellow Maize: KSh 42/kg\n📈 Trend: Stable\n💡 Good time to sell",
            "2": "END Bean Prices\n📍 Local Market\n🫘 Red Beans: KSh 120/kg\n🫘 White Beans: KSh 110/kg\n📈 Trend: Rising\n💡 Hold for better prices",
            "3": "END Rice Prices\n📍 Local Market\n🍚 Local Rice: KSh 85/kg\n🍚 Imported Rice: KSh 95/kg\n📈 Trend: Stable\n💡 Fair market price",
            "4": "END Vegetable Prices\n📍 Local Market\n🥬 Sukuma Wiki: KSh 20/bunch\n🥕 Carrots: KSh 60/kg\n🧅 Onions: KSh 80/kg\n📈 Trend: Seasonal",
            "5": "END Livestock Prices\n📍 Local Market\n🐄 Dairy Cow: KSh 45,000\n🐐 Goat: KSh 8,000\n🐔 Chicken: KSh 800\n📈 Trend: Stable"
        }
        
        response = prices.get(selection, "END Invalid selection. Try again.")
        return {"response": response, "continue": False}
    
    async def _handle_disease_selection(self, session_id: str, selection: str) -> Dict[str, Any]:
        """Handle disease menu selections"""
        info = {
            "1": "END Common Maize Diseases\n🦠 Maize Streak Virus\n🦠 Fall Armyworm\n🦠 Maize Lethal Necrosis\n💊 Use certified seeds\n💊 Apply recommended pesticides",
            "2": "END Bean Disease Symptoms\n🔍 Yellow leaves: Nutrient deficiency\n🔍 Brown spots: Bacterial blight\n🔍 Wilting: Root rot\n📞 Call extension officer",
            "3": "END Treatment Options\n💊 Organic: Neem oil spray\n💊 Chemical: Consult agro-dealer\n💊 Cultural: Crop rotation\n⚠️ Follow label instructions",
            "4": "END Prevention Tips\n🌱 Use certified seeds\n💧 Proper drainage\n🔄 Crop rotation\n🧹 Field sanitation\n📅 Timely planting"
        }
        
        response = info.get(selection, "END Invalid selection. Try again.")
        return {"response": response, "continue": False}
    
    async def _handle_tips_selection(self, session_id: str, selection: str) -> Dict[str, Any]:
        """Handle tips menu selections"""
        tips = {
            "1": "END Planting Calendar\n📅 Short Rains (Oct-Dec)\n🌽 Maize: Plant by mid-Oct\n🫘 Beans: Plant by end-Oct\n📅 Long Rains (Mar-May)\n🌾 All crops suitable",
            "2": "END Fertilizer Guide\n🌱 Basal: DAP at planting\n🌿 Top dress: CAN after 6 weeks\n📏 Rate: 50kg/acre for maize\n💡 Soil test recommended",
            "3": "END Pest Control\n🐛 Scout fields weekly\n🌿 Use IPM approach\n💊 Spray early morning/evening\n⚠️ Wear protective gear\n📞 Consult experts",
            "4": "END Harvest Tips\n🌽 Maize: 18-20% moisture\n🫘 Beans: Pods dry and brown\n☀️ Harvest in dry weather\n🏠 Proper storage essential\n📦 Use hermetic bags"
        }
        
        response = tips.get(selection, "END Invalid selection. Try again.")
        return {"response": response, "continue": False}


# Service instances
sms_service = SMSService()
ussd_service = USSDService()