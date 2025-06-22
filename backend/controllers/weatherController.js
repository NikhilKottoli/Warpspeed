const axios = require('axios');

const weatherController = {
  // Get current weather
  getCurrentWeather: async (req, res) => {
    try {
      const { city, country } = req.query;
      const apiKey = process.env.WEATHER_API_KEY;
      
      // Build query string for location
      const location = country ? `${city},${country}` : city;
      const url = `https://api.weatherapi.com/v1/current.json?key=${apiKey}&q=${location}&aqi=no`;
      
      const response = await axios.get(url);
      
      res.status(200).json({
        success: true,
        data: {
          location: response.data.location.name,
          country: response.data.location.country,
          temperature: response.data.current.temp_c,
          description: response.data.current.condition.text,
          humidity: response.data.current.humidity,
          windSpeed: response.data.current.wind_kph,
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      if (error.response && error.response.status === 400) {
        return res.status(404).json({
          success: false,
          message: 'City not found'
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Failed to fetch current weather',
        error: error.message
      });
    }
  },

  // Get weather forecast
  getForecast: async (req, res) => {
    try {
      const { city, country, days = 5 } = req.query;
      const apiKey = process.env.WEATHER_API_KEY;
      
      // WeatherAPI.com allows max 10 days for free tier
      const forecastDays = Math.min(parseInt(days), 10);
      
      const location = country ? `${city},${country}` : city;
      const url = `https://api.weatherapi.com/v1/forecast.json?key=${apiKey}&q=${location}&days=${forecastDays}&aqi=no&alerts=no`;
      
      const response = await axios.get(url);
      
      // Format forecast data
      const dailyForecasts = {};
      response.data.forecast.forecastday.forEach(day => {
        const date = day.date;
        dailyForecasts[date] = {
          date: day.date,
          maxTemp: day.day.maxtemp_c,
          minTemp: day.day.mintemp_c,
          avgTemp: day.day.avgtemp_c,
          description: day.day.condition.text,
          humidity: day.day.avghumidity,
          windSpeed: day.day.maxwind_kph,
          chanceOfRain: day.day.daily_chance_of_rain,
          hourly: day.hour.map(hour => ({
            time: hour.time,
            temperature: hour.temp_c,
            description: hour.condition.text,
            humidity: hour.humidity,
            windSpeed: hour.wind_kph
          }))
        };
      });
      
      res.status(200).json({
        success: true,
        data: {
          location: response.data.location.name,
          country: response.data.location.country,
          forecasts: dailyForecasts
        }
      });
    } catch (error) {
      if (error.response && error.response.status === 400) {
        return res.status(404).json({
          success: false,
          message: 'City not found'
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Failed to fetch weather forecast',
        error: error.message
      });
    }
  },

  // Get weather by coordinates
  getWeatherByCoordinates: async (req, res) => {
    try {
      const { lat, lon } = req.query;
      
      if (!lat || !lon) {
        return res.status(400).json({
          success: false,
          message: 'Latitude and longitude are required'
        });
      }

      // Validate coordinates
      const latitude = parseFloat(lat);
      const longitude = parseFloat(lon);
      
      if (isNaN(latitude) || isNaN(longitude) || 
          latitude < -90 || latitude > 90 || 
          longitude < -180 || longitude > 180) {
        return res.status(400).json({
          success: false,
          message: 'Invalid coordinates provided'
        });
      }

      const apiKey = process.env.WEATHER_API_KEY;
      const url = `https://api.weatherapi.com/v1/current.json?key=${apiKey}&q=${latitude},${longitude}&aqi=no`;
      
      const response = await axios.get(url);
      
      res.status(200).json({
        success: true,
        data: {
          location: response.data.location.name,
          country: response.data.location.country,
          coordinates: {
            latitude: response.data.location.lat,
            longitude: response.data.location.lon
          },
          temperature: response.data.current.temp_c,
          description: response.data.current.condition.text,
          humidity: response.data.current.humidity,
          windSpeed: response.data.current.wind_kph,
          feelsLike: response.data.current.feelslike_c,
          uvIndex: response.data.current.uv,
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      if (error.response && error.response.status === 400) {
        return res.status(404).json({
          success: false,
          message: 'Location not found'
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Failed to fetch weather by coordinates',
        error: error.message
      });
    }
  }
};

module.exports = weatherController;
