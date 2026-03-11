/**
 * Market intelligence routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { query, validationResult } = require('express-validator');
const NodeCache = require('node-cache');

const config = require('../config/config');
const logger = require('../utils/logger');
const { authenticateToken } = require('../middleware/auth');

// Initialize cache
const cache = new NodeCache({ stdTTL: config.MARKET_DATA_CACHE_TTL });

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

// Get market intelligence
router.get('/intelligence', [
  query('location').optional().isString(),
  query('crop').optional().isString(),
  query('radius').optional().isNumeric()
], validateRequest, async (req, res) => {
  try {
    const { location, crop, radius = 50 } = req.query;
    
    const cacheKey = `market_intelligence_${location}_${crop}_${radius}`;
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ ...cached, cached: true, requestId: req.id });
    }
    
    const marketIntelligence = await getMarketIntelligence(location, crop, radius);
    
    cache.set(cacheKey, marketIntelligence);
    
    logger.info(`Market intelligence fetched for ${location}`, { requestId: req.id });
    
    res.json({
      ...marketIntelligence,
      requestId: req.id,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    logger.error('Market intelligence error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Market intelligence unavailable',
      message: 'Unable to fetch market data at this time',
      requestId: req.id
    });
  }
});

// Get price opportunities (requires authentication)
router.get('/opportunities', authenticateToken, [
  query('crops').optional().isString(),
  query('max_distance').optional().isNumeric()
], validateRequest, async (req, res) => {
  try {
    const { crops, max_distance = 100 } = req.query;
    const cropList = crops ? crops.split(',') : ['maize', 'beans', 'coffee'];
    
    const opportunities = await findPriceOpportunities(req.user, cropList, max_distance);
    
    res.json({
      opportunities,
      user_location: req.user.location,
      search_criteria: { crops: cropList, max_distance },
      requestId: req.id,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    logger.error('Price opportunities error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Price opportunities unavailable',
      message: 'Unable to find price opportunities at this time',
      requestId: req.id
    });
  }
});

// Get current market prices
router.get('/prices', [
  query('crop').optional().isString(),
  query('location').optional().isString()
], validateRequest, async (req, res) => {
  try {
    const { crop, location } = req.query;
    
    const cacheKey = `market_prices_${crop}_${location}`;
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ ...cached, cached: true, requestId: req.id });
    }
    
    const prices = await getCurrentMarketPrices(crop, location);
    
    cache.set(cacheKey, prices);
    
    res.json({
      ...prices,
      requestId: req.id,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    logger.error('Market prices error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Market prices unavailable',
      message: 'Unable to fetch current market prices',
      requestId: req.id
    });
  }
});

// Helper functions
async function getMarketIntelligence(location, crop, radius) {
  // Mock market intelligence - replace with real market data APIs
  const markets = [
    {
      name: 'Nakuru Central Market',
      distance: 15,
      prices: {
        maize: { current: 45.50, trend: 'up', change: 2.3 },
        beans: { current: 120.00, trend: 'stable', change: 0.5 },
        coffee: { current: 280.00, trend: 'down', change: -1.5 }
      },
      demand_level: 'high',
      transport_cost: 5.50,
      market_days: ['Monday', 'Wednesday', 'Friday'],
      contact: '+254700123456'
    },
    {
      name: 'Eldoret Grain Market',
      distance: 45,
      prices: {
        maize: { current: 47.00, trend: 'up', change: 3.1 },
        wheat: { current: 55.00, trend: 'stable', change: 1.2 }
      },
      demand_level: 'medium',
      transport_cost: 12.00,
      market_days: ['Tuesday', 'Thursday', 'Saturday'],
      contact: '+254700654321'
    }
  ];
  
  const selectedCrop = crop || 'maize';
  
  return {
    location,
    crop: selectedCrop,
    search_radius: radius,
    markets: markets.map(market => ({
      ...market,
      net_price: market.prices[selectedCrop] ? 
        market.prices[selectedCrop].current - market.transport_cost : null,
      profit_margin: market.prices[selectedCrop] ? 
        ((market.prices[selectedCrop].current - market.transport_cost - 35) / 35) * 100 : null
    })),
    best_market: markets.reduce((best, current) => {
      const bestPrice = best.prices[selectedCrop]?.current - best.transport_cost || 0;
      const currentPrice = current.prices[selectedCrop]?.current - current.transport_cost || 0;
      return currentPrice > bestPrice ? current : best;
    }),
    price_alerts: [
      {
        type: 'price_spike',
        message: `${selectedCrop} prices up 15% this week in Nakuru region`,
        action: 'Consider selling if you have stock'
      }
    ],
    seasonal_trends: {
      current_season: 'harvest',
      price_prediction: 'Prices expected to drop 10-15% in next 2 weeks',
      best_selling_window: 'Next 7-10 days'
    }
  };
}

async function findPriceOpportunities(user, crops, maxDistance) {
  // Mock opportunity finder
  return [
    {
      crop: 'maize',
      opportunity_type: 'price_arbitrage',
      local_price: 42.00,
      target_market: 'Mombasa Port',
      target_price: 52.00,
      distance: 85,
      transport_cost: 8.50,
      net_profit_per_bag: 1.50,
      confidence: 0.85,
      time_sensitive: true,
      expires_in_days: 5,
      requirements: ['Minimum 100 bags', 'Quality grade A'],
      contact_info: {
        buyer: 'East Africa Grain Traders',
        phone: '+254700987654',
        email: 'buyers@eagraintraders.com'
      }
    },
    {
      crop: 'coffee',
      opportunity_type: 'premium_market',
      local_price: 280.00,
      target_market: 'Nairobi Coffee Exchange',
      target_price: 320.00,
      distance: 65,
      transport_cost: 15.00,
      net_profit_per_bag: 25.00,
      confidence: 0.92,
      time_sensitive: false,
      requirements: ['Organic certification', 'AA grade'],
      contact_info: {
        buyer: 'Premium Coffee Buyers Ltd',
        phone: '+254700456789',
        email: 'premium@coffeekenya.com'
      }
    }
  ];
}

async function getCurrentMarketPrices(crop, location) {
  // Mock current prices
  return {
    crop: crop || 'general',
    location: location || 'Kenya',
    prices: {
      maize: { current: 45.50, currency: 'KES', unit: 'per 90kg bag', trend: 'up' },
      beans: { current: 120.00, currency: 'KES', unit: 'per 90kg bag', trend: 'stable' },
      coffee: { current: 280.00, currency: 'KES', unit: 'per kg', trend: 'down' },
      wheat: { current: 55.00, currency: 'KES', unit: 'per 90kg bag', trend: 'up' }
    },
    last_updated: new Date().toISOString(),
    source: 'Kenya Agricultural Commodity Exchange'
  };
}

module.exports = router;