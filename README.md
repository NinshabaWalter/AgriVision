<<<<<<< HEAD
# 🌾 AgriVision - Agricultural Intelligence Platform

A comprehensive agricultural intelligence platform designed specifically for East African farmers, providing AI-powered crop disease detection, weather predictions, market insights, and financial services.

> **📁 Project Recently Organized!** All files have been organized into clean, logical folders. See [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md) for the new layout.

## 🌟 Features

### Core Features
- **🔍 AI-Powered Disease Detection**: Use phone cameras to identify crop diseases with machine learning
- **🌤️ Weather Predictions**: Micro-climate specific weather data and alerts
- **📈 Market Intelligence**: Real-time crop prices and buyer connections
- **🌱 Soil Health Monitoring**: Soil analysis and farming recommendations
- **💰 Microfinance & Insurance**: Access to agricultural loans and crop insurance
- **📦 Supply Chain Tracking**: Track produce from farm to market

### Technical Features
- **📱 Offline-First**: Works without internet connection in rural areas
- **🌍 Multi-Language**: Supports English, Swahili, Amharic, and French
- **📲 SMS Integration**: Critical alerts via SMS for areas with limited internet
- **🔒 Secure**: End-to-end encryption for financial transactions
- **⚡ Performance**: Optimized for low-end Android devices

## 🏗️ Architecture

### Mobile App (Flutter)
```
mobile/
├── lib/
│   ├── core/                 # Core utilities and services
│   │   ├── services/         # API, Storage, ML, Camera services
│   │   ├── theme/           # App theming
│   │   └── router/          # Navigation
│   ├── features/            # Feature modules
│   │   ├── auth/            # Authentication
│   │   ├── disease_detection/ # AI disease detection
│   │   ├── weather/         # Weather services
│   │   ├── market/          # Market data
│   │   ├── finance/         # Loans and insurance
│   │   └── supply_chain/    # Supply chain tracking
│   └── main.dart
```

### Backend API (FastAPI + Python)
```
backend/
├── app/
│   ├── api/v1/              # API endpoints
│   ├── core/                # Core utilities
│   ├── models/              # Database models
│   ├── services/            # Business logic
│   └── main.py
├── requirements.txt
└── Dockerfile
```

## 🚀 Quick Start

### 📱 **Run iOS App** (Recommended)
```bash
# Launch iOS app with automatic fixes
./scripts/ios/run-ios-app.sh

# Or diagnose any issues first
./scripts/ios/diagnose-ios-app.sh
```

### 🌐 **Start API Gateway**
```bash
# Start organized API gateway
./scripts/api/start-organized-api.sh

# Or start manually
npm start
```

### 📚 **Full Documentation**
- **📖 Getting Started**: `docs/guides/RUN_AGRIVISION.md`
- **🏗️ Project Structure**: `PROJECT-STRUCTURE.md`
- **🔧 iOS Troubleshooting**: `docs/guides/iOS-APP-NAME-GUIDE.md`
- **🌐 API Documentation**: `docs/api/README-ENHANCED-API.md`

## 🏗️ Detailed Setup

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (16+)
- Python 3.9+
- Xcode (for iOS development)
- Docker (optional)

### Backend Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd AgriculturalIntelligencePlatform
```

2. **Set up Python environment**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Set up database**
```bash
# Install PostgreSQL and PostGIS
# Create database
createdb agricultural_platform

# Run migrations
alembic upgrade head
```

5. **Start the backend**
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Mobile App Setup

1. **Install Flutter dependencies**
```bash
cd mobile
flutter pub get
```

2. **Generate code**
```bash
flutter packages pub run build_runner build
```

3. **Configure Firebase** (for notifications)
- Create a Firebase project
- Add Android/iOS apps
- Download configuration files
- Place them in the appropriate directories

4. **Run the app**
```bash
flutter run
```

## 🔧 Configuration

### Backend Configuration (.env)
```env
# Database
DATABASE_URL=postgresql://user:password@localhost/agricultural_platform
REDIS_URL=redis://localhost:6379

# Security
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# External APIs
OPENWEATHER_API_KEY=your-openweather-key
SENTRY_DSN=your-sentry-dsn

# ML Models
ML_MODEL_PATH=./models
DISEASE_DETECTION_MODEL=disease_detection.tflite

