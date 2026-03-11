/**
 * Rate limiting middleware for AgriVision API Gateway
 */

const rateLimit = require('express-rate-limit');
const config = require('../config/config');

// General rate limiter
const general = rateLimit({
  windowMs: config.RATE_LIMIT_WINDOW_MS,
  max: config.RATE_LIMIT_MAX_REQUESTS,
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: Math.ceil(config.RATE_LIMIT_WINDOW_MS / 1000 / 60) + ' minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'Rate limit exceeded',
      message: 'Too many requests from this IP, please try again later.',
      retryAfter: Math.ceil(config.RATE_LIMIT_WINDOW_MS / 1000 / 60) + ' minutes',
      requestId: req.id
    });
  }
});

// Strict rate limiter for AI endpoints
const ai = rateLimit({
  windowMs: config.AI_RATE_LIMIT_WINDOW_MS,
  max: config.AI_RATE_LIMIT_MAX_REQUESTS,
  message: {
    error: 'AI service rate limit exceeded. Please try again later.',
    retryAfter: Math.ceil(config.AI_RATE_LIMIT_WINDOW_MS / 1000) + ' seconds'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'AI rate limit exceeded',
      message: 'AI service rate limit exceeded. Please try again later.',
      retryAfter: Math.ceil(config.AI_RATE_LIMIT_WINDOW_MS / 1000) + ' seconds',
      requestId: req.id
    });
  }
});

// Authentication rate limiter (stricter for login attempts)
const auth = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50, // increased limit for development - limit each IP to 50 requests per windowMs for auth endpoints
  message: {
    error: 'Too many authentication attempts, please try again later.',
    retryAfter: '15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'Authentication rate limit exceeded',
      message: 'Too many authentication attempts, please try again later.',
      retryAfter: '15 minutes',
      requestId: req.id
    });
  }
});

// Payment rate limiter
const payment = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 3, // limit each IP to 3 payment requests per minute
  message: {
    error: 'Payment rate limit exceeded. Please try again later.',
    retryAfter: '1 minute'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'Payment rate limit exceeded',
      message: 'Payment rate limit exceeded. Please try again later.',
      retryAfter: '1 minute',
      requestId: req.id
    });
  }
});

module.exports = {
  general,
  ai,
  auth,
  payment
};