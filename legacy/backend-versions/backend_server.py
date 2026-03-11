#!/usr/bin/env python3
"""
Simple HTTP server for Agricultural Intelligence Platform
"""

import json
import http.server
import socketserver
from urllib.parse import urlparse, parse_qs
from datetime import datetime, timedelta
import random

class AgriPlatformHandler(http.server.BaseHTTPRequestHandler):
    def _set_headers(self, status_code=200):
        """Set common headers for all responses"""
        self.send_response(status_code)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.send_header('Content-Type', 'application/json')
        self.end_headers()

    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self._set_headers(200)

    def do_GET(self):
        """Handle GET requests"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        query_params = parse_qs(parsed_path.query)
        
        if path == '/' or path == '/health':
            self._set_headers(200)
            response = {
                "message": "Agricultural Intelligence Platform API",
                "version": "1.0.0",
                "status": "healthy",
                "timestamp": datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/weather/current':
            self._set_headers(200)
            lat = float(query_params.get('lat', [-1.2921])[0])
            lng = float(query_params.get('lng', [36.8219])[0])
            response = {
                "location": {"lat": lat, "lng": lng},
                "temperature": round(20 + random.uniform(-5, 10), 1),
                "humidity": random.randint(50, 80),
                "pressure": round(1013 + random.uniform(-20, 20), 1),
                "wind_speed": round(random.uniform(0, 15), 1),
                "wind_direction": random.choice(["N", "NE", "E", "SE", "S", "SW", "W", "NW"]),
                "description": random.choice(["Sunny", "Partly cloudy", "Cloudy", "Light rain"]),
                "icon": "sunny",
                "uv_index": random.randint(1, 10),
                "visibility": random.randint(5, 15),
                "timestamp": datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/weather/forecast':
            self._set_headers(200)
            lat = float(query_params.get('lat', [-1.2921])[0])
            lng = float(query_params.get('lng', [36.8219])[0])
            days = int(query_params.get('days', [7])[0])
            
            forecast = []
            for i in range(min(days, 7)):
                date = datetime.now() + timedelta(days=i)
                forecast.append({
                    "date": date.strftime("%Y-%m-%d"),
                    "temperature_max": random.randint(22, 32),
                    "temperature_min": random.randint(15, 22),
                    "humidity": random.randint(50, 80),
                    "precipitation": round(random.uniform(0, 10), 1),
                    "wind_speed": round(random.uniform(2, 12), 1),
                    "description": random.choice(["Sunny", "Partly cloudy", "Cloudy", "Light rain"]),
                    "icon": "sunny"
                })
            
            response = {
                "location": {"lat": lat, "lng": lng},
                "forecast": forecast
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/weather/alerts':
            self._set_headers(200)
            lat = float(query_params.get('lat', [-1.2921])[0])
            lng = float(query_params.get('lng', [36.8219])[0])
            
            alerts = []
            if random.random() > 0.7:  # 30% chance of alerts
                alerts.append({
                    "id": 1,
                    "type": random.choice(["Heavy Rain Warning", "Drought Alert", "Storm Warning"]),
                    "severity": random.choice(["Low", "Medium", "High"]),
                    "description": "Weather alert for your area",
                    "start_time": datetime.now().isoformat(),
                    "end_time": (datetime.now() + timedelta(hours=24)).isoformat(),
                    "recommendations": [
                        "Take necessary precautions",
                        "Monitor weather conditions",
                        "Protect crops if needed"
                    ]
                })
            
            response = {
                "location": {"lat": lat, "lng": lng},
                "alerts": alerts
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/market/prices':
            self._set_headers(200)
            crops = ["Maize", "Beans", "Tomatoes", "Onions", "Carrots", "Cabbage", "Potatoes", "Rice"]
            prices = []
            for crop in crops:
                base_price = {"Maize": 45, "Beans": 120, "Tomatoes": 80, "Onions": 60, 
                             "Carrots": 70, "Cabbage": 40, "Potatoes": 50, "Rice": 90}
                price = base_price.get(crop, 50) + random.uniform(-10, 20)
                prices.append({
                    "crop": crop,
                    "price_per_kg": round(price, 2),
                    "currency": "KES",
                    "location": "Nairobi",
                    "market": "Wakulima Market",
                    "quality": "Grade A",
                    "trend": random.choice(["up", "down", "stable"]),
                    "change_percentage": round(random.uniform(-5, 5), 1),
                    "last_updated": datetime.now().isoformat()
                })
            response = {"prices": prices}
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/market/buyers':
            self._set_headers(200)
            buyers = [
                {
                    "id": 1,
                    "name": "East Africa Grain Company",
                    "contact": "+254700123456",
                    "email": "procurement@eagc.com",
                    "location": "Nairobi",
                    "crops_interested": ["Maize", "Wheat", "Beans"],
                    "min_quantity": "10 tons",
                    "payment_terms": "30 days",
                    "rating": 4.5,
                    "verified": True
                },
                {
                    "id": 2,
                    "name": "Fresh Produce Exporters",
                    "contact": "+254700654321",
                    "email": "buy@freshexport.com",
                    "location": "Mombasa",
                    "crops_interested": ["Tomatoes", "Peppers", "Onions"],
                    "min_quantity": "5 tons",
                    "payment_terms": "15 days",
                    "rating": 4.2,
                    "verified": True
                }
            ]
            response = {"buyers": buyers}
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/farms':
            self._set_headers(200)
            farms = [
                {
                    "id": 1,
                    "name": "Green Valley Farm",
                    "location": {"lat": -1.2921, "lng": 36.8219},
                    "size": "10 acres",
                    "crops": ["Maize", "Beans", "Tomatoes"],
                    "owner": "John Farmer",
                    "status": "Active",
                    "soil_health": "Good",
                    "last_harvest": "2024-06-15"
                },
                {
                    "id": 2,
                    "name": "Sunrise Agriculture",
                    "location": {"lat": -4.0435, "lng": 39.6682},
                    "size": "25 acres",
                    "crops": ["Coffee", "Bananas"],
                    "owner": "Mary Grower",
                    "status": "Active",
                    "soil_health": "Excellent",
                    "last_harvest": "2024-05-20"
                }
            ]
            response = {"farms": farms}
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self._set_headers(404)
            response = {"error": "Endpoint not found", "path": path}
            self.wfile.write(json.dumps(response).encode())

    def do_POST(self):
        """Handle POST requests"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # Read request body
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)
        
        if path == '/api/v1/auth/login':
            self._set_headers(200)
            response = {
                "access_token": f"token_{random.randint(1000, 9999)}",
                "token_type": "bearer",
                "expires_in": 3600,
                "user": {
                    "id": 1,
                    "name": "John Farmer",
                    "email": "john@example.com",
                    "phone": "+254700000000",
                    "location": "Nairobi, Kenya",
                    "farm_size": "10 acres"
                }
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/auth/register':
            self._set_headers(201)
            response = {
                "message": "User registered successfully",
                "user_id": random.randint(1, 1000),
                "status": "active"
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/disease-detection/detect':
            self._set_headers(200)
            diseases = [
                {"name": "Bacterial Blight", "severity": "High"},
                {"name": "Brown Spot", "severity": "Medium"},
                {"name": "Leaf Blast", "severity": "High"},
                {"name": "Tungro", "severity": "High"},
                {"name": "Healthy", "severity": "None"}
            ]
            disease = random.choice(diseases)
            confidence = random.uniform(0.75, 0.95)
            
            recommendations = []
            if disease["name"] != "Healthy":
                recommendations = [
                    "Apply appropriate fungicide treatment",
                    "Improve air circulation around plants",
                    "Remove affected leaves",
                    "Monitor closely for spread"
                ]
            else:
                recommendations = [
                    "Plant appears healthy",
                    "Continue regular care",
                    "Monitor for any changes"
                ]
            
            response = {
                "disease": disease["name"],
                "severity": disease["severity"],
                "confidence": round(confidence, 2),
                "recommendations": recommendations,
                "detection_id": f"DET_{random.randint(1000, 9999)}",
                "timestamp": datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self._set_headers(404)
            response = {"error": "Endpoint not found", "path": path}
            self.wfile.write(json.dumps(response).encode())

    def log_message(self, format, *args):
        """Override to customize logging"""
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {format % args}")

if __name__ == "__main__":
    PORT = 8000
    Handler = AgriPlatformHandler
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"🌾 Agricultural Intelligence Platform Backend")
        print(f"🚀 Server running at http://localhost:{PORT}")
        print(f"📱 Ready for mobile app connection")
        print(f"❤️  Press Ctrl+C to stop")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Server stopped")
            httpd.shutdown()