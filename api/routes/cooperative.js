/**
 * Cooperative routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const { v4: uuidv4 } = require('uuid');

const config = require('../config/config');
const logger = require('../utils/logger');
const { authenticateToken } = require('../middleware/auth');

// All cooperative routes require authentication
router.use(authenticateToken);

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

// Create or join cooperative
router.post('/join', [
  body('cooperative_id').optional().isString(),
  body('cooperative_name').optional().isString(),
  body('action').isIn(['create', 'join']).withMessage('Action must be create or join')
], validateRequest, async (req, res) => {
  try {
    const { cooperative_id, cooperative_name, action } = req.body;
    
    if (action === 'create') {
      if (!cooperative_name) {
        return res.status(400).json({
          error: 'Cooperative name required',
          message: 'Cooperative name is required when creating a new cooperative',
          requestId: req.id
        });
      }
      
      const newCooperative = {
        id: uuidv4(),
        name: cooperative_name,
        founder: req.user,
        members: [req.user],
        created_at: new Date().toISOString(),
        location: req.user.location,
        focus_crops: req.user.crops || [],
        member_count: 1,
        total_farm_size: req.user.farm_size || 0,
        services: ['bulk_purchasing', 'collective_marketing', 'knowledge_sharing'],
        status: 'active'
      };
      
      // In production, save to database
      logger.info(`Cooperative created: ${cooperative_name}`, { requestId: req.id });
      
      res.status(201).json({
        success: true,
        cooperative: newCooperative,
        message: 'Cooperative created successfully',
        requestId: req.id
      });
      
    } else {
      // Join existing cooperative
      if (!cooperative_id) {
        return res.status(400).json({
          error: 'Cooperative ID required',
          message: 'Cooperative ID is required when joining an existing cooperative',
          requestId: req.id
        });
      }
      
      const cooperative = {
        id: cooperative_id,
        name: 'Nakuru Farmers Cooperative',
        member_count: 45,
        total_farm_size: 234.5,
        services: ['bulk_purchasing', 'collective_marketing', 'knowledge_sharing', 'equipment_sharing'],
        benefits: [
          'Reduced input costs through bulk purchasing',
          'Better market prices through collective selling',
          'Shared equipment and resources',
          'Training and knowledge sharing'
        ]
      };
      
      // In production, add user to cooperative in database
      logger.info(`User ${req.user.userId} applied to join cooperative ${cooperative_id}`, { requestId: req.id });
      
      res.json({
        success: true,
        cooperative,
        membership_status: 'pending_approval',
        message: 'Application to join cooperative submitted',
        requestId: req.id
      });
    }
    
  } catch (error) {
    logger.error('Cooperative join error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Cooperative operation failed',
      message: 'Unable to process cooperative request',
      requestId: req.id
    });
  }
});

// Get cooperative information
router.get('/:cooperativeId', async (req, res) => {
  try {
    const { cooperativeId } = req.params;
    
    // Mock cooperative data
    const cooperative = {
      id: cooperativeId,
      name: 'Nakuru Farmers Cooperative',
      description: 'A cooperative focused on sustainable farming practices and collective marketing',
      founded: '2020-03-15',
      location: 'Nakuru County, Kenya',
      member_count: 45,
      total_farm_size: 234.5,
      focus_crops: ['maize', 'beans', 'coffee', 'vegetables'],
      services: [
        {
          name: 'Bulk Input Purchasing',
          description: 'Group buying of seeds, fertilizers, and pesticides',
          savings: '15-25%',
          active: true
        },
        {
          name: 'Collective Marketing',
          description: 'Joint selling to get better prices',
          price_premium: '10-20%',
          active: true
        },
        {
          name: 'Equipment Sharing',
          description: 'Shared tractors, harvesters, and other equipment',
          cost_reduction: '40-60%',
          active: true
        }
      ],
      recent_activities: [
        {
          type: 'bulk_purchase',
          description: 'Ordered 2 tons of NPK fertilizer',
          date: '2024-01-10',
          savings: 450
        },
        {
          type: 'collective_sale',
          description: 'Sold 500 bags of maize to export company',
          date: '2024-01-08',
          premium_earned: 1200
        }
      ],
      financial_summary: {
        total_savings_this_year: 12500,
        average_savings_per_member: 278,
        collective_sales_volume: 2340,
        price_premium_earned: 8900
      }
    };
    
    res.json({
      cooperative,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Cooperative info error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Cooperative information unavailable',
      message: 'Unable to fetch cooperative information',
      requestId: req.id
    });
  }
});

// Get user's cooperatives
router.get('/user/cooperatives', async (req, res) => {
  try {
    // Mock user cooperatives
    const cooperatives = [
      {
        id: 'coop_001',
        name: 'Nakuru Farmers Cooperative',
        role: 'member',
        joined_date: '2023-06-15',
        status: 'active',
        member_count: 45,
        savings_this_year: 2340
      },
      {
        id: 'coop_002',
        name: 'Coffee Growers Union',
        role: 'founder',
        joined_date: '2022-03-20',
        status: 'active',
        member_count: 23,
        savings_this_year: 1850
      }
    ];
    
    res.json({
      cooperatives,
      total_cooperatives: cooperatives.length,
      total_savings: cooperatives.reduce((sum, coop) => sum + coop.savings_this_year, 0),
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('User cooperatives error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'User cooperatives unavailable',
      message: 'Unable to fetch user cooperatives',
      requestId: req.id
    });
  }
});

// Leave cooperative
router.post('/:cooperativeId/leave', async (req, res) => {
  try {
    const { cooperativeId } = req.params;
    
    // In production, remove user from cooperative in database
    logger.info(`User ${req.user.userId} left cooperative ${cooperativeId}`, { requestId: req.id });
    
    res.json({
      success: true,
      message: 'Successfully left the cooperative',
      cooperativeId,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Leave cooperative error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Leave cooperative failed',
      message: 'Unable to leave cooperative',
      requestId: req.id
    });
  }
});

// Get cooperative members (for cooperative admins)
router.get('/:cooperativeId/members', async (req, res) => {
  try {
    const { cooperativeId } = req.params;
    
    // Mock members data
    const members = [
      {
        id: 'user_001',
        name: 'John Farmer',
        location: 'Nakuru, Kenya',
        farm_size: 5.5,
        crops: ['maize', 'beans'],
        joined_date: '2023-06-15',
        role: 'member',
        contribution_score: 8.5
      },
      {
        id: 'user_002',
        name: 'Mary Wanjiku',
        location: 'Kiambu, Kenya',
        farm_size: 3.2,
        crops: ['coffee', 'vegetables'],
        joined_date: '2023-07-20',
        role: 'member',
        contribution_score: 9.1
      }
    ];
    
    res.json({
      members,
      total_members: members.length,
      total_farm_size: members.reduce((sum, member) => sum + member.farm_size, 0),
      average_contribution_score: members.reduce((sum, member) => sum + member.contribution_score, 0) / members.length,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Cooperative members error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Cooperative members unavailable',
      message: 'Unable to fetch cooperative members',
      requestId: req.id
    });
  }
});

module.exports = router;