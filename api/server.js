#!/usr/bin/env node

/**
 * AgriVision API Gateway Server
 * Main server file for the organized API gateway
 */

const app = require('./app');
const config = require('./config/config');
const logger = require('./utils/logger');

const PORT = config.PORT;

// Start server
const server = app.listen(PORT, () => {
  logger.info(`🌾 AgriVision API Gateway Started on port ${PORT}`);
  console.log(`
🌾 AgriVision API Gateway Started
📡 Server running on port ${PORT}
🌍 Environment: ${config.NODE_ENV}

🔒 Security Features:
   ✅ Rate limiting enabled
   ✅ CORS configured
   ✅ Security headers (Helmet)
   ✅ Input validation
   ✅ JWT authentication
   ✅ Request logging

📋 Available Services:
   ✅ Smart Weather Alerts
   ✅ AI Crop Diagnosis
   ✅ Soil Analysis
   ✅ Yield Prediction
   ✅ Market Intelligence
   ${config.TWILIO_ACCOUNT_SID !== 'your_twilio_sid' ? '✅' : '⚠️ '} SMS Service (Twilio)
   ${config.MPESA_CONSUMER_KEY !== 'your_mpesa_key' ? '✅' : '⚠️ '} M-Pesa Integration
   ✅ Community Features
   ✅ Cooperative Support
   ✅ Analytics & Insights

🌍 East Africa Features:
   ✅ Multi-language support ready
   ✅ M-Pesa integration
   ✅ SMS templates
   ✅ Local market data

📊 Monitoring:
   ✅ Request logging
   ✅ Error tracking
   ✅ Performance metrics
   ✅ Health checks

🚀 API Endpoints:
   📖 Documentation: http://localhost:${PORT}/api/docs
   🏥 Health Check: http://localhost:${PORT}/health
   🔐 Authentication: http://localhost:${PORT}/api/auth/*
   🌤️  Weather: http://localhost:${PORT}/api/weather/*
   🤖 AI Services: http://localhost:${PORT}/api/ai/*
   📊 Market Data: http://localhost:${PORT}/api/market/*
   📱 SMS: http://localhost:${PORT}/api/sms/*
   💰 M-Pesa: http://localhost:${PORT}/api/mpesa/*
   👥 Community: http://localhost:${PORT}/api/community/*
   🤝 Cooperatives: http://localhost:${PORT}/api/cooperatives/*
   📈 Analytics: http://localhost:${PORT}/api/analytics/*

Ready for production deployment! 🚀
    `);
});

// Handle server errors
server.on('error', (error) => {
  if (error.syscall !== 'listen') {
    throw error;
  }

  const bind = typeof PORT === 'string' ? 'Pipe ' + PORT : 'Port ' + PORT;

  switch (error.code) {
    case 'EACCES':
      logger.error(`${bind} requires elevated privileges`);
      process.exit(1);
      break;
    case 'EADDRINUSE':
      logger.error(`${bind} is already in use`);
      process.exit(1);
      break;
    default:
      throw error;
  }
});

// Graceful shutdown
const gracefulShutdown = (signal) => {
  logger.info(`Received ${signal}. Shutting down gracefully...`);
  
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
  
  // Force close after 10 seconds
  setTimeout(() => {
    logger.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

module.exports = server;