# Storage
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760  # 10MB
```

### Mobile Configuration
Update `lib/core/app_config.dart` with your backend URL and API keys.

## 🤖 Machine Learning Models

### Disease Detection Model
- **Framework**: TensorFlow Lite
- **Input**: 224x224 RGB images
- **Output**: Disease classification with confidence scores
- **Supported Diseases**: 
  - Bacterial Blight
  - Brown Spot
  - Leaf Blast
  - Tungro
  - Bacterial Leaf Streak
  - Sheath Blight

### Training Data
The model is trained on a dataset of crop disease images specific to East African crops and conditions.

## 📱 Mobile Features

### Offline Capabilities
- Disease detection works offline using on-device ML
- Weather data cached for 7 days
- Market prices cached locally
- Automatic sync when connection restored

### Camera Integration
- Real-time disease detection
- Image preprocessing for better accuracy
- Multiple image formats supported
- Batch processing capability

### Notifications
- Weather alerts
- Disease detection results
- Market price changes
- Loan application updates
- SMS fallback for critical alerts

## 🌐 API Documentation

### Authentication Endpoints
```
POST /api/v1/auth/register    # User registration
POST /api/v1/auth/login       # User login
POST /api/v1/auth/refresh     # Token refresh
```

### Disease Detection Endpoints
```
POST /api/v1/disease-detection/detect     # Detect disease from image
GET  /api/v1/disease-detection/detections # Get detection history
GET  /api/v1/disease-detection/disease-types # Get disease information
```

### Weather Endpoints
```
GET /api/v1/weather/current   # Current weather
GET /api/v1/weather/forecast  # Weather forecast
GET /api/v1/weather/alerts    # Weather alerts
```

### Market Endpoints
```
GET /api/v1/market/prices     # Market prices
GET /api/v1/market/buyers     # Buyer connections
POST /api/v1/market/transactions # Record transactions
```

## 🔒 Security

### Data Protection
- All sensitive data encrypted at rest
- API communications over HTTPS
- JWT tokens for authentication
- Rate limiting on all endpoints

### Privacy
- User data anonymized for analytics
- GDPR compliant data handling
- User consent for data collection
- Right to data deletion

## 🌍 Localization

### Supported Languages
- **English** (en) - Primary language
- **Swahili** (sw) - Kenya, Tanzania, Uganda
- **Amharic** (am) - Ethiopia
- **French** (fr) - Rwanda, Burundi, DRC

### Adding New Languages
1. Add locale to `pubspec.yaml`
2. Create ARB files in `lib/l10n/`
3. Run `flutter gen-l10n`
4. Update language selection in settings

## 📊 Analytics & Monitoring

### Backend Monitoring
- **Sentry**: Error tracking and performance monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and alerting
- **ELK Stack**: Log aggregation and analysis

### Mobile Analytics
- **Firebase Analytics**: User behavior tracking
- **Crashlytics**: Crash reporting
- **Performance Monitoring**: App performance metrics

## 🚀 Deployment

### Backend Deployment (Docker)
```bash
# Build image
docker build -t agricultural-platform-backend .

# Run container
docker run -p 8000:8000 agricultural-platform-backend
```

### Mobile App Deployment
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Infrastructure (AWS/GCP)
- **Compute**: ECS/GKE for backend services
- **Database**: RDS PostgreSQL with PostGIS
- **Storage**: S3/Cloud Storage for images
- **CDN**: CloudFront/Cloud CDN for static assets
- **Monitoring**: CloudWatch/Cloud Monitoring

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Standards
- **Backend**: Follow PEP 8 for Python
- **Mobile**: Follow Dart style guide
- **Documentation**: Update README for new features
- **Testing**: Maintain >80% code coverage

### Commit Messages
```
feat: add disease detection for maize
fix: resolve camera permission issue
docs: update API documentation
test: add unit tests for weather service
```

## 📈 Roadmap

### Phase 1 (Current)
- ✅ Core disease detection
- ✅ Weather integration
- ✅ Basic market data
- ✅ User authentication

### Phase 2 (Q2 2024)
- 🔄 Advanced ML models
- 🔄 IoT sensor integration
- 🔄 Blockchain supply chain
- 🔄 Advanced analytics

### Phase 3 (Q3 2024)
- 📋 Drone integration
- 📋 Satellite imagery
- 📋 AI-powered recommendations
- 📋 Marketplace platform

### Phase 4 (Q4 2024)
- 📋 Carbon credit tracking
- 📋 Climate adaptation tools
- 📋 Regional expansion
- 📋 Enterprise features

## 📞 Support

### Documentation
- **API Docs**: Available at `/docs` when running backend
- **User Guide**: Available in the mobile app
- **Developer Docs**: See `/docs` folder

### Community
- **Discord**: Join our developer community
- **GitHub Issues**: Report bugs and request features
- **Email**: support@agriplatform.com

### Commercial Support
For enterprise deployments and custom features, contact our team at enterprise@agriplatform.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenWeatherMap**: Weather data API
- **TensorFlow**: Machine learning framework
- **Flutter Team**: Mobile development framework
- **FastAPI**: Backend framework
- **East African Farmers**: For their invaluable feedback and testing

---

**Built with ❤️ for East African farmers**

*Empowering agriculture through technology*
=======
# AgriVision
AgriVision is a computer vision system designed to help farmers detect crop diseases using AI.
>>>>>>> 7b5e2353cf55dfe0848193881eb48658434db7ac
