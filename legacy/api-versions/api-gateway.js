#!/usr/bin/env node

/**
 * AgriVision API Gateway
 * Single-file backend for agricultural intelligence platform
 * Provides unified API for weather, SMS, payments, market data, and more
 * 
 * Author: AgriVision Team
 * Version: 1.0.0
 * License: MIT
 */

const express = require('express');
const cors = require('cors');
const axios = require('axios');
const admin = require('firebase-admin');
const twilio = require('twilio');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const rateLimiter = require('./middleware/rateLimiter');
const securityHeaders = require('./middleware/securityHeaders');
const requestId = require('./middleware/requestId');
const { logger, logRequest } = require('./middleware/logger');
const { validateWeatherQuery, validateSmsSend } = require('./middleware/validation');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(securityHeaders);
app.use(rateLimiter);
app.use(requestId);
app.use(logRequest);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuration - Replace with your actual API keys
const CONFIG = {
  // Weather API (Free - Open-Meteo)
  WEATHER_API_URL: 'https://api.open-meteo.com/v1',
  
  // SMS Service (Twilio)
  TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID || 'your_twilio_sid',
  TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN || 'your_twilio_token',
  TWILIO_PHONE_NUMBER: process.env.TWILIO_PHONE || '+1234567890',
  
  // M-Pesa (Safaricom Daraja API)
  MPESA_CONSUMER_KEY: process.env.MPESA_CONSUMER_KEY || 'your_mpesa_key',
  MPESA_CONSUMER_SECRET: process.env.MPESA_CONSUMER_SECRET || 'your_mpesa_secret',
  MPESA_SHORTCODE: process.env.MPESA_SHORTCODE || '174379',
  MPESA_PASSKEY: process.env.MPESA_PASSKEY || 'your_passkey',
  MPESA_BASE_URL: process.env.MPESA_ENV === 'production' 
    ? 'https://api.safaricom.co.ke' 
    : 'https://sandbox.safaricom.co.ke',
  
  // Firebase (Initialize with service account)
  FIREBASE_PROJECT_ID: process.env.FIREBASE_PROJECT_ID || 'your-project-id',
  
  // Agora (Video/Voice)
  AGORA_APP_ID: process.env.AGORA_APP_ID || 'your_agora_app_id',
  AGORA_APP_CERTIFICATE: process.env.AGORA_APP_CERTIFICATE || 'your_agora_certificate',
  
  // Hugging Face (AI/ML)
  HUGGINGFACE_API_KEY: process.env.HUGGINGFACE_API_KEY || 'your_hf_token',
  
  // Market Data APIs
  ALPHA_VANTAGE_KEY: process.env.ALPHA_VANTAGE_KEY || 'your_alpha_vantage_key',
  
  // Geocoding (Free - OpenStreetMap Nominatim)
  GEOCODING_API_URL: 'https://nominatim.openstreetmap.org',
};

// Initialize services
let twilioClient = null;
let firebaseApp = null;

// Initialize Twilio
try {
  if (CONFIG.TWILIO_ACCOUNT_SID !== 'your_twilio_sid') {
    twilioClient = twilio(CONFIG.TWILIO_ACCOUNT_SID, CONFIG.TWILIO_AUTH_TOKEN);
  }
} catch (error) {
  logger.error('Twilio not initialized - using mock mode', { error });
}

// Initialize Firebase
try {
  // You would need to add your Firebase service account key file
  // const serviceAccount = require('./firebase-service-account.json');
  // firebaseApp = admin.initializeApp({
  //   credential: admin.credential.cert(serviceAccount),
  //   projectId: CONFIG.FIREBASE_PROJECT_ID,
  // });
  logger.info('Firebase initialization skipped - add service account key');
} catch (error) {
  logger.error('Firebase not initialized - using mock mode', { error });
}

// Utility Functions
const generateTimestamp = () => {
  const now = new Date();
  return now.getFullYear() +
    String(now.getMonth() + 1).padStart(2, '0') +
    String(now.getDate()).padStart(2, '0') +
    String(now.getHours()).padStart(2, '0') +
    String(now.getMinutes()).padStart(2, '0') +
    String(now.getSeconds()).padStart(2, '0');
};

