# AgriVision Enhanced API Gateway

A production-ready Node.js API gateway that wraps all agricultural services under one unified endpoint. Built specifically for East African farmers with comprehensive security, performance optimizations, and agriculture-specific features.

## 🌟 Key Features

### 🔒 Security & Performance
- **Rate Limiting**: Prevents API abuse with configurable limits
- **CORS Protection**: Secure cross-origin resource sharing
- **Security Headers**: Helmet.js for comprehensive security headers
- **Input Validation**: Express-validator for request sanitization
- **JWT Authentication**: Secure user authentication and authorization
- **Request Logging**: Winston logger for monitoring and debugging
- **Error Handling**: Comprehensive error handling with request IDs

### 🌾 Agriculture-Specific Features
- **Smart Weather Alerts**: Crop-specific warnings (frost, disease risk, irrigation needs)
- **AI Crop Diagnosis**: Disease detection from photos with treatment recommendations
- **Soil Analysis**: Photo-based soil assessment with fertilizer suggestions
- **Yield Prediction**: ML-powered harvest forecasting
- **Market Intelligence**: Local price tracking with selling recommendations

### 🌍 East Africa Optimizations
- **SMS Templates**: Pre-built messages in local context (English/Swahili)
- **M-Pesa Integration**: Full payment flow with transaction history
- **Offline Capabilities**: Structured for eventual offline sync
- **Multi-language Ready**: Framework for Swahili/local languages
- **Local Market Data**: East African market prices and trends

### 👥 Community Features
- **Farmer Profiles**: Analytics and performance tracking
- **Knowledge Sharing**: Community posts and best practices
- **Cooperative Support**: Group management capabilities
- **Expert Consultation**: Connect with agricultural experts

### 💡 Business Intelligence
- **Price Opportunities**: Market finder with transport cost calculations
- **Sustainability Scoring**: Environmental impact tracking
- **Revenue Analytics**: Profit margin analysis and recommendations

## 🚀 Quick Start

### Prerequisites
- Node.js >= 16.0.0
- npm >= 8.0.0

### Installation

1. **Install dependencies:**
```bash
npm install
```

2. **Configure environment:**
```bash
cp .env.enhanced .env
# Edit .env with your API keys and configuration
```

3. **Start the server:**
```bash
# Development mode
npm run dev

# Production mode
npm start
```

4. **Test the API:**
```bash
# Run comprehensive tests
node test-enhanced-api.js

# Or use the original test
node test-api.js
```

## 📚 API Documentation

### Base URL
```
http://localhost:3000
```

### Authentication
Most endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### Core Endpoints

#### Health Check
```http
GET /health
```
Returns system health status and service availability.

#### Authentication
```http
POST /api/auth/register
POST /api/auth/login
```

#### Smart Weather Alerts
```http
GET /api/weather/smart-alerts?lat=-1.2921&lon=36.8219&crops=maize,beans
```
Returns weather data with crop-specific alerts and recommendations.

#### AI Crop Diagnosis
```http
POST /api/ai/crop-diagnosis
Content-Type: multipart/form-data

{
  "image": <file>,
  "crop_type": "maize",
  "symptoms": "Yellow spots on leaves",
  "location": "Nakuru, Kenya"
}
```

#### Soil Analysis
```http
POST /api/soil/analyze
Content-Type: multipart/form-data

{
  "soil_image": <file>,
  "location": "Nakuru, Kenya",
  "crop_planned": "maize"
}
```

#### Yield Prediction
```http
POST /api/yield/predict
{
  "crop_type": "maize",
  "farm_size": 5.5,
  "planting_date": "2024-03-15T00:00:00Z",
  "location": "Nakuru, Kenya",
  "farming_practices": {
    "irrigation": true,
    "fertilizer_use": true,
    "pest_control": true,
    "certified_seeds": true
  }
}
```

#### Market Intelligence
```http
GET /api/market/intelligence?location=Nakuru&crop=maize&radius=50
GET /api/market/opportunities?crops=maize,beans (requires auth)
```

#### SMS Services
```http
GET /api/sms/templates?language=english&category=weather_alerts
POST /api/sms/send-template
{
  "template_id": "weather_frost",
  "recipients": ["+254700000000"],
  "variables": {
    "location": "Nakuru",
    "temp": "2",
    "crop": "maize"
  },
  "language": "english"
}
```

#### M-Pesa Integration
```http
POST /api/mpesa/stkpush
{
  "phone": "+254700000000",
  "amount": 100,
  "account_reference": "AGRIVISION",
  "transaction_desc": "Payment for services"
}

POST /api/mpesa/pay-service (requires auth)
{
  "service_type": "soil_test",
  "phone": "+254700000000",
  "amount": 50
}

GET /api/mpesa/transactions (requires auth)
```

#### Community Features
```http
GET /api/community/posts?category=pest_control&page=1&limit=20
POST /api/community/share (requires auth)
{
  "title": "Effective Pest Control Method",
  "content": "Here's how I control pests...",
  "category": "pest_control",
  "crops": ["maize"]
}

GET /api/community/profile/:userId (requires auth)
```

#### Cooperative Support
```http
POST /api/cooperatives/join (requires auth)
{
  "cooperative_name": "Nakuru Farmers Cooperative",
  "action": "create"
}

GET /api/cooperatives/:cooperativeId (requires auth)
```

