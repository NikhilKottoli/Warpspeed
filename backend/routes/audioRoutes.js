const express = require('express');
const multer = require('multer');
const speechController = require('../controllers/voiceController');

const router = express.Router();

// Text to AI to Speech pipeline
router.post('/process-speech', speechController.chatResponse);

// Standalone text-to-speech
router.post('/text-to-speech', speechController.generateAudio);

module.exports = router;