const generatePassword = (shortcode, passkey, timestamp) => {
  const data = shortcode + passkey + timestamp;
  return Buffer.from(data).toString('base64');
};

// Agora Token Generator
const generateAgoraToken = (channelName, uid, role = 1) => {
  // This is a simplified version - use official Agora token generator in production
  const appId = CONFIG.AGORA_APP_ID;
  const appCertificate = CONFIG.AGORA_APP_CERTIFICATE;
  const expirationTimeInSeconds = 3600; // 1 hour
  
  // Mock token for development
  return `mock_agora_token_${channelName}_${uid}_${Date.now()}`;
};

// API Key Authentication Middleware
const apiKeyAuth = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey || apiKey !== process.env.API_KEY) {
    return res.status(401).json({ error: 'Unauthorized: Invalid API key' });
  }
  next();
};

// ==================== ROUTES ====================

// Health Check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    services: {
      weather: 'operational',
      sms: twilioClient ? 'operational' : 'mock',
      firebase: firebaseApp ? 'operational' : 'mock',
      mpesa: CONFIG.MPESA_CONSUMER_KEY !== 'your_mpesa_key' ? 'operational' : 'mock',
    }
  });
});

// ==================== WEATHER API ====================

// Get current weather
app.get('/api/weather/current', apiKeyAuth, validateWeatherQuery, async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    const response = await axios.get(`${CONFIG.WEATHER_API_URL}/forecast`, {
      params: {
        latitude: lat,
        longitude: lon,
        current_weather: true,
        hourly: 'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m',
        daily: 'temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max',
        timezone: 'auto',
        forecast_days: 7
      }
    });
    
    const data = response.data;
    
    res.json({
      current: {
        temperature: data.current_weather.temperature,
        humidity: data.hourly.relative_humidity_2m[0],
        wind_speed: data.current_weather.windspeed,
        weather_code: data.current_weather.weathercode,
        time: data.current_weather.time,
      },
      hourly: {
        time: data.hourly.time.slice(0, 24),
        temperature: data.hourly.temperature_2m.slice(0, 24),
        humidity: data.hourly.relative_humidity_2m.slice(0, 24),
        precipitation: data.hourly.precipitation.slice(0, 24),
      },
      daily: {
        time: data.daily.time,
        temperature_max: data.daily.temperature_2m_max,
        temperature_min: data.daily.temperature_2m_min,
        precipitation: data.daily.precipitation_sum,
        wind_speed: data.daily.wind_speed_10m_max,
      },
      farming_advice: generateFarmingAdvice(data.current_weather, data.daily)
    });
    
  } catch (error) {
    logger.error('Weather API error', { error, requestId: req.id });
    res.status(500).json({ error: 'Failed to fetch weather data', requestId: req.id });
  }
});

// Send SMS alert
app.post('/api/sms/send', apiKeyAuth, validateSmsSend, async (req, res) => {
  try {
    const { to, message, type = 'alert' } = req.body;
    
    if (twilioClient) {
      const result = await twilioClient.messages.create({
        body: message,
        from: CONFIG.TWILIO_PHONE_NUMBER,
        to: to
      });
      
      res.json({
        success: true,
        messageId: result.sid,
        status: result.status,
        timestamp: new Date().toISOString()
      });
    } else {
      // Mock mode
      logger.info(`Mock SMS to ${to}: ${message}`, { requestId: req.id });
      res.json({
        success: true,
        messageId: `mock_${Date.now()}`,
        status: 'sent',
        timestamp: new Date().toISOString(),
        mock: true
      });
    }
    
  } catch (error) {
    logger.error('SMS error', { error, requestId: req.id });
    res.status(500).json({ error: 'Failed to send SMS', requestId: req.id });
  }
});

