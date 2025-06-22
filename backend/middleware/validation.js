const validateWeatherRequest = (req, res, next) => {
  const { city, country } = req.query;
  
  // Check if required parameters are provided
  if (!city) {
    return res.status(400).json({
      success: false,
      message: 'City parameter is required'
    });
  }
  
  // Validate city name (basic validation)
  if (typeof city !== 'string' || city.trim().length === 0) {
    return res.status(400).json({
      success: false,
      message: 'City must be a valid string'
    });
  }
  
  // Validate country if provided
  if (country && (typeof country !== 'string' || country.trim().length === 0)) {
    return res.status(400).json({
      success: false,
      message: 'Country must be a valid string'
    });
  }
  
  // Sanitize inputs
  req.query.city = city.trim();
  if (country) {
    req.query.country = country.trim();
  }
  
  next();
};

// Additional middleware for rate limiting (optional)
const rateLimit = require('express-rate-limit');

const weatherRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many weather requests, please try again later'
  }
});

module.exports = {
  validateWeatherRequest,
  weatherRateLimit
};
