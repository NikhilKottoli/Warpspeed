const axios = require('axios');
require('dotenv').config();

const speechController = {
  chatResponse: async (req, res) => {
    try {
      const text = req.body.text?.trim();
      if (!text) {
        return res.status(400).json({ success: false, error: 'Text is required' });
      }
      const assetsResponse = await axios.get('http://localhost:3000/assets/assets');
      const assetsList = assetsResponse.data;
      
      const messageContent = `You are an helpful agent to indian farmers, farmers own assets and talk about it only when the farmer asks about it.Give suggestions on the best item to borrow to farmers from the list ,Heres a list of assets: ${JSON.stringify(assetsList, null, 2)}`;
      
      const aiResponse = await axios.post('https://api.sarvam.ai/v1/chat/completions', {
        messages: [{ role: "system", content: messageContent },
          { role: "user", content: text }
        ],
        model: "sarvam-m"
      }, {
        headers: {
          'api-subscription-key': process.env.API_SUBSCRIPTION_KEY,
          'Content-Type': 'application/json'
        }
      });

      const aiText = aiResponse.data?.choices?.[0]?.message?.content?.trim();

      return res.status(200).json({
        success: true,
        originalText: text,
        aiResponse: aiText
      });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Processing failed', details: error.message });
    }
  },

  generateAudio: async (req, res) => {
    try {
      const { text, speaker = "anushka", language_code = "en-IN" } = req.body;
      if (!text) {
        return res.status(400).json({ success: false, error: 'Text required' });
      }

      const response = await axios.post('https://api.sarvam.ai/text-to-speech', {
        text: text.trim(),
        speaker,
        language_code
      }, {
        headers: {
          'api-subscription-key': process.env.API_SUBSCRIPTION_KEY,
          'Content-Type': 'application/json'
        }
      });

      const audioBase64 = response.data?.audios?.join('') || '';

      return res.status(200).json({ success: true, text, audio: audioBase64 });
    } catch (error) {
      return res.status(500).json({ success: false, error: 'Audio generation failed', details: error.message });
    }
  }
};

module.exports = speechController;