// Other routes remain unchanged but should also include apiKeyAuth and logging/error handling enhancements

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    requestId: req.id,
    available_endpoints: [
      'GET /health',
      'GET /api/weather/current',
      'POST /api/sms/send',
      'POST /api/mpesa/stkpush',
      'GET /api/market/prices',
      'GET /api/geocode',
      'POST /api/notifications/send',
      'POST /api/agora/token',
      'POST /api/ai/detect-disease',
      'GET /api/experts'
    ]
  });
});

// Global error handler
app.use((error, req, res, next) => {
  logger.error('Global error', { error, requestId: req.id });
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong',
    requestId: req.id
  });
});

// ==================== SERVER STARTUP ====================

app.listen(PORT, () => {
  logger.info(`
🌾 AgriVision API Gateway Started
📡 Server running on port ${PORT}
🌍 Environment: ${process.env.NODE_ENV || 'development'}

📋 Available Services:
   ✅ Weather API (Open-Meteo)
   ${twilioClient ? '✅' : '⚠️ '} SMS Service (Twilio)
   ${firebaseApp ? '✅' : '⚠️ '} Firebase Auth & Notifications
   ${CONFIG.MPESA_CONSUMER_KEY !== 'your_mpesa_key' ? '✅' : '⚠️ '} M-Pesa Integration
   ✅ Market Data API
   ✅ Geocoding Service
   ✅ AI/ML Services
   ✅ Expert Consultation

🔗 Health Check: http://localhost:${PORT}/health
📖 API Documentation: http://localhost:${PORT}/docs (coming soon)

⚠️  Note: Replace API keys in CONFIG section for production use
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

module.exports = app;

// ==================== WEATHER API ====================

// Get current weather
app.get('/api/weather/current', async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }
    
    const response = await axios.get(`${CONFIG.WEATHER_API_URL}/forecast`, {
      params: {
        latitude: lat,
        longitude: lon,
        current_weather: true,
        hourly: 'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m',
        daily: 'temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max',
        timezone: 'auto',
        forecast_days: 7
      }
    });
    
    const data = response.data;
    
    res.json({
      current: {
        temperature: data.current_weather.temperature,
        humidity: data.hourly.relative_humidity_2m[0],
        wind_speed: data.current_weather.windspeed,
        weather_code: data.current_weather.weathercode,
        time: data.current_weather.time,
      },
      hourly: {
        time: data.hourly.time.slice(0, 24),
        temperature: data.hourly.temperature_2m.slice(0, 24),
        humidity: data.hourly.relative_humidity_2m.slice(0, 24),
        precipitation: data.hourly.precipitation.slice(0, 24),
      },
      daily: {
        time: data.daily.time,
        temperature_max: data.daily.temperature_2m_max,
        temperature_min: data.daily.temperature_2m_min,
        precipitation: data.daily.precipitation_sum,
        wind_speed: data.daily.wind_speed_10m_max,
      },
      farming_advice: generateFarmingAdvice(data.current_weather, data.daily)
    });
    
  } catch (error) {
    console.error('Weather API error:', error.message);
    res.status(500).json({ error: 'Failed to fetch weather data' });
  }
});

// Generate farming advice based on weather
function generateFarmingAdvice(current, daily) {
  const advice = [];
  
  if (current.temperature > 30) {
    advice.push({
      type: 'warning',
      message: 'High temperature detected. Ensure adequate irrigation for crops.',
      priority: 'high'
    });
  }
  
  if (daily.precipitation_sum[0] > 10) {
    advice.push({
      type: 'info',
      message: 'Good rainfall expected. Consider planting or transplanting.',
      priority: 'medium'
    });
  }
  
  if (current.windspeed > 20) {
    advice.push({
      type: 'warning',
      message: 'Strong winds detected. Secure greenhouse structures.',
      priority: 'high'
    });
  }
  
  return advice;
}

// ==================== SMS SERVICE ====================

// Send SMS alert
app.post('/api/sms/send', async (req, res) => {
  try {
    const { to, message, type = 'alert' } = req.body;
    
    if (!to || !message) {
      return res.status(400).json({ error: 'Phone number and message required' });
    }
    
    if (twilioClient) {
      const result = await twilioClient.messages.create({
        body: message,
        from: CONFIG.TWILIO_PHONE_NUMBER,
        to: to
      });
      
      res.json({
        success: true,
        messageId: result.sid,
        status: result.status,
        timestamp: new Date().toISOString()
      });
    } else {
      // Mock mode
      console.log(`Mock SMS to ${to}: ${message}`);
      res.json({
        success: true,
        messageId: `mock_${Date.now()}`,
        status: 'sent',
        timestamp: new Date().toISOString(),
        mock: true
      });
    }
    
  } catch (error) {
    console.error('SMS error:', error.message);
    res.status(500).json({ error: 'Failed to send SMS' });
  }
});

// Send bulk SMS
app.post('/api/sms/bulk', async (req, res) => {
  try {
    const { recipients, message } = req.body;
    
    if (!recipients || !Array.isArray(recipients) || !message) {
      return res.status(400).json({ error: 'Recipients array and message required' });
    }
    
    const results = [];
    
    for (const recipient of recipients) {
      try {
        if (twilioClient) {
          const result = await twilioClient.messages.create({
            body: message,
            from: CONFIG.TWILIO_PHONE_NUMBER,
            to: recipient
          });
          results.push({ to: recipient, success: true, messageId: result.sid });
        } else {
          // Mock mode
          results.push({ to: recipient, success: true, messageId: `mock_${Date.now()}` });
        }
      } catch (error) {
        results.push({ to: recipient, success: false, error: error.message });
      }
    }
    
    res.json({
      success: true,
      results,
      total: recipients.length,
      successful: results.filter(r => r.success).length,
      failed: results.filter(r => !r.success).length
    });
    
  } catch (error) {
    console.error('Bulk SMS error:', error.message);
    res.status(500).json({ error: 'Failed to send bulk SMS' });
  }
});

// ==================== M-PESA INTEGRATION ====================

// Get M-Pesa access token
async function getMpesaAccessToken() {
  try {
    const auth = Buffer.from(`${CONFIG.MPESA_CONSUMER_KEY}:${CONFIG.MPESA_CONSUMER_SECRET}`).toString('base64');
    
    const response = await axios.get(`${CONFIG.MPESA_BASE_URL}/oauth/v1/generate?grant_type=client_credentials`, {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    });
    
    return response.data.access_token;
  } catch (error) {
    throw new Error('Failed to get M-Pesa access token');
  }
}

// STK Push (M-Pesa payment request)
app.post('/api/mpesa/stkpush', async (req, res) => {
  try {
    const { phone, amount, account_reference, transaction_desc } = req.body;
    
    if (!phone || !amount) {
      return res.status(400).json({ error: 'Phone number and amount required' });
    }
    
    if (CONFIG.MPESA_CONSUMER_KEY === 'your_mpesa_key') {
      // Mock mode
      return res.json({
        success: true,
        CheckoutRequestID: `mock_checkout_${Date.now()}`,
        ResponseDescription: 'Success. Request accepted for processing',
        ResponseCode: '0',
        mock: true
      });
    }
    
    const accessToken = await getMpesaAccessToken();
    const timestamp = generateTimestamp();
    const password = generatePassword(CONFIG.MPESA_SHORTCODE, CONFIG.MPESA_PASSKEY, timestamp);
    
    const response = await axios.post(`${CONFIG.MPESA_BASE_URL}/mpesa/stkpush/v1/processrequest`, {
      BusinessShortCode: CONFIG.MPESA_SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.round(amount),
      PartyA: phone,
      PartyB: CONFIG.MPESA_SHORTCODE,
      PhoneNumber: phone,
      CallBackURL: `${req.protocol}://${req.get('host')}/api/mpesa/callback`,
      AccountReference: account_reference || 'AgriVision',
      TransactionDesc: transaction_desc || 'Payment for AgriVision services'
    }, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });
    
    res.json(response.data);
    
  } catch (error) {
    console.error('M-Pesa STK Push error:', error.message);
    res.status(500).json({ error: 'Failed to initiate payment' });
  }
});

