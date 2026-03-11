#!/usr/bin/env python3
"""
Simple HTTP server for Agricultural Intelligence Platform
This serves as a mock backend for testing the mobile app
"""

import json
import http.server
import socketserver
from urllib.parse import urlparse, parse_qs
from datetime import datetime, timedelta
import random

class AgriPlatformHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_GET(self):
        """Handle GET requests"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        query_params = parse_qs(parsed_path.query)
        
        if path == '/':
            self.send_response(200)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                "message": "Agricultural Intelligence Platform API",
                "version": "1.0.0",
                "status": "operational"
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/health':
            self.send_response(200)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {"status": "healthy", "timestamp": datetime.now().isoformat()}
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/weather/current':
            self.send_response(200)
            self.end_headers()
            lat = query_params.get('lat', [-1.2921])[0]
            lng = query_params.get('lng', [36.8219])[0]
            response = {
                "location": {"lat": float(lat), "lng": float(lng)},
                "temperature": round(20 + random.uniform(-5, 10), 1),
                "humidity": random.randint(50, 80),
                "pressure": round(1013 + random.uniform(-20, 20), 1),
                "wind_speed": round(random.uniform(0, 15), 1),
                "description": random.choice(["Sunny", "Partly cloudy", "Cloudy", "Light rain"]),
                "timestamp": datetime.now().isoformat()
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/weather/forecast':
            self.send_response(200)
            self.end_headers()
            lat = query_params.get('lat', [-1.2921])[0]
            lng = query_params.get('lng', [36.8219])[0]
            forecast = []
            for i in range(7):
                date = datetime.now() + timedelta(days=i)
                forecast.append({
                    "date": date.strftime("%Y-%m-%d"),
                    "temperature_max": random.randint(22, 32),
                    "temperature_min": random.randint(15, 22),
                    "humidity": random.randint(50, 80),
                    "precipitation": round(random.uniform(0, 10), 1),
                    "description": random.choice(["Sunny", "Partly cloudy", "Cloudy", "Light rain"])
                })
            response = {
                "location": {"lat": float(lat), "lng": float(lng)},
                "forecast": forecast
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/market/prices':
            self.send_response(200)
            self.end_headers()
            crops = ["Maize", "Beans", "Tomatoes", "Onions", "Carrots", "Cabbage"]
            prices = []
            for crop in crops:
                prices.append({
                    "crop": crop,
                    "price_per_kg": round(random.uniform(20, 150), 2),
                    "currency": "KES",
                    "location": "Nairobi",
                    "trend": random.choice(["up", "down", "stable"]),
                    "last_updated": datetime.now().isoformat()
                })
            response = {"prices": prices}
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/farms':
            self.send_response(200)
            self.end_headers()
            response = {
                "farms": [
                    {
                        "id": 1,
                        "name": "Green Valley Farm",
                        "location": {"lat": -1.2921, "lng": 36.8219},
                        "size": "10 acres",
                        "crops": ["Maize", "Beans", "Tomatoes"],
                        "owner": "John Farmer",
                        "status": "Active"
                    },
                    {
                        "id": 2,
                        "name": "Sunrise Agriculture",
                        "location": {"lat": -4.0435, "lng": 39.6682},
                        "size": "25 acres",
                        "crops": ["Coffee", "Bananas"],
                        "owner": "Mary Grower",
                        "status": "Active"
                    }
                ]
            }
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self.send_response(404)
            self.end_headers()
            response = {"error": "Not found"}
            self.wfile.write(json.dumps(response).encode())

    def do_POST(self):
        """Handle POST requests"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Type', 'application/json')
        
        if path == '/api/v1/auth/login':
            self.send_response(200)
            self.end_headers()
            response = {
                "access_token": "sample_token_123",
                "token_type": "bearer",
                "user": {
                    "id": 1,
                    "name": "John Farmer",
                    "email": "john@example.com",
                    "phone": "+254700000000"
                }
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/auth/register':
            self.send_response(201)
            self.end_headers()
            response = {
                "message": "User registered successfully",
                "user_id": random.randint(1, 1000)
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/api/v1/disease-detection/detect':
            self.send_response(200)
            self.end_headers()
            diseases = ["Leaf Blight", "Brown Spot", "Bacterial Blight", "Healthy"]
            disease = random.choice(diseases)
            confidence = random.uniform(0.7, 0.95)
            response = {
                "disease": disease,
                "confidence": round(confidence, 2),
                "recommendations": [
                    "Apply appropriate fungicide treatment",
                    "Improve air circulation around plants",
                    "Remove affected leaves if necessary"
                ] if disease != "Healthy" else ["Plant appears healthy", "Continue regular care"]
            }
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self.send_response(404)
            self.end_headers()
            response = {"error": "Not found"}
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
        print(f"📚 API Documentation: http://localhost:{PORT}")
        print(f"❤️  Press Ctrl+C to stop")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Server stopped")
            httpd.shutdown()