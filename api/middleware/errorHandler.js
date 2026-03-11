/**
 * Error handling middleware for AgriVision API Gateway
 */

const logger = require('../utils/logger');
const config = require('../config/config');

const errorHandler = (err, req, res, next) => {
  // Log the error
  logger.error('API Error:', {
    error: err.message,
    stack: err.stack,
    requestId: req.id,
    method: req.method,
    url: req.originalUrl,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  // Default error response
  let statusCode = err.statusCode || err.status || 500;
  let message = err.message || 'Internal Server Error';

  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation Error';
  } else if (err.name === 'UnauthorizedError' || err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (err.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid ID format';
  } else if (err.code === 11000) {
    statusCode = 409;
    message = 'Duplicate entry';
  }

  // Prepare error response
  const errorResponse = {
    error: message,
    requestId: req.id,
    timestamp: new Date().toISOString()
  };

  // Add stack trace in development
  if (config.NODE_ENV === 'development') {
    errorResponse.stack = err.stack;
    errorResponse.details = err;
  }

  // Send error response
  res.status(statusCode).json(errorResponse);
};

module.exports = errorHandler;