// M-Pesa callback
app.post('/api/mpesa/callback', (req, res) => {
  console.log('M-Pesa Callback:', JSON.stringify(req.body, null, 2));
  
  // Process the callback data here
  // Update your database with payment status
  
  res.json({ ResultCode: 0, ResultDesc: 'Success' });
});

// ==================== MARKET DATA ====================

// Get market prices
app.get('/api/market/prices', async (req, res) => {
  try {
    const { country = 'kenya', crop } = req.query;
    
    // Mock market data - replace with real API calls
    const marketData = {
      kenya: {
        maize: { price: 45.50, currency: 'KES', unit: 'kg', change: 2.3, market: 'Nairobi' },
        coffee: { price: 280.00, currency: 'KES', unit: 'kg', change: -1.5, market: 'Mombasa' },
        beans: { price: 120.00, currency: 'KES', unit: 'kg', change: 0.8, market: 'Nakuru' },
        wheat: { price: 55.00, currency: 'KES', unit: 'kg', change: 1.2, market: 'Eldoret' },
        rice: { price: 95.00, currency: 'KES', unit: 'kg', change: -0.5, market: 'Mwea' }
      },
      tanzania: {
        maize: { price: 1200, currency: 'TZS', unit: 'kg', change: 3.1, market: 'Dar es Salaam' },
        coffee: { price: 8500, currency: 'TZS', unit: 'kg', change: -2.1, market: 'Arusha' },
        rice: { price: 2800, currency: 'TZS', unit: 'kg', change: 1.5, market: 'Morogoro' }
      },
      uganda: {
        maize: { price: 1800, currency: 'UGX', unit: 'kg', change: 2.8, market: 'Kampala' },
        coffee: { price: 12000, currency: 'UGX', unit: 'kg', change: -1.8, market: 'Mbale' },
        beans: { price: 4500, currency: 'UGX', unit: 'kg', change: 1.1, market: 'Masaka' }
      }
    };
    
    const countryData = marketData[country.toLowerCase()] || marketData.kenya;
    
    if (crop) {
      const cropData = countryData[crop.toLowerCase()];
      if (!cropData) {
        return res.status(404).json({ error: 'Crop not found' });
      }
      res.json({
        crop,
        country,
        ...cropData,
        lastUpdated: new Date().toISOString()
      });
    } else {
      const prices = Object.entries(countryData).map(([cropName, data]) => ({
        crop: cropName,
        country,
        ...data,
        lastUpdated: new Date().toISOString()
      }));
      res.json({ prices });
    }
    
  } catch (error) {
    console.error('Market data error:', error.message);
    res.status(500).json({ error: 'Failed to fetch market data' });
  }
});

