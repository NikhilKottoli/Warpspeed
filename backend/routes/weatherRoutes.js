// routes/weatherRoutes.js
const express = require('express');
const weatherController = require('../controllers/weatherController');
const { validateWeatherRequest } = require('../middleware/validation')

const router = express.Router();

// GET /weather/current - Get current weather
router.get('/current', validateWeatherRequest, weatherController.getCurrentWeather);

// GET /weather/forecast - Get weather forecast
router.get('/forecast', validateWeatherRequest, weatherController.getForecast);

// GET /weather/coordinates - Get weather by coordinates
router.get('/coordinates', weatherController.getWeatherByCoordinates);

module.exports = router;
