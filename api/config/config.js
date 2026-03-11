/**
 * Configuration management for AgriVision API Gateway
 */

require('dotenv').config();

const config = {
  // Server Configuration
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT) || 3000,
  
  // Security
  JWT_SECRET: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  
  // Database (for production use)
  DATABASE_URL: process.env.DATABASE_URL || 'sqlite:./agrivision.db',
  
  // External Services
  TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID || 'your_twilio_sid',
  TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN || 'your_twilio_token',
  TWILIO_PHONE_NUMBER: process.env.TWILIO_PHONE_NUMBER || '+1234567890',
  
  // M-Pesa Configuration
  MPESA_ENV: process.env.MPESA_ENV || 'sandbox',
  MPESA_CONSUMER_KEY: process.env.MPESA_CONSUMER_KEY || 'your_mpesa_key',
  MPESA_CONSUMER_SECRET: process.env.MPESA_CONSUMER_SECRET || 'your_mpesa_secret',
  MPESA_SHORTCODE: process.env.MPESA_SHORTCODE || '174379',
  MPESA_PASSKEY: process.env.MPESA_PASSKEY || 'your_passkey',
  MPESA_BASE_URL: process.env.MPESA_ENV === 'production' 
    ? 'https://api.safaricom.co.ke' 
    : 'https://sandbox.safaricom.co.ke',
  
  // Firebase
  FIREBASE_PROJECT_ID: process.env.FIREBASE_PROJECT_ID || 'your-project-id',
  
  // AI/ML Services
  HUGGINGFACE_API_KEY: process.env.HUGGINGFACE_API_KEY || 'your_hf_token',
  OPENAI_API_KEY: process.env.OPENAI_API_KEY || 'your_openai_key',
  
  // Weather API
  WEATHER_API_URL: 'https://api.open-meteo.com/v1',
  WEATHER_CACHE_TTL: parseInt(process.env.WEATHER_CACHE_TTL) || 300,
  
  // Market Data
  ALPHA_VANTAGE_KEY: process.env.ALPHA_VANTAGE_KEY || 'your_alpha_vantage_key',
  MARKET_DATA_CACHE_TTL: parseInt(process.env.MARKET_DATA_CACHE_TTL) || 600,
  
  // Geocoding
  GEOCODING_API_URL: 'https://nominatim.openstreetmap.org',
  
  // Agora (Video/Voice)
  AGORA_APP_ID: process.env.AGORA_APP_ID || 'your_agora_app_id',
  AGORA_APP_CERTIFICATE: process.env.AGORA_APP_CERTIFICATE || 'your_agora_certificate',
  
  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000, // 15 minutes
  RATE_LIMIT_MAX_REQUESTS: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  AI_RATE_LIMIT_WINDOW_MS: parseInt(process.env.AI_RATE_LIMIT_WINDOW_MS) || 60000, // 1 minute
  AI_RATE_LIMIT_MAX_REQUESTS: parseInt(process.env.AI_RATE_LIMIT_MAX_REQUESTS) || 10,
  
  // CORS
  ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS || 'https://agrivision.com,https://app.agrivision.com',
  
  // Feature Flags
  ENABLE_AI_FEATURES: process.env.ENABLE_AI_FEATURES !== 'false',
  ENABLE_PAYMENT_FEATURES: process.env.ENABLE_PAYMENT_FEATURES !== 'false',
  ENABLE_COMMUNITY_FEATURES: process.env.ENABLE_COMMUNITY_FEATURES !== 'false',
  ENABLE_ANALYTICS: process.env.ENABLE_ANALYTICS !== 'false',
  
  // East Africa Specific
  DEFAULT_COUNTRY: process.env.DEFAULT_COUNTRY || 'kenya',
  DEFAULT_CURRENCY: process.env.DEFAULT_CURRENCY || 'KES',
  DEFAULT_LANGUAGE: process.env.DEFAULT_LANGUAGE || 'english',
  SUPPORTED_LANGUAGES: process.env.SUPPORTED_LANGUAGES || 'english,swahili',
  
  // File Upload
  MAX_FILE_SIZE: parseInt(process.env.MAX_FILE_SIZE) || 10485760, // 10MB
  ALLOWED_FILE_TYPES: process.env.ALLOWED_FILE_TYPES || 'image/jpeg,image/png,image/webp',
  
  // Logging
  LOG_LEVEL: process.env.LOG_LEVEL || 'info',
  LOG_FILE_MAX_SIZE: process.env.LOG_FILE_MAX_SIZE || '10m',
  LOG_FILE_MAX_FILES: parseInt(process.env.LOG_FILE_MAX_FILES) || 5,
  
  // Monitoring
  SENTRY_DSN: process.env.SENTRY_DSN,
  ENABLE_METRICS_ENDPOINT: process.env.ENABLE_METRICS_ENDPOINT === 'true',
  
  // Development/Testing
  MOCK_EXTERNAL_APIS: process.env.MOCK_EXTERNAL_APIS === 'true',
  ENABLE_API_DOCS: process.env.ENABLE_API_DOCS !== 'false'
};

// Validation
const requiredEnvVars = ['JWT_SECRET'];
const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar] || process.env[envVar] === `your_${envVar.toLowerCase()}`);

if (missingEnvVars.length > 0 && config.NODE_ENV === 'production') {
  console.error('Missing required environment variables:', missingEnvVars);
  process.exit(1);
}

module.exports = config;