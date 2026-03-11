/**
 * AI routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const sharp = require('sharp');

const config = require('../config/config');
const logger = require('../utils/logger');
const rateLimiter = require('../middleware/rateLimiter');
const { authenticateToken } = require('../middleware/auth');

// Apply AI rate limiter to all AI routes
router.use(rateLimiter.ai);

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: config.MAX_FILE_SIZE,
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = config.ALLOWED_FILE_TYPES.split(',');
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

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

// Crop disease detection
router.post('/crop-diagnosis', upload.single('image'), [
  body('crop_type').optional().isString(),
  body('symptoms').optional().isString(),
  body('location').optional().isString()
], validateRequest, async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'Image file required',
        message: 'Please upload an image of the affected crop',
        requestId: req.id
      });
    }
    
    const { crop_type, symptoms, location } = req.body;
    
    // Process image
    const processedImage = await sharp(req.file.buffer)
      .resize(224, 224)
      .jpeg({ quality: 90 })
      .toBuffer();
    
    const imageBase64 = processedImage.toString('base64');
    
    // Perform AI analysis
    const analysis = await performCropDiagnosis(imageBase64, crop_type, symptoms, location);
    
    logger.info(`Crop diagnosis performed for ${crop_type}`, { requestId: req.id });
    
    res.json({
      ...analysis,
      requestId: req.id,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    logger.error('Crop diagnosis error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Crop diagnosis failed',
      message: 'Unable to analyze the crop image at this time',
      requestId: req.id
    });
  }
});

// Soil analysis
router.post('/soil-analysis', upload.single('soil_image'), [
  body('location').optional().isString(),
  body('crop_planned').optional().isString(),
  body('previous_crop').optional().isString(),
  body('soil_type').optional().isString()
], validateRequest, async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'Soil image required',
        message: 'Please upload an image of the soil',
        requestId: req.id
      });
    }
    
    const { location, crop_planned, previous_crop, soil_type } = req.body;
    
    // Process soil image
    const processedImage = await sharp(req.file.buffer)
      .resize(512, 512)
      .jpeg({ quality: 95 })
      .toBuffer();
    
    const analysis = await performSoilAnalysis(processedImage, {
      location,
      crop_planned,
      previous_crop,
      soil_type
    });
    
    logger.info(`Soil analysis performed for ${location}`, { requestId: req.id });
    
    res.json({
      ...analysis,
      requestId: req.id,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    logger.error('Soil analysis error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Soil analysis failed',
      message: 'Unable to analyze the soil image at this time',
      requestId: req.id
    });
  }
});

// Yield prediction
router.post('/yield-prediction', [
  body('crop_type').notEmpty().withMessage('Crop type is required'),
  body('farm_size').isNumeric().withMessage('Farm size must be a number'),
  body('planting_date').isISO8601().withMessage('Valid planting date required'),
  body('location').notEmpty().withMessage('Location is required'),
  body('farming_practices').optional().isObject(),
  body('historical_yields').optional().isArray()
], validateRequest, async (req, res) => {
  try {
    const {
      crop_type,
      farm_size,
      planting_date,
      location,
      farming_practices = {},
      historical_yields = []
    } = req.body;
    
    const prediction = await generateYieldPrediction({
      crop_type,
      farm_size,
      planting_date,
      location,
      farming_practices,
      historical_yields
    });
    
    logger.info(`Yield prediction generated for ${crop_type}`, { requestId: req.id });
    
    res.json({
      ...prediction,
      requestId: req.id,
      generated_at: new Date().toISOString()
    });
    
  } catch (error) {
    logger.error('Yield prediction error:', { error: error.message, requestId: req.id });
    res.status(500).json({
      error: 'Yield prediction failed',
      message: 'Unable to generate yield prediction at this time',
      requestId: req.id
    });
  }
});

// Helper functions
async function performCropDiagnosis(imageBase64, cropType, symptoms, location) {
  // Mock AI response - in production, call actual AI service
  const diseases = [
    {
      name: 'Late Blight',
      confidence: 0.87,
      severity: 'high',
      description: 'Fungal disease causing dark lesions on leaves and stems',
      stage: 'advanced'
    },
    {
      name: 'Early Blight',
      confidence: 0.12,
      severity: 'medium',
      description: 'Fungal disease with concentric ring patterns',
      stage: 'early'
    },
    {
      name: 'Healthy',
      confidence: 0.01,
      severity: 'none',
      description: 'Plant appears healthy',
      stage: 'none'
    }
  ];
  
  const topDisease = diseases[0];
  
  return {
    crop_type: cropType || 'unknown',
    location,
    symptoms_reported: symptoms,
    analysis: {
      predictions: diseases,
      top_prediction: topDisease,
      confidence_threshold: 0.7,
      needs_expert_review: topDisease.confidence < 0.7
    },
    treatment_plan: generateTreatmentPlan(topDisease, cropType),
    prevention_tips: generatePreventionTips(topDisease, cropType),
    monitoring_schedule: generateMonitoringSchedule(topDisease),
    cost_estimate: calculateTreatmentCost(topDisease, cropType),
    follow_up_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
  };
}

async function performSoilAnalysis(imageBuffer, context) {
  // Mock soil analysis - replace with actual AI service
  return {
    soil_health_score: 7.2,
    soil_type: context.soil_type || 'Clay loam',
    ph_estimate: 6.8,
    organic_matter: 'Medium (2.5-3.0%)',
    moisture_level: 'Adequate',
    compaction_level: 'Low',
    color_analysis: {
      dominant_color: 'Dark brown',
      indicates: 'Good organic matter content'
    },
    nutrient_assessment: {
      nitrogen: 'Medium',
      phosphorus: 'Low',
      potassium: 'High',
      calcium: 'Adequate',
      magnesium: 'Medium'
    },
    fertilizer_recommendations: [
      {
        type: 'NPK 10-26-10',
        amount: '50kg per acre',
        timing: 'At planting',
        cost_estimate: 35,
        expected_yield_increase: '15-20%'
      },
      {
        type: 'Organic compost',
        amount: '2 tons per acre',
        timing: '2 weeks before planting',
        cost_estimate: 80,
        expected_yield_increase: '10-15%'
      }
    ],
    soil_improvement_plan: {
      short_term: [
        'Apply recommended fertilizers',
        'Add organic matter',
        'Test soil pH if needed'
      ],
      long_term: [
        'Implement crop rotation',
        'Use cover crops',
        'Practice conservation tillage'
      ]
    },
    suitability_for_crops: {
      [context.crop_planned || 'maize']: {
        suitability: 'Good',
        score: 8.1,
        limiting_factors: ['Low phosphorus'],
        recommendations: ['Apply phosphorus fertilizer', 'Monitor soil pH']
      }
    },
    next_soil_test_date: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString()
  };
}

async function generateYieldPrediction(data) {
  // Mock ML prediction - replace with actual ML model
  const baseYield = {
    maize: 25, // bags per acre
    beans: 8,
    coffee: 12,
    wheat: 20,
    rice: 30
  };
  
  const cropBaseYield = baseYield[data.crop_type.toLowerCase()] || 15;
  
  // Factors affecting yield
  let yieldMultiplier = 1.0;
  
  // Farming practices impact
  if (data.farming_practices.irrigation) yieldMultiplier += 0.2;
  if (data.farming_practices.fertilizer_use) yieldMultiplier += 0.15;
  if (data.farming_practices.pest_control) yieldMultiplier += 0.1;
  if (data.farming_practices.certified_seeds) yieldMultiplier += 0.1;
  
  // Weather impact (mock)
  const weatherImpact = 0.9 + (Math.random() * 0.2); // 0.9 to 1.1
  yieldMultiplier *= weatherImpact;
  
  const predictedYield = cropBaseYield * yieldMultiplier * data.farm_size;
  const confidence = Math.min(0.95, 0.6 + (data.historical_yields.length * 0.05));
  
  return {
    crop_type: data.crop_type,
    farm_size: data.farm_size,
    predicted_yield: {
      amount: Math.round(predictedYield * 100) / 100,
      unit: 'bags',
      per_acre: Math.round((predictedYield / data.farm_size) * 100) / 100,
      confidence_level: confidence
    },
    harvest_window: {
      earliest: new Date(new Date(data.planting_date).getTime() + 90 * 24 * 60 * 60 * 1000).toISOString(),
      optimal: new Date(new Date(data.planting_date).getTime() + 120 * 24 * 60 * 60 * 1000).toISOString(),
      latest: new Date(new Date(data.planting_date).getTime() + 150 * 24 * 60 * 60 * 1000).toISOString()
    },
    factors_considered: [
      'Historical weather patterns',
      'Soil conditions',
      'Farming practices',
      'Crop variety',
      'Regional averages'
    ],
    risk_factors: [
      {
        factor: 'Weather variability',
        impact: 'medium',
        mitigation: 'Monitor weather forecasts and adjust irrigation'
      },
      {
        factor: 'Pest and disease pressure',
        impact: 'medium',
        mitigation: 'Implement integrated pest management'
      }
    ],
    recommendations: [
      'Monitor crop development weekly',
      'Adjust fertilizer application based on plant growth',
      'Prepare harvesting equipment in advance',
      'Consider market timing for optimal prices'
    ],
    economic_projection: {
      estimated_revenue: predictedYield * 45, // $45 per bag
      production_costs: data.farm_size * 200, // $200 per acre
      projected_profit: (predictedYield * 45) - (data.farm_size * 200),
      roi_percentage: (((predictedYield * 45) - (data.farm_size * 200)) / (data.farm_size * 200)) * 100
    }
  };
}

function generateTreatmentPlan(disease, cropType) {
  const treatments = {
    'Late Blight': {
      immediate: [
        'Remove and destroy affected plant parts',
        'Apply copper-based fungicide (Copper oxychloride 50% WP)',
        'Improve air circulation around plants'
      ],
      weekly: [
        'Apply systemic fungicide (Metalaxyl + Mancozeb)',
        'Monitor for new infections',
        'Adjust irrigation to avoid leaf wetness'
      ],
      products: [
        { name: 'Ridomil Gold MZ', dosage: '2.5g/L', frequency: 'weekly', cost_per_application: 15 },
        { name: 'Copper Oxychloride', dosage: '3g/L', frequency: 'bi-weekly', cost_per_application: 8 }
      ]
    },
    'Early Blight': {
      immediate: [
        'Remove affected leaves',
        'Apply preventive fungicide',
        'Ensure proper plant spacing'
      ],
      weekly: [
        'Monitor plant health',
        'Apply organic fungicide if needed'
      ],
      products: [
        { name: 'Mancozeb 80% WP', dosage: '2g/L', frequency: 'weekly', cost_per_application: 10 }
      ]
    }
  };
  
  return treatments[disease.name] || {
    immediate: ['Consult agricultural extension officer'],
    weekly: ['Monitor plant health'],
    products: []
  };
}

function generatePreventionTips(disease, cropType) {
  return [
    'Rotate crops annually to break disease cycles',
    'Use certified disease-free seeds',
    'Maintain proper plant spacing for air circulation',
    'Avoid overhead irrigation during humid conditions',
    'Apply organic mulch to prevent soil splash',
    'Remove crop residues after harvest',
    'Use resistant varieties when available'
  ];
}

function generateMonitoringSchedule(disease) {
  return {
    daily: ['Check for new symptoms', 'Monitor weather conditions'],
    weekly: ['Assess treatment effectiveness', 'Document plant health changes'],
    monthly: ['Review overall crop health', 'Plan preventive measures'],
    next_inspection: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
  };
}

function calculateTreatmentCost(disease, cropType) {
  // Mock cost calculation
  return {
    immediate_treatment: 25,
    weekly_maintenance: 15,
    total_season_estimate: 120,
    currency: 'USD',
    cost_per_acre: 45,
    roi_improvement: '15-25%'
  };
}

module.exports = router;