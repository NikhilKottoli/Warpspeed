const tokensController = {
  getTokenBalance: (req, res) => {
    const address = req.params.address;
    const balance = '1000';
    res.json({ address, balance });
  },

  getTokenInfo: (req, res) => {
    res.json({ name: 'FarmToken', symbol: 'FARM', decimals: 18 });
  }
};

module.exports = tokensController;