#### Analytics
```http
GET /api/analytics/revenue?period=month&crop=maize (requires auth)
GET /api/analytics/sustainability (requires auth)
```

## 🔧 Configuration

### Environment Variables

Key configuration options in `.env`:

```bash
# Server
NODE_ENV=development
PORT=3000
JWT_SECRET=your-super-secret-jwt-key

# External Services
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
MPESA_CONSUMER_KEY=your_mpesa_key
MPESA_CONSUMER_SECRET=your_mpesa_secret
HUGGINGFACE_API_KEY=your_hf_token
OPENAI_API_KEY=your_openai_key

# Features
ENABLE_AI_FEATURES=true
ENABLE_PAYMENT_FEATURES=true
ENABLE_COMMUNITY_FEATURES=true

# East Africa Specific
DEFAULT_COUNTRY=kenya
DEFAULT_CURRENCY=KES
DEFAULT_LANGUAGE=english
SUPPORTED_LANGUAGES=english,swahili
```

### Rate Limiting

Default rate limits:
- General endpoints: 100 requests per 15 minutes
- AI endpoints: 10 requests per minute

Configure in `.env`:
```bash
RATE_LIMIT_MAX_REQUESTS=100
AI_RATE_LIMIT_MAX_REQUESTS=10
```

## 🧪 Testing

### Comprehensive Test Suite
```bash
# Run all tests
node test-enhanced-api.js

# Run specific test categories
npm test
```

Test categories:
- Health checks
- Authentication
- Weather API
- AI features
- Market intelligence
- SMS services
- M-Pesa integration
- Community features
- Analytics
- Performance tests
- Security tests

### Manual Testing
```bash
# Test health endpoint
curl http://localhost:3000/health

# Test weather with authentication
curl -H "Authorization: Bearer <token>" \
     "http://localhost:3000/api/weather/smart-alerts?lat=-1.2921&lon=36.8219&crops=maize"
```

## 📊 Monitoring & Logging

### Logging
- **Winston Logger**: Structured logging with multiple transports
- **Request Logging**: Morgan middleware for HTTP request logging
- **Error Tracking**: Comprehensive error logging with stack traces

Log files:
- `logs/combined.log`: All logs
- `logs/error.log`: Error logs only

### Monitoring Endpoints
```http
GET /health - System health check
GET /metrics - Performance metrics (if enabled)
```

### Request Tracking
Every request gets a unique ID for tracking:
```json
{
  "requestId": "uuid-v4-string",
  "data": "..."
}
```

## 🔐 Security Features

### Authentication & Authorization
- JWT-based authentication
- Protected endpoints require valid tokens
- Token expiration handling

### Input Validation
- Express-validator for request validation
- Sanitization of user inputs
- File upload restrictions

### Security Headers
- Helmet.js for security headers
- CORS configuration
- Content Security Policy

### Rate Limiting
- IP-based rate limiting
- Different limits for different endpoint types
- Configurable windows and limits

## 🌍 East Africa Specific Features

### SMS Templates
Pre-built SMS templates in English and Swahili:
- Weather alerts
- Market price notifications
- Farming tips
- Payment confirmations

### M-Pesa Integration
Full M-Pesa integration with:
- STK Push for payments
- Transaction history
- Service-specific payments
- Callback handling

### Local Market Data
- East African market prices
- Transport cost calculations
- Regional market information
- Currency support (KES, TZS, UGX)

### Multi-language Support
Framework ready for:
- English (default)
- Swahili
- Other local languages

## 🚀 Deployment

### Docker Deployment
```bash
# Build image
npm run docker:build

# Run container
npm run docker:run
```

### Production Checklist
- [ ] Set `NODE_ENV=production`
- [ ] Configure all API keys
- [ ] Set up proper database
- [ ] Configure CORS origins
- [ ] Set up SSL/TLS
- [ ] Configure monitoring
- [ ] Set up log rotation
- [ ] Configure backup strategy

### Environment-Specific Configuration
```bash
# Development
NODE_ENV=development
MOCK_EXTERNAL_APIS=true

# Production
NODE_ENV=production
MOCK_EXTERNAL_APIS=false
ALLOWED_ORIGINS=https://agrivision.com
```

## 📈 Performance Optimization

### Caching
- Node-cache for in-memory caching
- Weather data cached for 5 minutes
- Market data cached for 10 minutes

### Compression
- Gzip compression enabled
- Response compression for better performance

### Database Optimization
- Connection pooling (when using database)
- Query optimization
- Indexing strategies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Run the test suite
6. Submit a pull request

### Code Style
- ESLint configuration included
- Run `npm run lint` before committing
- Follow existing code patterns

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Check the test suite for examples
- Review the API documentation

## 🔄 Version History

### v2.0.0 (Enhanced)
- Added comprehensive security features
- Implemented East Africa optimizations
- Added AI-powered crop diagnosis
- Enhanced market intelligence
- Community and cooperative features
- Business intelligence analytics

### v1.0.0 (Original)
- Basic API gateway functionality
- Weather, SMS, M-Pesa integration
- Simple market data
- Basic error handling

---

**Built with ❤️ for East African farmers** 🌾