// Get price history
app.get('/api/market/history/:crop', (req, res) => {
  try {
    const { crop } = req.params;
    const { days = 30 } = req.query;
    
    // Generate mock price history
    const basePrice = 45.50;
    const history = [];
    
    for (let i = parseInt(days); i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      
      const variation = (Math.random() - 0.5) * 10; // ±5 price variation
      const price = Math.max(basePrice + variation, 20); // Minimum price of 20
      
      history.push({
        date: date.toISOString().split('T')[0],
        price: Math.round(price * 100) / 100,
        volume: Math.floor(Math.random() * 1000) + 100
      });
    }
    
    res.json({
      crop,
      period: `${days} days`,
      history,
      summary: {
        average: history.reduce((sum, item) => sum + item.price, 0) / history.length,
        highest: Math.max(...history.map(item => item.price)),
        lowest: Math.min(...history.map(item => item.price)),
        trend: history[history.length - 1].price > history[0].price ? 'up' : 'down'
      }
    });
    
  } catch (error) {
    console.error('Price history error:', error.message);
    res.status(500).json({ error: 'Failed to fetch price history' });
  }
});

// ==================== GEOCODING ====================

// Geocode address
app.get('/api/geocode', async (req, res) => {
  try {
    const { address } = req.query;
    
    if (!address) {
      return res.status(400).json({ error: 'Address parameter required' });
    }
    
    const response = await axios.get(`${CONFIG.GEOCODING_API_URL}/search`, {
      params: {
        q: address,
        format: 'json',
        limit: 5,
        countrycodes: 'ke,tz,ug,et,rw' // East African countries
      }
    });
    
    const results = response.data.map(item => ({
      address: item.display_name,
      latitude: parseFloat(item.lat),
      longitude: parseFloat(item.lon),
      type: item.type,
      importance: item.importance
    }));
    
    res.json({ results });
    
  } catch (error) {
    console.error('Geocoding error:', error.message);
    res.status(500).json({ error: 'Failed to geocode address' });
  }
});

