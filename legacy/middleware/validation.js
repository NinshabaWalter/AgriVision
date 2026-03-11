const { body, query, validationResult } = require('express-validator');

const validateWeatherQuery = [
  query('lat').exists().withMessage('Latitude is required').isFloat({ min: -90, max: 90 }).withMessage('Latitude must be a valid number between -90 and 90'),
  query('lon').exists().withMessage('Longitude is required').isFloat({ min: -180, max: 180 }).withMessage('Longitude must be a valid number between -180 and 180'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  }
];

const validateSmsSend = [
  body('to').exists().withMessage('Phone number is required').isMobilePhone().withMessage('Invalid phone number'),
  body('message').exists().withMessage('Message is required').isLength({ min: 1 }),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  }
];

module.exports = {
  validateWeatherQuery,
  validateSmsSend
};
