const analyticsController = {
  getDashboardStats: (req, res) => {
    const address = req.params.address;
    res.json({ totalAssets: 5, activeLoans: 2, tokensEarned: '150.75', totalRevenue: '300.50' });
  },

  getAssetPerformance: (req, res) => {
    const assetId = req.params.assetId;
    res.json({ assetId, performance: 'Good', usage: 75 });
  },

  getPlatformStats: (req, res) => {
    res.json({ totalUsers: 100, totalAssets: 50, totalLoans: 20 });
  }
};

module.exports = analyticsController;
