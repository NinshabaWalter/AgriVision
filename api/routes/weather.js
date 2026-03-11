/**
 * Weather routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { query, validationResult } = require('express-validator');
const axios = require('axios');
const NodeCache = require('node-cache');

const config = require('../config/config');
const logger = require('../utils/logger');

// Initialize cache
const cache = new NodeCache({ stdTTL: config.WEATHER_CACHE_TTL });

// Input validation middleware
const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array(),
      requestId: req.id
    });
  }
  next();
};

// Get current weather
router.get('/current', [
  query('lat').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude required'),
  query('lon').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude required')
], validateRequest, async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    // Check cache first
    const cacheKey = `weather_current_${lat}_${lon}`;
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ ...cached, cached: true, requestId: req.id });
    }
    
    const response = await axios.get(`${config.WEATHER_API_URL}/current`, {
      params: {
        latitude: lat,
        longitude: lon,
        current_weather: true,
        hourly: 'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m',
        timezone: 'auto'
      },
      timeout: 5000
    });
    
    const data = response.data;
    const result = {
      location: { lat: parseFloat(lat), lon: parseFloat(lon) },
      current: {
        temperature: data.current_weather.temperature,
        humidity: data.hourly.relative_humidity_2m[0],
        wind_speed: data.current_weather.windspeed,
        weather_code: data.current_weather.weathercode,
        time: data.current_weather.time,
        precipitation: data.hourly.precipitation[0] || 0
      },
      units: {
        temperature: '°C',
        wind_speed: 'km/h',
        precipitation: 'mm'
      },
      requestId: req.id
    };
    
    // Cache for configured TTL
    cache.set(cacheKey, result);
    
    logger.info(`Weather data fetched for ${lat}, ${lon}`, { requestId: req.id });
    res.json(result);
    
  } catch (error) {
    logger.error('Weather API error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Weather data unavailable',
      message: 'Unable to fetch weather data at this time',
      requestId: req.id
    });
  }
});

// Get weather with crop-specific alerts
router.get('/smart-alerts', [
  query('lat').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude required'),
  query('lon').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude required'),
  query('crops').optional().isString()
], validateRequest, async (req, res) => {
  try {
    const { lat, lon, crops } = req.query;
    const cropList = crops ? crops.split(',') : ['general'];
    
    // Check cache first
    const cacheKey = `weather_alerts_${lat}_${lon}_${crops}`;
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ ...cached, cached: true, requestId: req.id });
    }
    
    const response = await axios.get(`${config.WEATHER_API_URL}/forecast`, {
      params: {
        latitude: lat,
        longitude: lon,
        current_weather: true,
        hourly: 'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,soil_temperature_0cm,soil_moisture_0_1cm',
        daily: 'temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,sunrise,sunset',
        timezone: 'auto',
        forecast_days: 7
      },
      timeout: 5000
    });
    
    const data = response.data;
    const alerts = generateCropSpecificAlerts(data, cropList);
    
    const result = {
      location: { lat: parseFloat(lat), lon: parseFloat(lon) },
      current: {
        temperature: data.current_weather.temperature,
        humidity: data.hourly.relative_humidity_2m[0],
        wind_speed: data.current_weather.windspeed,
        weather_code: data.current_weather.weathercode,
        time: data.current_weather.time,
        soil_temperature: data.hourly.soil_temperature_0cm[0],
        soil_moisture: data.hourly.soil_moisture_0_1cm[0]
      },
      forecast: {
        daily: data.daily,
        hourly: {
          next_24h: {
            time: data.hourly.time.slice(0, 24),
            temperature: data.hourly.temperature_2m.slice(0, 24),
            humidity: data.hourly.relative_humidity_2m.slice(0, 24),
            precipitation: data.hourly.precipitation.slice(0, 24)
          }
        }
      },
      smart_alerts: alerts,
      irrigation_advice: generateIrrigationAdvice(data, cropList),
      planting_windows: generatePlantingWindows(data, cropList),
      requestId: req.id
    };
    
    // Cache for configured TTL
    cache.set(cacheKey, result);
    
    logger.info(`Smart weather alerts generated for ${lat}, ${lon}`, { requestId: req.id });
    res.json(result);
    
  } catch (error) {
    logger.error('Smart alerts error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Smart alerts unavailable',
      message: 'Unable to generate weather alerts at this time',
      requestId: req.id
    });
  }
});

// Weather forecast
router.get('/forecast', [
  query('lat').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude required'),
  query('lon').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude required'),
  query('days').optional().isInt({ min: 1, max: 14 }).withMessage('Days must be between 1 and 14')
], validateRequest, async (req, res) => {
  try {
    const { lat, lon, days = 7 } = req.query;
    
    const cacheKey = `weather_forecast_${lat}_${lon}_${days}`;
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ ...cached, cached: true, requestId: req.id });
    }
    
    const response = await axios.get(`${config.WEATHER_API_URL}/forecast`, {
      params: {
        latitude: lat,
        longitude: lon,
        daily: 'temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,weather_code',
        timezone: 'auto',
        forecast_days: days
      },
      timeout: 5000
    });
    
    const result = {
      location: { lat: parseFloat(lat), lon: parseFloat(lon) },
      forecast_days: parseInt(days),
      daily_forecast: response.data.daily,
      requestId: req.id
    };
    
    cache.set(cacheKey, result);
    
    logger.info(`Weather forecast fetched for ${lat}, ${lon}`, { requestId: req.id });
    res.json(result);
    
  } catch (error) {
    logger.error('Weather forecast error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Weather forecast unavailable',
      message: 'Unable to fetch weather forecast at this time',
      requestId: req.id
    });
  }
});

// Helper functions
function generateCropSpecificAlerts(weatherData, crops) {
  const alerts = [];
  const current = weatherData.current_weather;
  const daily = weatherData.daily;
  
  crops.forEach(crop => {
    // Frost warning
    if (daily.temperature_2m_min[0] < 5) {
      alerts.push({
        type: 'frost_warning',
        crop,
        severity: 'high',
        message: `Frost risk for ${crop}. Temperature expected to drop to ${daily.temperature_2m_min[0]}°C`,
        actions: ['Cover sensitive plants', 'Use frost protection methods', 'Harvest mature crops'],
        valid_until: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      });
    }
    
    // Disease risk based on humidity and temperature
    if (weatherData.hourly.relative_humidity_2m[0] > 80 && current.temperature > 20) {
      alerts.push({
        type: 'disease_risk',
        crop,
        severity: 'medium',
        message: `High disease risk for ${crop} due to warm, humid conditions`,
        actions: ['Apply preventive fungicide', 'Improve air circulation', 'Monitor for early symptoms'],
        valid_until: new Date(Date.now() + 48 * 60 * 60 * 1000).toISOString()
      });
    }
    
    // Irrigation needs
    if (daily.precipitation_sum[0] < 2 && current.temperature > 25) {
      alerts.push({
        type: 'irrigation_needed',
        crop,
        severity: 'medium',
        message: `${crop} may need irrigation. Low rainfall and high temperature expected`,
        actions: ['Check soil moisture', 'Plan irrigation schedule', 'Mulch around plants'],
        valid_until: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      });
    }
  });
  
  return alerts;
}

function generateIrrigationAdvice(weatherData, crops) {
  const advice = [];
  const precipitation = weatherData.daily.precipitation_sum[0];
  const temperature = weatherData.current_weather.temperature;
  
  if (precipitation < 5 && temperature > 25) {
    advice.push({
      recommendation: 'increase_irrigation',
      reason: 'Low rainfall and high temperature',
      frequency: 'daily',
      amount: '25-30mm',
      best_time: 'early_morning'
    });
  } else if (precipitation > 20) {
    advice.push({
      recommendation: 'reduce_irrigation',
      reason: 'Adequate rainfall expected',
      frequency: 'monitor_only',
      amount: '0mm',
      best_time: 'none'
    });
  }
  
  return advice;
}

function generatePlantingWindows(weatherData, crops) {
  const windows = [];
  const avgTemp = (weatherData.daily.temperature_2m_max[0] + weatherData.daily.temperature_2m_min[0]) / 2;
  const precipitation = weatherData.daily.precipitation_sum[0];
  
  crops.forEach(crop => {
    let suitable = false;
    let reason = '';
    
    switch (crop.toLowerCase()) {
      case 'maize':
        suitable = avgTemp >= 18 && avgTemp <= 30 && precipitation >= 5;
        reason = suitable ? 'Optimal temperature and moisture for maize planting' : 'Wait for better conditions';
        break;
      case 'beans':
        suitable = avgTemp >= 15 && avgTemp <= 25 && precipitation >= 3;
        reason = suitable ? 'Good conditions for bean planting' : 'Temperature or moisture not optimal';
        break;
      case 'coffee':
        suitable = avgTemp >= 15 && avgTemp <= 24 && precipitation >= 10;
        reason = suitable ? 'Suitable for coffee planting/transplanting' : 'Need more consistent rainfall';
        break;
      default:
        suitable = avgTemp >= 15 && avgTemp <= 28 && precipitation >= 5;
        reason = suitable ? 'General planting conditions are favorable' : 'Wait for better weather';
    }
    
    windows.push({
      crop,
      suitable,
      reason,
      confidence: suitable ? 0.8 : 0.3,
      next_check: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
    });
  });
  
  return windows;
}

module.exports = router;