const express = require('express');
const router = express.Router();
const { generateAudio } = require('../controllers/voiceController');

// POST /audio/generate-audio - Generate audio from text
router.post('/generate-audio', generateAudio);

module.exports = router;