// Reverse geocode
app.get('/api/reverse-geocode', async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }
    
    const response = await axios.get(`${CONFIG.GEOCODING_API_URL}/reverse`, {
      params: {
        lat,
        lon,
        format: 'json'
      }
    });
    
    res.json({
      address: response.data.display_name,
      components: response.data.address,
      latitude: parseFloat(lat),
      longitude: parseFloat(lon)
    });
    
  } catch (error) {
    console.error('Reverse geocoding error:', error.message);
    res.status(500).json({ error: 'Failed to reverse geocode coordinates' });
  }
});

// ==================== PUSH NOTIFICATIONS ====================

// Send push notification
app.post('/api/notifications/send', async (req, res) => {
  try {
    const { token, title, body, data } = req.body;
    
    if (!token || !title || !body) {
      return res.status(400).json({ error: 'Token, title, and body required' });
    }
    
    if (firebaseApp) {
      const message = {
        notification: { title, body },
        data: data || {},
        token
      };
      
      const response = await admin.messaging().send(message);
      res.json({ success: true, messageId: response });
    } else {
      // Mock mode
      console.log(`Mock notification to ${token}: ${title} - ${body}`);
      res.json({
        success: true,
        messageId: `mock_notification_${Date.now()}`,
        mock: true
      });
    }
    
  } catch (error) {
    console.error('Push notification error:', error.message);
    res.status(500).json({ error: 'Failed to send notification' });
  }
});

// ==================== VIDEO/VOICE (AGORA) ====================

// Generate Agora token
app.post('/api/agora/token', (req, res) => {
  try {
    const { channelName, uid, role = 1 } = req.body;
    
    if (!channelName || !uid) {
      return res.status(400).json({ error: 'Channel name and UID required' });
    }
    
    const token = generateAgoraToken(channelName, uid, role);
    
    res.json({
      token,
      channelName,
      uid,
      appId: CONFIG.AGORA_APP_ID,
      expiresAt: new Date(Date.now() + 3600000).toISOString() // 1 hour
    });
    
  } catch (error) {
    console.error('Agora token error:', error.message);
    res.status(500).json({ error: 'Failed to generate Agora token' });
  }
});

// ==================== AI/ML SERVICES ====================

