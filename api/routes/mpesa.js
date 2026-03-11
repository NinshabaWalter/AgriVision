/**
 * M-Pesa routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const axios = require('axios');

const config = require('../config/config');
const logger = require('../utils/logger');
const rateLimiter = require('../middleware/rateLimiter');
const { authenticateToken } = require('../middleware/auth');

// Apply payment rate limiter to payment routes
router.use('/stkpush', rateLimiter.payment);
router.use('/pay-service', rateLimiter.payment);

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

// Utility functions
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

const getMpesaAccessToken = async () => {
  if (config.MPESA_CONSUMER_KEY === 'your_mpesa_key') {
    return 'mock_access_token';
  }
  
  const auth = Buffer.from(`${config.MPESA_CONSUMER_KEY}:${config.MPESA_CONSUMER_SECRET}`).toString('base64');
  
  const response = await axios.get(`${config.MPESA_BASE_URL}/oauth/v1/generate?grant_type=client_credentials`, {
    headers: {
      'Authorization': `Basic ${auth}`
    }
  });
  
  return response.data.access_token;
};

// STK Push
router.post('/stkpush', [
  body('phone').isMobilePhone().withMessage('Valid phone number required'),
  body('amount').isNumeric({ min: 1 }).withMessage('Amount must be a positive number'),
  body('account_reference').notEmpty().withMessage('Account reference is required'),
  body('transaction_desc').notEmpty().withMessage('Transaction description is required')
], validateRequest, async (req, res) => {
  try {
    const { phone, amount, account_reference, transaction_desc } = req.body;
    
    if (config.MPESA_CONSUMER_KEY === 'your_mpesa_key') {
      // Mock mode
      const mockResponse = {
        success: true,
        CheckoutRequestID: `mock_checkout_${Date.now()}`,
        ResponseDescription: 'Success. Request accepted for processing',
        ResponseCode: '0',
        amount,
        phone,
        account_reference,
        transaction_desc,
        mock: true
      };
      
      logger.info(`Mock M-Pesa STK Push initiated`, { requestId: req.id });
      return res.json({ ...mockResponse, requestId: req.id });
    }
    
    const accessToken = await getMpesaAccessToken();
    const timestamp = generateTimestamp();
    const password = generatePassword(config.MPESA_SHORTCODE, config.MPESA_PASSKEY, timestamp);
    
    const response = await axios.post(`${config.MPESA_BASE_URL}/mpesa/stkpush/v1/processrequest`, {
      BusinessShortCode: config.MPESA_SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.round(amount),
      PartyA: phone,
      PartyB: config.MPESA_SHORTCODE,
      PhoneNumber: phone,
      CallBackURL: `${req.protocol}://${req.get('host')}/api/mpesa/callback`,
      AccountReference: account_reference,
      TransactionDesc: transaction_desc
    }, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });
    
    logger.info(`M-Pesa STK Push initiated`, { requestId: req.id });
    
    res.json({
      ...response.data,
      amount,
      phone,
      account_reference,
      transaction_desc,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('M-Pesa STK Push error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'STK Push failed',
      message: 'Unable to initiate M-Pesa payment',
      requestId: req.id
    });
  }
});

// Service payment
router.post('/pay-service', authenticateToken, [
  body('service_type').isIn(['soil_test', 'crop_diagnosis', 'expert_consultation', 'premium_features']).withMessage('Invalid service type'),
  body('phone').isMobilePhone().withMessage('Valid phone number required'),
  body('amount').isNumeric({ min: 1 }).withMessage('Amount must be a positive number')
], validateRequest, async (req, res) => {
  try {
    const { service_type, phone, amount } = req.body;
    
    const serviceDescriptions = {
      soil_test: 'Soil Analysis Service',
      crop_diagnosis: 'AI Crop Diagnosis',
      expert_consultation: 'Expert Consultation',
      premium_features: 'Premium Features Access'
    };
    
    const description = serviceDescriptions[service_type] || 'AgriVision Service';
    
    if (config.MPESA_CONSUMER_KEY === 'your_mpesa_key') {
      // Mock mode
      const mockResponse = {
        success: true,
        CheckoutRequestID: `mock_service_${Date.now()}`,
        ResponseDescription: 'Success. Request accepted for processing',
        ResponseCode: '0',
        service_type,
        amount,
        description,
        mock: true
      };
      
      logger.info(`Mock M-Pesa service payment initiated for ${service_type}`, { requestId: req.id });
      return res.json({ ...mockResponse, requestId: req.id });
    }
    
    const accessToken = await getMpesaAccessToken();
    const timestamp = generateTimestamp();
    const password = generatePassword(config.MPESA_SHORTCODE, config.MPESA_PASSKEY, timestamp);
    
    const response = await axios.post(`${config.MPESA_BASE_URL}/mpesa/stkpush/v1/processrequest`, {
      BusinessShortCode: config.MPESA_SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.round(amount),
      PartyA: phone,
      PartyB: config.MPESA_SHORTCODE,
      PhoneNumber: phone,
      CallBackURL: `${req.protocol}://${req.get('host')}/api/mpesa/service-callback`,
      AccountReference: `AGV_${service_type.toUpperCase()}`,
      TransactionDesc: description
    }, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });
    
    logger.info(`M-Pesa service payment initiated for ${service_type}`, { requestId: req.id });
    
    res.json({
      ...response.data,
      service_type,
      amount,
      description,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('M-Pesa service payment error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Service payment failed',
      message: 'Unable to initiate service payment',
      requestId: req.id
    });
  }
});

// Transaction history
router.get('/transactions', authenticateToken, [
  query('start_date').optional().isISO8601(),
  query('end_date').optional().isISO8601(),
  query('status').optional().isIn(['completed', 'pending', 'failed'])
], validateRequest, async (req, res) => {
  try {
    const { start_date, end_date, status } = req.query;
    
    // Mock transaction history
    const transactions = [
      {
        id: 'txn_001',
        type: 'payment',
        amount: 1500,
        currency: 'KES',
        description: 'Fertilizer purchase - AgriVision',
        phone: '+254700000000',
        mpesa_receipt: 'QK7X8Y9Z0A',
        status: 'completed',
        created_at: '2024-01-15T10:30:00Z',
        completed_at: '2024-01-15T10:31:15Z'
      },
      {
        id: 'txn_002',
        type: 'payment',
        amount: 850,
        currency: 'KES',
        description: 'Soil test service - AgriVision',
        phone: '+254700000000',
        mpesa_receipt: 'QK7X8Y9Z1B',
        status: 'completed',
        created_at: '2024-01-12T14:20:00Z',
        completed_at: '2024-01-12T14:21:30Z'
      }
    ];
    
    res.json({
      transactions,
      summary: {
        total_transactions: transactions.length,
        total_amount: transactions.reduce((sum, txn) => sum + txn.amount, 0),
        completed: transactions.filter(txn => txn.status === 'completed').length,
        pending: transactions.filter(txn => txn.status === 'pending').length,
        failed: transactions.filter(txn => txn.status === 'failed').length
      },
      filters: { start_date, end_date, status },
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Transaction history error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Transaction history unavailable',
      message: 'Unable to fetch transaction history',
      requestId: req.id
    });
  }
});

// M-Pesa callback
router.post('/callback', (req, res) => {
  logger.info('M-Pesa Callback received:', { body: req.body });
  
  // Process the callback
  const { Body } = req.body;
  if (Body && Body.stkCallback) {
    const { ResultCode, ResultDesc, CallbackMetadata } = Body.stkCallback;
    
    if (ResultCode === 0) {
      // Payment successful
      logger.info('M-Pesa payment successful', { 
        resultDesc: ResultDesc,
        metadata: CallbackMetadata 
      });
    } else {
      // Payment failed
      logger.warn('M-Pesa payment failed', { 
        resultCode: ResultCode,
        resultDesc: ResultDesc 
      });
    }
  }
  
  res.json({ ResultCode: 0, ResultDesc: 'Success' });
});

// Service payment callback
router.post('/service-callback', (req, res) => {
  logger.info('M-Pesa Service Callback received:', { body: req.body });
  
  // Process the callback and update service access
  const { Body } = req.body;
  if (Body && Body.stkCallback) {
    const { ResultCode, ResultDesc, CallbackMetadata } = Body.stkCallback;
    
    if (ResultCode === 0) {
      // Payment successful - grant service access
      logger.info('M-Pesa service payment successful', { 
        resultDesc: ResultDesc,
        metadata: CallbackMetadata 
      });
      
      // Here you would update the user's service access in your database
    } else {
      // Payment failed
      logger.warn('M-Pesa service payment failed', { 
        resultCode: ResultCode,
        resultDesc: ResultDesc 
      });
    }
  }
  
  res.json({ ResultCode: 0, ResultDesc: 'Success' });
});

module.exports = router;