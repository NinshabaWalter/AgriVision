/**
 * Authentication middleware for AgriVision API Gateway
 */

const jwt = require('jsonwebtoken');
const config = require('../config/config');
const logger = require('../utils/logger');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ 
      error: 'Access token required',
      message: 'Please provide a valid authentication token',
      requestId: req.id 
    });
  }

  jwt.verify(token, config.JWT_SECRET, (err, user) => {
    if (err) {
      logger.warn('Invalid token attempt', {
        error: err.message,
        requestId: req.id,
        ip: req.ip
      });
      
      return res.status(403).json({ 
        error: 'Invalid or expired token',
        message: 'The provided token is invalid or has expired',
        requestId: req.id 
      });
    }
    
    req.user = user;
    next();
  });
};

// Optional authentication - doesn't fail if no token provided
const optionalAuth = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    req.user = null;
    return next();
  }

  jwt.verify(token, config.JWT_SECRET, (err, user) => {
    if (err) {
      req.user = null;
    } else {
      req.user = user;
    }
    next();
  });
};

module.exports = {
  authenticateToken,
  optionalAuth
};