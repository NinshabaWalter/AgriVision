"""
Mobile Money Service for Agricultural Intelligence Platform
Handles M-Pesa, Airtel Money, and other mobile payment integrations
"""

import logging
import hashlib
import base64
import requests
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import json
import uuid

from ..core.config import settings
from ..models.user import User
from ..models.finance import Transaction, LoanApplication

logger = logging.getLogger(__name__)

class MobileMoneyService:
    """Service for handling mobile money transactions"""
    
    def __init__(self):
        self.mpesa_config = {
            "consumer_key": settings.MPESA_CONSUMER_KEY,
            "consumer_secret": settings.MPESA_CONSUMER_SECRET,
            "business_short_code": settings.MPESA_BUSINESS_SHORT_CODE,
            "passkey": settings.MPESA_PASSKEY,
            "base_url": settings.MPESA_BASE_URL or "https://sandbox.safaricom.co.ke"
        }
        
        self.airtel_config = {
            "client_id": settings.AIRTEL_CLIENT_ID,
            "client_secret": settings.AIRTEL_CLIENT_SECRET,
            "base_url": settings.AIRTEL_BASE_URL or "https://openapiuat.airtel.africa"
        }
    
    async def initiate_mpesa_payment(
        self, 
        phone_number: str, 
        amount: float, 
        account_reference: str,
        transaction_desc: str = "AgriPlatform Payment"
    ) -> Dict[str, Any]:
        """Initiate M-Pesa STK Push payment"""
        try:
            # Get access token
            access_token = await self._get_mpesa_access_token()
            if not access_token:
                return {"success": False, "error": "Failed to get access token"}
            
            # Format phone number
            phone_number = self._format_kenyan_phone(phone_number)
            
            # Generate timestamp and password
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            password = base64.b64encode(
                f"{self.mpesa_config['business_short_code']}{self.mpesa_config['passkey']}{timestamp}".encode()
            ).decode('utf-8')
            
            # Prepare STK push request
            stk_push_url = f"{self.mpesa_config['base_url']}/mpesa/stkpush/v1/processrequest"
            
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            }
            
            payload = {
                "BusinessShortCode": self.mpesa_config['business_short_code'],
                "Password": password,
                "Timestamp": timestamp,
                "TransactionType": "CustomerPayBillOnline",
                "Amount": int(amount),
                "PartyA": phone_number,
                "PartyB": self.mpesa_config['business_short_code'],
                "PhoneNumber": phone_number,
                "CallBackURL": f"{settings.BASE_URL}/api/v1/payments/mpesa/callback",
                "AccountReference": account_reference,
                "TransactionDesc": transaction_desc
            }
            
            response = requests.post(stk_push_url, json=payload, headers=headers)
            response_data = response.json()
            
            if response.status_code == 200 and response_data.get("ResponseCode") == "0":
                return {
                    "success": True,
                    "checkout_request_id": response_data.get("CheckoutRequestID"),
                    "merchant_request_id": response_data.get("MerchantRequestID"),
                    "response_description": response_data.get("ResponseDescription")
                }
            else:
                return {
                    "success": False,
                    "error": response_data.get("ResponseDescription", "Payment initiation failed")
                }
                
        except Exception as e:
            logger.error(f"Error initiating M-Pesa payment: {str(e)}")
            return {"success": False, "error": "Payment service temporarily unavailable"}
    
    async def check_mpesa_transaction_status(self, checkout_request_id: str) -> Dict[str, Any]:
        """Check M-Pesa transaction status"""
        try:
            access_token = await self._get_mpesa_access_token()
            if not access_token:
                return {"success": False, "error": "Failed to get access token"}
            
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            password = base64.b64encode(
                f"{self.mpesa_config['business_short_code']}{self.mpesa_config['passkey']}{timestamp}".encode()
            ).decode('utf-8')
            
            query_url = f"{self.mpesa_config['base_url']}/mpesa/stkpushquery/v1/query"
            
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            }
            
            payload = {
                "BusinessShortCode": self.mpesa_config['business_short_code'],
                "Password": password,
                "Timestamp": timestamp,
                "CheckoutRequestID": checkout_request_id
            }
            
            response = requests.post(query_url, json=payload, headers=headers)
            response_data = response.json()
            
            return {
                "success": True,
                "result_code": response_data.get("ResultCode"),
                "result_desc": response_data.get("ResultDesc"),
                "status": self._get_transaction_status(response_data.get("ResultCode"))
            }
            
        except Exception as e:
            logger.error(f"Error checking M-Pesa transaction status: {str(e)}")
            return {"success": False, "error": "Status check failed"}
    
    async def initiate_airtel_payment(
        self,
        phone_number: str,
        amount: float,
        transaction_id: str,
        currency: str = "KES"
    ) -> Dict[str, Any]:
        """Initiate Airtel Money payment"""
        try:
            # Get access token
            access_token = await self._get_airtel_access_token()
            if not access_token:
                return {"success": False, "error": "Failed to get access token"}
            
            # Format phone number for Airtel (remove country code)
            phone_number = self._format_airtel_phone(phone_number)
            
            payment_url = f"{self.airtel_config['base_url']}/merchant/v1/payments/"
            
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json",
                "X-Country": "KE",  # Kenya
                "X-Currency": currency
            }
            
            payload = {
                "reference": transaction_id,
                "subscriber": {
                    "country": "KE",
                    "currency": currency,
                    "msisdn": phone_number
                },
                "transaction": {
                    "amount": amount,
                    "country": "KE",
                    "currency": currency,
                    "id": transaction_id
                }
            }
            
            response = requests.post(payment_url, json=payload, headers=headers)
            response_data = response.json()
            
            if response.status_code == 200:
                return {
                    "success": True,
                    "transaction_id": response_data.get("data", {}).get("transaction", {}).get("id"),
                    "status": response_data.get("data", {}).get("transaction", {}).get("status")
                }
            else:
                return {
                    "success": False,
                    "error": response_data.get("message", "Payment initiation failed")
                }
                
        except Exception as e:
            logger.error(f"Error initiating Airtel payment: {str(e)}")
            return {"success": False, "error": "Payment service temporarily unavailable"}
    
    async def process_loan_payment(
        self,
        user: User,
        loan_application: LoanApplication,
        amount: float,
        payment_method: str = "mpesa"
    ) -> Dict[str, Any]:
        """Process loan payment"""
        try:
            transaction_id = str(uuid.uuid4())
            account_reference = f"LOAN_{loan_application.id}"
            
            if payment_method.lower() == "mpesa":
                result = await self.initiate_mpesa_payment(
                    phone_number=user.phone_number,
                    amount=amount,
                    account_reference=account_reference,
                    transaction_desc=f"Loan Payment - {loan_application.loan_type}"
                )
            elif payment_method.lower() == "airtel":
                result = await self.initiate_airtel_payment(
                    phone_number=user.phone_number,
                    amount=amount,
                    transaction_id=transaction_id
                )
            else:
                return {"success": False, "error": "Unsupported payment method"}
            
            if result["success"]:
                # Create transaction record
                transaction = Transaction(
                    user_id=user.id,
                    transaction_id=transaction_id,
                    amount=amount,
                    transaction_type="loan_payment",
                    payment_method=payment_method,
                    status="pending",
                    reference=account_reference,
                    description=f"Loan payment for {loan_application.loan_type}"
                )
                
                # In production, save to database
                # db.add(transaction)
                # db.commit()
                
                return {
                    "success": True,
                    "transaction_id": transaction_id,
                    "message": "Payment initiated successfully. Please complete on your phone."
                }
            else:
                return result
                
        except Exception as e:
            logger.error(f"Error processing loan payment: {str(e)}")
            return {"success": False, "error": "Payment processing failed"}
    
    async def process_insurance_payment(
        self,
        user: User,
        insurance_type: str,
        premium_amount: float,
        payment_method: str = "mpesa"
    ) -> Dict[str, Any]:
        """Process insurance premium payment"""
        try:
            transaction_id = str(uuid.uuid4())
            account_reference = f"INSURANCE_{insurance_type.upper()}"
            
            if payment_method.lower() == "mpesa":
                result = await self.initiate_mpesa_payment(
                    phone_number=user.phone_number,
                    amount=premium_amount,
                    account_reference=account_reference,
                    transaction_desc=f"Insurance Premium - {insurance_type}"
                )
            elif payment_method.lower() == "airtel":
                result = await self.initiate_airtel_payment(
                    phone_number=user.phone_number,
                    amount=premium_amount,
                    transaction_id=transaction_id
                )
            else:
                return {"success": False, "error": "Unsupported payment method"}
            
            if result["success"]:
                # Create transaction record
                transaction = Transaction(
                    user_id=user.id,
                    transaction_id=transaction_id,
                    amount=premium_amount,
                    transaction_type="insurance_payment",
                    payment_method=payment_method,
                    status="pending",
                    reference=account_reference,
                    description=f"Insurance premium for {insurance_type}"
                )
                
                return {
                    "success": True,
                    "transaction_id": transaction_id,
                    "message": "Insurance payment initiated successfully."
                }
            else:
                return result
                
        except Exception as e:
            logger.error(f"Error processing insurance payment: {str(e)}")
            return {"success": False, "error": "Payment processing failed"}
    
    async def get_transaction_history(self, user: User, limit: int = 10) -> List[Dict[str, Any]]:
        """Get user's transaction history"""
        try:
            # In production, fetch from database
            # transactions = db.query(Transaction).filter(
            #     Transaction.user_id == user.id
            # ).order_by(Transaction.created_at.desc()).limit(limit).all()
            
            # Mock data for now
            transactions = [
                {
                    "id": "txn_001",
                    "amount": 5000.0,
                    "type": "loan_payment",
                    "status": "completed",
                    "date": "2024-01-15T10:30:00Z",
                    "description": "Loan payment for crop financing"
                },
                {
                    "id": "txn_002",
                    "amount": 1200.0,
                    "type": "insurance_payment",
                    "status": "completed",
                    "date": "2024-01-10T14:20:00Z",
                    "description": "Crop insurance premium"
                }
            ]
            
            return transactions
            
        except Exception as e:
            logger.error(f"Error fetching transaction history: {str(e)}")
            return []
    
    async def _get_mpesa_access_token(self) -> Optional[str]:
        """Get M-Pesa access token"""
        try:
            auth_url = f"{self.mpesa_config['base_url']}/oauth/v1/generate?grant_type=client_credentials"
            
            auth_string = f"{self.mpesa_config['consumer_key']}:{self.mpesa_config['consumer_secret']}"
            auth_bytes = auth_string.encode('ascii')
            auth_b64 = base64.b64encode(auth_bytes).decode('ascii')
            
            headers = {
                "Authorization": f"Basic {auth_b64}",
                "Content-Type": "application/json"
            }
            
            response = requests.get(auth_url, headers=headers)
            
            if response.status_code == 200:
                return response.json().get("access_token")
            else:
                logger.error(f"Failed to get M-Pesa access token: {response.text}")
                return None
                
        except Exception as e:
            logger.error(f"Error getting M-Pesa access token: {str(e)}")
            return None
    
    async def _get_airtel_access_token(self) -> Optional[str]:
        """Get Airtel Money access token"""
        try:
            auth_url = f"{self.airtel_config['base_url']}/auth/oauth2/token"
            
            headers = {
                "Content-Type": "application/json"
            }
            
            payload = {
                "client_id": self.airtel_config['client_id'],
                "client_secret": self.airtel_config['client_secret'],
                "grant_type": "client_credentials"
            }
            
            response = requests.post(auth_url, json=payload, headers=headers)
            
            if response.status_code == 200:
                return response.json().get("access_token")
            else:
                logger.error(f"Failed to get Airtel access token: {response.text}")
                return None
                
        except Exception as e:
            logger.error(f"Error getting Airtel access token: {str(e)}")
            return None
    
    def _format_kenyan_phone(self, phone_number: str) -> str:
        """Format phone number for M-Pesa (254XXXXXXXXX)"""
        phone = phone_number.replace("+", "").replace(" ", "").replace("-", "")
        
        if phone.startswith("0"):
            phone = "254" + phone[1:]
        elif not phone.startswith("254"):
            phone = "254" + phone
            
        return phone
    
    def _format_airtel_phone(self, phone_number: str) -> str:
        """Format phone number for Airtel (remove country code)"""
        phone = phone_number.replace("+", "").replace(" ", "").replace("-", "")
        
        if phone.startswith("254"):
            phone = "0" + phone[3:]
        elif not phone.startswith("0"):
            phone = "0" + phone
            
        return phone
    
    def _get_transaction_status(self, result_code: str) -> str:
        """Get transaction status from result code"""
        status_map = {
            "0": "completed",
            "1032": "cancelled",
            "1037": "timeout",
            "2001": "insufficient_funds"
        }
        
        return status_map.get(str(result_code), "failed")


# Service instance
mobile_money_service = MobileMoneyService()