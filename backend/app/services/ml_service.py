import tensorflow as tf
import numpy as np
from PIL import Image
import json
import os
from typing import List, Dict, Any
import structlog

from app.config import settings

logger = structlog.get_logger()


class MLService:
    """Machine Learning service for crop disease detection"""
    
    def __init__(self):
        self.model = None
        self.class_names = []
        self.load_model()
    
    def load_model(self):
        """Load the trained disease detection model"""
        try:
            model_path = os.path.join(settings.ml_model_path, settings.disease_detection_model)
            
            if os.path.exists(model_path):
                self.model = tf.keras.models.load_model(model_path)
                logger.info("Disease detection model loaded successfully")
                
                # Load class names
                class_names_path = os.path.join(settings.ml_model_path, "class_names.json")
                if os.path.exists(class_names_path):
                    with open(class_names_path, 'r') as f:
                        self.class_names = json.load(f)
                else:
                    # Default class names for demo
                    self.class_names = [
                        "healthy",
                        "bacterial_blight",
                        "brown_spot",
                        "leaf_blast",
                        "tungro",
                        "bacterial_leaf_streak",
                        "sheath_blight"
                    ]
            else:
                logger.warning("Disease detection model not found, using mock predictions")
                self.model = None
                
        except Exception as e:
            logger.error("Failed to load disease detection model", error=str(e))
            self.model = None
    
    async def detect_disease(self, image: Image.Image) -> List[Dict[str, Any]]:
        """Detect disease from crop image"""
        try:
            # Preprocess image
            processed_image = self.preprocess_image(image)
            
            if self.model is not None:
                # Run inference
                predictions = self.model.predict(processed_image)
                
                # Process predictions
                results = self.process_predictions(predictions[0])
            else:
                # Mock predictions for demo
                results = self.mock_predictions()
            
            logger.info("Disease detection completed", predictions_count=len(results))
            return results
            
        except Exception as e:
            logger.error("Disease detection failed", error=str(e))
            return self.mock_predictions()
    
    def preprocess_image(self, image: Image.Image) -> np.ndarray:
        """Preprocess image for model inference"""
        # Resize image to model input size
        image = image.resize((224, 224))
        
        # Convert to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Convert to numpy array and normalize
        image_array = np.array(image) / 255.0
        
        # Add batch dimension
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
    
    def process_predictions(self, predictions: np.ndarray) -> List[Dict[str, Any]]:
        """Process model predictions into structured format"""
        results = []
        
        # Get top 3 predictions
        top_indices = np.argsort(predictions)[-3:][::-1]
        
        for idx in top_indices:
            confidence = float(predictions[idx])
            if confidence > 0.1:  # Only include predictions with >10% confidence
                disease_name = self.class_names[idx] if idx < len(self.class_names) else f"unknown_{idx}"
                
                results.append({
                    "disease_name": disease_name,
                    "confidence": confidence,
                    "severity": self.estimate_severity(confidence),
                    "treatment_urgency": self.estimate_urgency(disease_name, confidence)
                })
        
        return results
    
    def mock_predictions(self) -> List[Dict[str, Any]]:
        """Generate mock predictions for demo purposes"""
        import random
        
        diseases = [
            {"name": "bacterial_blight", "confidence": 0.85, "severity": "moderate"},
            {"name": "brown_spot", "confidence": 0.72, "severity": "mild"},
            {"name": "leaf_blast", "confidence": 0.68, "severity": "severe"},
            {"name": "healthy", "confidence": 0.95, "severity": "none"}
        ]
        
        # Randomly select 1-3 predictions
        selected = random.sample(diseases, random.randint(1, 3))
        
        results = []
        for disease in selected:
            results.append({
                "disease_name": disease["name"],
                "confidence": disease["confidence"],
                "severity": disease["severity"],
                "treatment_urgency": "high" if disease["severity"] == "severe" else "medium"
            })
        
        return results
    
    def estimate_severity(self, confidence: float) -> str:
        """Estimate disease severity based on confidence"""
        if confidence > 0.8:
            return "severe"
        elif confidence > 0.6:
            return "moderate"
        elif confidence > 0.4:
            return "mild"
        else:
            return "uncertain"
    
    def estimate_urgency(self, disease_name: str, confidence: float) -> str:
        """Estimate treatment urgency"""
        if disease_name == "healthy":
            return "none"
        
        high_urgency_diseases = ["leaf_blast", "bacterial_blight", "tungro"]
        
        if disease_name in high_urgency_diseases and confidence > 0.7:
            return "high"
        elif confidence > 0.6:
            return "medium"
        else:
            return "low"


class WeatherMLService:
    """ML service for weather predictions and analysis"""
    
    def __init__(self):
        self.weather_model = None
        self.load_weather_model()
    
    def load_weather_model(self):
        """Load weather prediction model"""
        try:
            # This would load a weather prediction model
            # For now, we'll use external APIs with ML enhancement
            logger.info("Weather ML service initialized")
        except Exception as e:
            logger.error("Failed to initialize weather ML service", error=str(e))
    
    async def predict_weather(self, location: Dict[str, float], days: int = 7) -> Dict[str, Any]:
        """Predict weather for given location"""
        # This would use ML models to enhance weather predictions
        # For now, return mock data
        return {
            "location": location,
            "forecast_days": days,
            "predictions": []
        }
    
    async def analyze_crop_weather_risk(self, crop_type: str, weather_data: Dict) -> Dict[str, Any]:
        """Analyze weather-related risks for specific crops"""
        # ML analysis of weather impact on crops
        return {
            "crop_type": crop_type,
            "risk_level": "medium",
            "risk_factors": [],
            "recommendations": []
        }


class MarketMLService:
    """ML service for market price predictions"""
    
    def __init__(self):
        self.price_model = None
        self.load_price_model()
    
    def load_price_model(self):
        """Load market price prediction model"""
        try:
            logger.info("Market ML service initialized")
        except Exception as e:
            logger.error("Failed to initialize market ML service", error=str(e))
    
    async def predict_prices(self, crop_type: str, location: str, days: int = 30) -> Dict[str, Any]:
        """Predict market prices for crops"""
        # ML-based price prediction
        return {
            "crop_type": crop_type,
            "location": location,
            "predictions": []
        }