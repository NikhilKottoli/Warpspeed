const axios = require('axios');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

exports.generateAudio = async (req, res) => {
  try {
    // const requestBody = {
    //   text: "When should we have lunch",
    //   target_language_code: "kn-IN"
    // };

    const apiResponse = await axios.post('https://api.sarvam.ai/text-to-speech', req, {
      headers: {
        'api-subscription-key': process.env.API_SUBSCRIPTION_KEY,
        'Content-Type': 'application/json'
      }
    });
    const audioBase64Array = apiResponse.data.audios;
    const audioBase64 = audioBase64Array.join('');

    return res.status(200).json({
      success: true,
      audio: audioBase64
    });
  } catch (error) {
    console.error(error.response?.data || error.message);
    return res.status(500).json({ error: 'Failed to generate or save audio.' });
  }
};
