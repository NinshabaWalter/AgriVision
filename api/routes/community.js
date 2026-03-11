/**
 * Community routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const { v4: uuidv4 } = require('uuid');

const config = require('../config/config');
const logger = require('../utils/logger');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

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

// Get community posts
router.get('/posts', optionalAuth, [
  query('category').optional().isString(),
  query('crop').optional().isString(),
  query('location').optional().isString(),
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 })
], validateRequest, async (req, res) => {
  try {
    const { category, crop, location, page = 1, limit = 20 } = req.query;
    
    // Mock posts data
    const posts = [
      {
        id: 'post_001',
        author: {
          id: 'user_123',
          name: 'Sarah Wanjiku',
          location: 'Kiambu, Kenya',
          avatar: 'https://example.com/avatar1.jpg'
        },
        title: 'Effective Organic Pest Control for Maize',
        content: 'I\'ve been using neem oil mixed with soap solution and it works wonders against aphids and other pests. Here\'s my recipe...',
        category: 'pest_control',
        crops: ['maize'],
        created_at: '2024-01-15T10:30:00Z',
        likes: 45,
        comments: 12,
        views: 234,
        helpful_votes: 38,
        images: ['https://example.com/pest-control1.jpg']
      },
      {
        id: 'post_002',
        author: {
          id: 'user_456',
          name: 'Peter Mwangi',
          location: 'Meru, Kenya',
          avatar: 'https://example.com/avatar2.jpg'
        },
        title: 'Drip Irrigation Setup for Small Farms',
        content: 'Here\'s how I set up a low-cost drip irrigation system using plastic bottles and tubes. Cost me less than 5000 KES for 1 acre...',
        category: 'irrigation',
        crops: ['beans', 'vegetables'],
        created_at: '2024-01-14T15:45:00Z',
        likes: 67,
        comments: 18,
        views: 456,
        helpful_votes: 52,
        images: ['https://example.com/irrigation1.jpg', 'https://example.com/irrigation2.jpg']
      }
    ];
    
    res.json({
      posts,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: posts.length,
        pages: Math.ceil(posts.length / limit)
      },
      filters: { category, crop, location },
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Community posts error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Community posts unavailable',
      message: 'Unable to fetch community posts',
      requestId: req.id
    });
  }
});

// Share knowledge
router.post('/share', authenticateToken, [
  body('title').notEmpty().trim().withMessage('Title is required'),
  body('content').notEmpty().trim().withMessage('Content is required'),
  body('category').isIn(['pest_control', 'soil_management', 'irrigation', 'harvesting', 'marketing', 'general']).withMessage('Invalid category'),
  body('crops').optional().isArray(),
  body('images').optional().isArray()
], validateRequest, async (req, res) => {
  try {
    const { title, content, category, crops = [], images = [] } = req.body;
    
    const post = {
      id: uuidv4(),
      author: req.user,
      title,
      content,
      category,
      crops,
      images,
      created_at: new Date().toISOString(),
      likes: 0,
      comments: [],
      views: 0,
      helpful_votes: 0
    };
    
    // In production, save to database
    logger.info(`Knowledge shared by ${req.user.email}: ${title}`, { requestId: req.id });
    
    res.status(201).json({
      success: true,
      post,
      message: 'Knowledge shared successfully',
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Knowledge sharing error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Knowledge sharing failed',
      message: 'Unable to share knowledge at this time',
      requestId: req.id
    });
  }
});

// Get farmer profile
router.get('/profile/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    
    // In production, fetch from database
    const profile = await getFarmerProfile(userId);
    
    res.json({
      profile,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Farmer profile error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Profile unavailable',
      message: 'Unable to fetch farmer profile',
      requestId: req.id
    });
  }
});

// Like a post
router.post('/posts/:postId/like', authenticateToken, async (req, res) => {
  try {
    const { postId } = req.params;
    
    // In production, update database
    logger.info(`Post liked: ${postId} by ${req.user.userId}`, { requestId: req.id });
    
    res.json({
      success: true,
      message: 'Post liked successfully',
      postId,
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Like post error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Like failed',
      message: 'Unable to like post',
      requestId: req.id
    });
  }
});

// Comment on a post
router.post('/posts/:postId/comment', authenticateToken, [
  body('comment').notEmpty().trim().withMessage('Comment is required')
], validateRequest, async (req, res) => {
  try {
    const { postId } = req.params;
    const { comment } = req.body;
    
    const newComment = {
      id: uuidv4(),
      author: req.user,
      content: comment,
      created_at: new Date().toISOString(),
      likes: 0
    };
    
    // In production, save to database
    logger.info(`Comment added to post ${postId} by ${req.user.userId}`, { requestId: req.id });
    
    res.status(201).json({
      success: true,
      comment: newComment,
      message: 'Comment added successfully',
      requestId: req.id
    });
    
  } catch (error) {
    logger.error('Comment error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Comment failed',
      message: 'Unable to add comment',
      requestId: req.id
    });
  }
});

// Helper function
async function getFarmerProfile(userId) {
  // Mock farmer profile
  return {
    id: userId,
    name: 'John Farmer',
    location: 'Nakuru, Kenya',
    farm_size: 5.5,
    crops: ['maize', 'beans', 'coffee'],
    farming_experience: 8,
    certifications: ['Organic', 'Fair Trade'],
    performance_metrics: {
      average_yield: {
        maize: 28.5,
        beans: 9.2,
        coffee: 14.1
      },
      sustainability_score: 8.2,
      profit_margin: 23.5,
      community_rating: 4.7,
      knowledge_sharing_points: 245
    },
    achievements: [
      { title: 'Top Yielder 2023', category: 'productivity' },
      { title: 'Sustainability Champion', category: 'environment' },
      { title: 'Community Helper', category: 'social' }
    ],
    recent_activities: [
      {
        type: 'knowledge_share',
        title: 'Shared pest control technique',
        date: '2024-01-15',
        engagement: 23
      },
      {
        type: 'yield_report',
        title: 'Reported maize harvest',
        date: '2024-01-10',
        yield: 142.5
      }
    ]
  };
}

module.exports = router;