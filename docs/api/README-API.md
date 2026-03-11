# 🌾 AgriVision API Gateway

A comprehensive single-file backend API for agricultural intelligence platforms. Designed as a "free-first" MVP solution that integrates multiple services farmers need.

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your API keys
```

### 3. Run the Server
```bash
# Development mode
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3000`

## 📡 API Endpoints

### Health Check
```http
GET /health
```

### 🌤️ Weather Services
```http
# Get current weather and forecast
GET /api/weather/current?lat=-1.286389&lon=36.817223

Response:
{
  "current": {
    "temperature": 24.5,
    "humidity": 65,
    "wind_speed": 12.3,
    "weather_code": 1,
    "time": "2024-01-15T10:00"
  },
  "hourly": { ... },
  "daily": { ... },
  "farming_advice": [
    {
      "type": "info",
      "message": "Good conditions for planting",
      "priority": "medium"
    }
  ]
}
```

### 📱 SMS Services
```http
# Send single SMS
POST /api/sms/send
Content-Type: application/json

{
  "to": "+254700123456",
  "message": "Weather alert: Heavy rains expected tomorrow",
  "type": "alert"
}

# Send bulk SMS
POST /api/sms/bulk
Content-Type: application/json

{
  "recipients": ["+254700123456", "+254700123457"],
  "message": "Market prices updated. Check the app for details."
}
```

### 💰 M-Pesa Integration
```http
# Initiate STK Push payment
POST /api/mpesa/stkpush
Content-Type: application/json

{
  "phone": "254700123456",
  "amount": 100,
  "account_reference": "LOAN001",
  "transaction_desc": "Loan repayment"
}

Response:
{
  "CheckoutRequestID": "ws_CO_191220191020363925",
  "ResponseDescription": "Success. Request accepted for processing",
  "ResponseCode": "0"
}
```

### 📊 Market Data
```http
# Get market prices
GET /api/market/prices?country=kenya&crop=maize

Response:
{
  "crop": "maize",
  "country": "kenya",
  "price": 45.50,
  "currency": "KES",
  "unit": "kg",
  "change": 2.3,
  "market": "Nairobi",
  "lastUpdated": "2024-01-15T10:00:00Z"
}

# Get price history
GET /api/market/history/maize?days=30

Response:
{
  "crop": "maize",
  "period": "30 days",
  "history": [
    {
      "date": "2024-01-01",
      "price": 43.20,
      "volume": 450
    }
  ],
  "summary": {
    "average": 44.85,
    "highest": 47.20,
    "lowest": 42.10,
    "trend": "up"
  }
}
```

### 🗺️ Geocoding Services
```http
# Geocode address
GET /api/geocode?address=Nairobi, Kenya

# Reverse geocode
GET /api/reverse-geocode?lat=-1.286389&lon=36.817223
```

### 🔔 Push Notifications
```http
POST /api/notifications/send
Content-Type: application/json

{
  "token": "firebase_device_token",
  "title": "Weather Alert",
  "body": "Heavy rains expected in your area",
  "data": {
    "type": "weather_alert",
    "severity": "high"
  }
}
```

### 🎥 Video/Voice (Agora)
```http
POST /api/agora/token
Content-Type: application/json

{
  "channelName": "expert_consultation_123",
  "uid": "user_456",
  "role": 1
}

Response:
{
  "token": "agora_rtc_token",
  "channelName": "expert_consultation_123",
  "uid": "user_456",
  "appId": "your_agora_app_id",
  "expiresAt": "2024-01-15T11:00:00Z"
}
```

### 🤖 AI/ML Services
```http
POST /api/ai/detect-disease
Content-Type: application/json

{
  "image_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
  "crop_type": "maize"
}

Response:
{
  "crop_type": "maize",
  "predictions": [
    {
      "name": "Leaf Blight",
      "confidence": 0.85,
      "severity": "moderate"
    }
  ],
  "top_prediction": {
    "name": "Leaf Blight",
    "confidence": 0.85,
    "severity": "moderate"
  },
  "recommendations": [
    "Apply copper-based fungicide",
    "Improve air circulation around plants"
  ]
}
```

### 👨‍🌾 Expert Consultation
```http
# Get available experts
GET /api/experts?specialty=crop_diseases&language=english

# Book consultation
POST /api/experts/book
Content-Type: application/json

{
  "expert_id": "exp_001",
  "date": "2024-01-20",
  "time": "14:00",
  "duration": 30,
  "topic": "Maize disease identification"
}
```

## 🔧 Configuration

### Required API Keys

1. **Twilio** (SMS Service)
   - Sign up: https://www.twilio.com/
   - Get: Account SID, Auth Token, Phone Number

2. **M-Pesa Daraja API** (Mobile Payments)
   - Apply: https://developer.safaricom.co.ke/
   - Get: Consumer Key, Consumer Secret, Shortcode, Passkey

3. **Firebase** (Auth & Notifications)
   - Create project: https://console.firebase.google.com/
   - Download service account key

4. **Agora** (Video/Voice)
   - Sign up: https://www.agora.io/
   - Get: App ID, App Certificate

5. **Hugging Face** (AI/ML)
   - Sign up: https://huggingface.co/
   - Get: API Token

### Free Services Used

- **Weather**: Open-Meteo (Free, no API key required)
- **Geocoding**: OpenStreetMap Nominatim (Free, no API key required)
- **Market Data**: Mock data (replace with real APIs)

## 🐳 Docker Deployment

```bash
# Build Docker image
docker build -t agrivision-api .

# Run container
docker run -p 3000:3000 --env-file .env agrivision-api
```

## 🌍 Production Deployment

### Heroku
```bash
# Install Heroku CLI
npm install -g heroku

# Login and create app
heroku login
heroku create agrivision-api

# Set environment variables
heroku config:set TWILIO_ACCOUNT_SID=your_sid
heroku config:set TWILIO_AUTH_TOKEN=your_token
# ... set all other env vars

# Deploy
git push heroku main
```

### Railway
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### DigitalOcean App Platform
1. Connect your GitHub repository
2. Set environment variables in the dashboard
3. Deploy automatically

## 📊 Monitoring & Analytics

The API includes built-in logging and error handling. For production, consider adding:

- **Logging**: Winston, Morgan
- **Monitoring**: New Relic, DataDog
- **Analytics**: Google Analytics, Mixpanel
- **Error Tracking**: Sentry

## 🔒 Security Features

- CORS enabled for cross-origin requests
- Input validation on all endpoints
- Rate limiting (add express-rate-limit)
- Environment variable configuration
- Error handling without exposing internals

## 🧪 Testing

```bash
# Run tests
npm test

# Test specific endpoint
curl -X GET http://localhost:3000/health
```

## 📈 Scaling Considerations

For high-traffic production use:

1. **Database**: Add PostgreSQL/MongoDB for persistent storage
2. **Caching**: Implement Redis for frequently accessed data
3. **Load Balancing**: Use nginx or cloud load balancers
4. **Microservices**: Split into separate services as needed
5. **Queue System**: Add Bull/Bee-Queue for background jobs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

- 📧 Email: support@agrivision.com
- 💬 Discord: https://discord.gg/agrivision
- 📖 Documentation: https://docs.agrivision.com
- 🐛 Issues: https://github.com/agrivision/api-gateway/issues

---

**Built with ❤️ for African farmers** 🌾