/**
 * SMS routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const twilio = require('twilio');

const config = require('../config/config');
const logger = require('../utils/logger');

// Initialize Twilio client
let twilioClient = null;
try {
  if (config.TWILIO_ACCOUNT_SID !== 'your_twilio_sid') {
    twilioClient = twilio(config.TWILIO_ACCOUNT_SID, config.TWILIO_AUTH_TOKEN);
    logger.info('Twilio initialized successfully');
  }
} catch (error) {
  logger.warn('Twilio not initialized - using mock mode');
}

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

// Send SMS
router.post('/send', [
  body('to').isMobilePhone().withMessage('Valid phone number required'),
  body('message').notEmpty().withMessage('Message is required'),
  body('type').optional().isIn(['alert', 'notification', 'marketing'])
], validateRequest, async (req, res) => {
  try {
    const { to, message, type = 'notification' } = req.body;
    
    let result;
    if (twilioClient) {
      result = await twilioClient.messages.create({
        body: message,
        from: config.TWILIO_PHONE_NUMBER,
        to: to
      });
    } else {
      // Mock mode
      result = {
        sid: `mock_${Date.now()}`,
        status: 'sent',
        to: to,
        from: config.TWILIO_PHONE_NUMBER
      };
    }
    
    logger.info(`SMS sent to ${to}`, { messageId: result.sid, requestId: req.id });
    
    res.json({
      success: true,
      messageId: result.sid,
      to: to,
      status: result.status || 'sent',
      type: type,
      timestamp: new Date().toISOString(),
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('SMS send error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'SMS send failed',
      message: 'Unable to send SMS at this time',
      requestId: req.id
    });
  }
});

// Get SMS templates
router.get('/templates', [
  query('language').optional().isIn(['english', 'swahili']),
  query('category').optional().isString()
], validateRequest, (req, res) => {
  try {
    const { language = 'english', category } = req.query;
    
    const templates = getSMSTemplates(language, category);
    
    res.json({
      templates,
      language,
      category,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('SMS templates error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'SMS templates unavailable',
      message: 'Unable to fetch SMS templates',
      requestId: req.id
    });
  }
});

// Send templated SMS
router.post('/send-template', [
  body('template_id').notEmpty().withMessage('Template ID is required'),
  body('recipients').isArray().withMessage('Recipients must be an array'),
  body('variables').isObject().withMessage('Variables must be an object'),
  body('language').optional().isIn(['english', 'swahili'])
], validateRequest, async (req, res) => {
  try {
    const { template_id, recipients, variables, language = 'english' } = req.body;
    
    // Get template
    const templates = getSMSTemplates(language);
    let template = null;
    
    for (const category of Object.values(templates)) {
      template = category.find(t => t.id === template_id);
      if (template) break;
    }
    
    if (!template) {
      return res.status(404).json({
        error: 'Template not found',
        message: `Template with ID ${template_id} not found`,
        requestId: req.id
      });
    }
    
    // Replace variables in template
    let message = template.template;
    for (const [key, value] of Object.entries(variables)) {
      message = message.replace(new RegExp(`{${key}}`, 'g'), value);
    }
    
    // Send SMS to all recipients
    const results = [];
    for (const recipient of recipients) {
      try {
        let result;
        if (twilioClient) {
          result = await twilioClient.messages.create({
            body: message,
            from: config.TWILIO_PHONE_NUMBER,
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
    
    logger.info(`Template SMS sent: ${template_id} to ${recipients.length} recipients`, { requestId: req.id });
    
    res.json({
      success: true,
      template_used: template.name,
      message_sent: message,
      results,
      total_sent: results.filter(r => r.success).length,
      total_failed: results.filter(r => !r.success).length,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Template SMS error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Template SMS failed',
      message: 'Unable to send template SMS',
      requestId: req.id
    });
  }
});

// Bulk SMS
router.post('/bulk', [
  body('recipients').isArray().withMessage('Recipients must be an array'),
  body('message').notEmpty().withMessage('Message is required'),
  body('type').optional().isIn(['alert', 'notification', 'marketing'])
], validateRequest, async (req, res) => {
  try {
    const { recipients, message, type = 'notification' } = req.body;
    
    const results = [];
    for (const recipient of recipients) {
      try {
        let result;
        if (twilioClient) {
          result = await twilioClient.messages.create({
            body: message,
            from: config.TWILIO_PHONE_NUMBER,
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
    
    logger.info(`Bulk SMS sent to ${recipients.length} recipients`, { requestId: req.id });
    
    res.json({
      success: true,
      message_sent: message,
      type: type,
      results,
      total_sent: results.filter(r => r.success).length,
      total_failed: results.filter(r => !r.success).length,
      timestamp: new Date().toISOString(),
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Bulk SMS error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Bulk SMS failed',
      message: 'Unable to send bulk SMS',
      requestId: req.id
    });
  }
});

// Helper function to get SMS templates
function getSMSTemplates(language, category) {
  const templates = {
    english: {
      weather_alerts: [
        {
          id: 'weather_frost',
          name: 'Frost Warning',
          template: 'WEATHER ALERT: Frost expected tonight in {location}. Temperature dropping to {temp}°C. Protect your {crop} crops. Cover plants or harvest if ready.',
          variables: ['location', 'temp', 'crop']
        },
        {
          id: 'weather_rain',
          name: 'Rain Forecast',
          template: 'WEATHER UPDATE: Heavy rains expected in {location} for next {days} days. Good time for planting {crop}. Ensure proper drainage.',
          variables: ['location', 'days', 'crop']
        }
      ],
      market_prices: [
        {
          id: 'price_alert',
          name: 'Price Alert',
          template: 'MARKET ALERT: {crop} prices in {market} now {price} KES per bag. Up {change}% from last week. Good time to sell!',
          variables: ['crop', 'market', 'price', 'change']
        },
        {
          id: 'price_opportunity',
          name: 'Price Opportunity',
          template: 'OPPORTUNITY: {buyer} buying {crop} at {price} KES/bag in {location}. Contact {phone}. Valid until {date}.',
          variables: ['buyer', 'crop', 'price', 'location', 'phone', 'date']
        }
      ],
      farming_tips: [
        {
          id: 'planting_reminder',
          name: 'Planting Reminder',
          template: 'FARMING TIP: Optimal planting time for {crop} in {location}. Soil temperature {temp}°C, moisture good. Plant certified seeds for best yield.',
          variables: ['crop', 'location', 'temp']
        }
      ]
    },
    swahili: {
      weather_alerts: [
        {
          id: 'weather_frost',
          name: 'Onyo la Barafu',
          template: 'ONYO LA HALI YA HEWA: Barafu inatarajiwa usiku huu {location}. Joto litashuka hadi {temp}°C. Linda mazao yako ya {crop}.',
          variables: ['location', 'temp', 'crop']
        },
        {
          id: 'weather_rain',
          name: 'Utabiri wa Mvua',
          template: 'HALI YA HEWA: Mvua kubwa inatarajiwa {location} kwa siku {days}. Wakati mzuri wa kupanda {crop}. Hakikisha mifereji mizuri.',
          variables: ['location', 'days', 'crop']
        }
      ],
      market_prices: [
        {
          id: 'price_alert',
          name: 'Onyo la Bei',
          template: 'ONYO LA SOKO: Bei ya {crop} {market} sasa {price} KES kwa gunia. Imeongezeka {change}% wiki iliyopita. Wakati mzuri wa kuuza!',
          variables: ['crop', 'market', 'price', 'change']
        }
      ]
    }
  };
  
  const languageTemplates = templates[language] || templates.english;
  
  if (category) {
    return { [category]: languageTemplates[category] || [] };
  }
  
  return languageTemplates;
}

module.exports = router;