// Crop disease detection
app.post('/api/ai/detect-disease', async (req, res) => {
  try {
    const { image_base64, crop_type } = req.body;
    
    if (!image_base64) {
      return res.status(400).json({ error: 'Base64 image required' });
    }
    
    // Mock AI response - replace with actual Hugging Face API call
    const diseases = [
      { name: 'Leaf Blight', confidence: 0.85, severity: 'moderate' },
      { name: 'Rust', confidence: 0.12, severity: 'low' },
      { name: 'Healthy', confidence: 0.03, severity: 'none' }
    ];
    
    const topDisease = diseases[0];
    
    res.json({
      crop_type: crop_type || 'unknown',
      predictions: diseases,
      top_prediction: topDisease,
      recommendations: generateDiseaseRecommendations(topDisease),
      confidence_threshold: 0.7,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Disease detection error:', error.message);
    res.status(500).json({ error: 'Failed to detect disease' });
  }
});

function generateDiseaseRecommendations(disease) {
  const recommendations = {
    'Leaf Blight': [
      'Apply copper-based fungicide',
      'Improve air circulation around plants',
      'Remove affected leaves immediately',
      'Avoid overhead watering'
    ],
    'Rust': [
      'Use sulfur-based fungicide',
      'Ensure proper plant spacing',
      'Apply in early morning or evening',
      'Monitor weather conditions'
    ],
    'Healthy': [
      'Continue current care routine',
      'Monitor regularly for changes',
      'Maintain proper nutrition',
      'Ensure adequate water supply'
    ]
  };
  
  return recommendations[disease.name] || ['Consult with agricultural expert'];
}

// ==================== EXPERT CONSULTATION ====================

// Get available experts
app.get('/api/experts', (req, res) => {
  const { specialty, language = 'english' } = req.query;
  
  const experts = [
    {
      id: 'exp_001',
      name: 'Dr. Sarah Wanjiku',
      title: 'Senior Agricultural Extension Officer',
      specialties: ['crop_diseases', 'organic_farming', 'soil_health'],
      languages: ['english', 'swahili'],
      rating: 4.9,
      consultations: 245,
      availability: 'Mon-Fri 9AM-5PM',
      hourly_rate: 50,
      currency: 'USD'
    },
    {
      id: 'exp_002',
      name: 'Prof. John Mwangi',
      title: 'Agricultural Economist',
      specialties: ['market_analysis', 'financial_planning', 'value_chains'],
      languages: ['english', 'swahili'],
      rating: 4.8,
      consultations: 189,
      availability: 'Tue, Thu 2PM-6PM',
      hourly_rate: 75,
      currency: 'USD'
    }
  ];
  
  let filteredExperts = experts;
  
  if (specialty) {
    filteredExperts = experts.filter(expert => 
      expert.specialties.includes(specialty.toLowerCase())
    );
  }
  
  if (language !== 'english') {
    filteredExperts = filteredExperts.filter(expert => 
      expert.languages.includes(language.toLowerCase())
    );
  }
  
  res.json({ experts: filteredExperts });
});

// Book consultation
app.post('/api/experts/book', (req, res) => {
  try {
    const { expert_id, date, time, duration, topic } = req.body;
    
    if (!expert_id || !date || !time) {
      return res.status(400).json({ error: 'Expert ID, date, and time required' });
    }
    
    const bookingId = `booking_${Date.now()}`;
    
    res.json({
      success: true,
      booking_id: bookingId,
      expert_id,
      scheduled_date: date,
      scheduled_time: time,
      duration: duration || 30,
      topic,
      status: 'confirmed',
      meeting_link: `https://meet.agrivision.com/room/${bookingId}`,
      created_at: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Booking error:', error.message);
    res.status(500).json({ error: 'Failed to book consultation' });
  }
});

// ==================== ERROR HANDLING ====================

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    available_endpoints: [
      'GET /health',
      'GET /api/weather/current',
      'POST /api/sms/send',
      'POST /api/mpesa/stkpush',
      'GET /api/market/prices',
      'GET /api/geocode',
      'POST /api/notifications/send',
      'POST /api/agora/token',
      'POST /api/ai/detect-disease',
      'GET /api/experts'
    ]
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Global error:', error);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
});

// ==================== SERVER STARTUP ====================

app.listen(PORT, () => {
  console.log(`
🌾 AgriVision API Gateway Started
📡 Server running on port ${PORT}
🌍 Environment: ${process.env.NODE_ENV || 'development'}

📋 Available Services:
   ✅ Weather API (Open-Meteo)
   ${twilioClient ? '✅' : '⚠️ '} SMS Service (Twilio)
   ${firebaseApp ? '✅' : '⚠️ '} Firebase Auth & Notifications
   ${CONFIG.MPESA_CONSUMER_KEY !== 'your_mpesa_key' ? '✅' : '⚠️ '} M-Pesa Integration
   ✅ Market Data API
   ✅ Geocoding Service
   ✅ AI/ML Services
   ✅ Expert Consultation

🔗 Health Check: http://localhost:${PORT}/health
📖 API Documentation: http://localhost:${PORT}/docs (coming soon)

⚠️  Note: Replace API keys in CONFIG section for production use
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});

module.exports = app;