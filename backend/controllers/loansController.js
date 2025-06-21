const loans = [];

const loansController = {
  borrowAsset: (req, res) => {
    const { assetId, days, borrower } = req.body;
    if (!assetId || !days || !borrower) {
      return res.status(400).json({ error: 'Missing parameters' });
    }
    const loanId = loans.length + 1;
    const newLoan = { loanId, assetId, days, borrower, isActive: true, startTime: Date.now() };
    loans.push(newLoan);
    res.status(201).json(newLoan);
  },

  returnAsset: (req, res) => {
    const loanId = parseInt(req.params.loanId);
    const loan = loans.find(l => l.loanId === loanId);
    if (!loan) return res.status(404).json({ error: 'Loan not found' });
    if (!loan.isActive) return res.status(400).json({ error: 'Loan already returned' });
    loan.isActive = false;
    loan.returnTime = Date.now();
    res.json({ message: 'Asset returned', loan });
  },

  getUserLoans: (req, res) => {
    const userAddress = req.params.address;
    const userLoans = loans.filter(l => l.borrower === userAddress);
    res.json(userLoans);
  },

  getLoanDetails: (req, res) => {
    const loanId = parseInt(req.params.loanId);
    const loan = loans.find(l => l.loanId === loanId);
    if (!loan) return res.status(404).json({ error: 'Loan not found' });
    res.json(loan);
  }
};

module.exports = loansController;
