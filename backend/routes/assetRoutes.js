const assetsController = require('../controllers/assetController.js');
const loansController = require('../controllers/loansController.js');
const tokensController = require('../controllers/tokensController.js');
const fertilizersController = require('../controllers/fertilizerController.js');
const analyticsController = require('../controllers/analyticsController.js');
const express = require('express');

const router = express.Router();
// Asset Routes
router.get('/assets', assetsController.getAllAssets); // Get all assets
router.get('/assets/user/:address', assetsController.getUserAssets); // get a particular user's assets
router.get('/assets/:id', assetsController.getAssetById); // Get asset by ID
router.post('/assets', assetsController.createAsset); // new asset

// Loans
router.post('/loans', loansController.borrowAsset);
router.put('/loans/:loanId/return', loansController.returnAsset);
router.get('/loans/user/:address', loansController.getUserLoans);
router.get('/loans/:loanId', loansController.getLoanDetails);

// Tokens
router.get('/tokens/balance/:address', tokensController.getTokenBalance); // Get tokens from here
router.get('/tokens/info', tokensController.getTokenInfo);

// Fertilizers
router.get('/fertilizers', fertilizersController.getAllFertilizers);
router.post('/fertilizers/purchase', fertilizersController.purchaseFertilizer);

// Analytics
router.get('/stats/dashboard/:address', analyticsController.getDashboardStats);
router.get('/stats/assets/:assetId', analyticsController.getAssetPerformance);
router.get('/stats/platform', analyticsController.getPlatformStats);

module.exports = router;