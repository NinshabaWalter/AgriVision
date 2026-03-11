/**
 * Authentication routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const config = require('../config/config');
const logger = require('../utils/logger');
const rateLimiter = require('../middleware/rateLimiter');

// Apply auth rate limiter to all auth routes
router.use(rateLimiter.auth);

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

// User registration
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('phone').optional().isMobilePhone(),
  body('location').optional().trim(),
  body('farm_size').optional().isNumeric(),
  body('crops').optional().isArray()
], validateRequest, async (req, res) => {
  try {
    const { email, password, name, phone, location, farm_size, crops } = req.body;
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);
    
    // In production, save to database
    const user = {
      id: uuidv4(),
      email,
      password: hashedPassword,
      name,
      phone,
      location,
      farm_size,
      crops: crops || [],
      created_at: new Date().toISOString(),
      verified: false
    };
    
    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      config.JWT_SECRET,
      { expiresIn: config.JWT_EXPIRES_IN }
    );
    
    logger.info(`User registered: ${email}`, { requestId: req.id });
    
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        location: user.location,
        farm_size: user.farm_size,
        crops: user.crops
      },
      requestId: req.id
    });
  } catch (error) {
    logger.error('Registration error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Registration failed',
      message: 'An error occurred during registration',
      requestId: req.id
    });
  }
});

// User login
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty().withMessage('Password is required')
], validateRequest, async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // In production, fetch from database
    // Mock user for demo
    const mockUser = {
      id: 'user_123',
      email: 'farmer@example.com',
      password: await bcrypt.hash('password123', 12),
      name: 'John Farmer',
      phone: '+254700000000',
      location: 'Nakuru, Kenya',
      farm_size: 5.5,
      crops: ['maize', 'beans', 'coffee']
    };
    
    if (email === mockUser.email && await bcrypt.compare(password, mockUser.password)) {
      const token = jwt.sign(
        { userId: mockUser.id, email: mockUser.email },
        config.JWT_SECRET,
        { expiresIn: config.JWT_EXPIRES_IN }
      );
      
      logger.info(`User logged in: ${email}`, { requestId: req.id });
      
      res.json({
        success: true,
        message: 'Login successful',
        token,
        user: {
          id: mockUser.id,
          email: mockUser.email,
          name: mockUser.name,
          phone: mockUser.phone,
          location: mockUser.location,
          farm_size: mockUser.farm_size,
          crops: mockUser.crops
        },
        requestId: req.id
      });
    } else {
      logger.warn(`Failed login attempt: ${email}`, { requestId: req.id, ip: req.ip });
      res.status(401).json({
        error: 'Invalid credentials',
        message: 'Email or password is incorrect',
        requestId: req.id
      });
    }
  } catch (error) {
    logger.error('Login error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Login failed',
      message: 'An error occurred during login',
      requestId: req.id
    });
  }
});

// Password reset request
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail()
], validateRequest, async (req, res) => {
  try {
    const { email } = req.body;
    
    // In production, generate reset token and send email
    logger.info(`Password reset requested for: ${email}`, { requestId: req.id });
    
    res.json({
      success: true,
      message: 'Password reset instructions sent to your email',
      requestId: req.id
    });
  } catch (error) {
    logger.error('Password reset error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Password reset failed',
      message: 'An error occurred while processing password reset',
      requestId: req.id
    });
  }
});

// Token validation
router.get('/validate', (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      valid: false,
      error: 'No token provided',
      requestId: req.id
    });
  }

  jwt.verify(token, config.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        valid: false,
        error: 'Invalid or expired token',
        requestId: req.id
      });
    }

    res.json({
      valid: true,
      user: {
        userId: user.userId,
        email: user.email
      },
      requestId: req.id
    });
  });
});

module.exports = router;