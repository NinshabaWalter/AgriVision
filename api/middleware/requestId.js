/**
 * Request ID middleware for AgriVision API Gateway
 * Adds unique request ID to each request for tracking
 */

const { v4: uuidv4 } = require('uuid');

const requestId = (req, res, next) => {
  req.id = uuidv4();
  res.setHeader('X-Request-ID', req.id);
  next();
};

module.exports = requestId;