import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

const MyLoans = ({ contract, account, onRefresh }) => {
  const [loans, setLoans] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (contract && account) {
      loadMyLoans();
    }
  }, [contract, account]);

  const loadMyLoans = async () => {
    try {
      const userLoanIds = await contract.getUserLoans(account);
      const loanPromises = userLoanIds.map(id => contract.loans(id));
      const loans = await Promise.all(loanPromises);
      
      const loansWithAssets = await Promise.all(
        loans.map(async (loan, index) => {
          const asset = await contract.assets(loan.assetId);
          return {
            ...loan,
            loanId: userLoanIds[index],
            asset
          };
        })
      );
      
      setLoans(loansWithAssets.filter(loan => loan.isActive));
    } catch (error) {
      console.error("Error loading my loans:", error);
    } finally {
      setLoading(false);
    }
  };

  const returnAsset = async (loanId) => {
    try {
      const tx = await contract.returnAsset(loanId);
      await tx.wait();
      alert("Asset returned successfully!");
      loadMyLoans();
      onRefresh();
    } catch (error) {
      console.error("Error returning asset:", error);
      alert("Error returning asset");
    }
  };

  if (loading) return <div className="loading">Loading your loans...</div>;

  return (
    <div className="my-loans">
      <h2>My Active Loans</h2>
      {loans.length === 0 ? (
        <p>You don't have any active loans.</p>
      ) : (
        <div className="loans-grid">
          {loans.map((loan) => (
            <div key={loan.loanId.toString()} className="loan-card">
              <div className="loan-info">
                <h3>{loan.asset.name}</h3>
                <p>{loan.asset.description}</p>
                <p className="loan-details">
                  Started: {new Date(loan.startTime * 1000).toLocaleDateString()}
                </p>
                <p className="loan-details">
                  Ends: {new Date(loan.endTime * 1000).toLocaleDateString()}
                </p>
                <p className="daily-rate">
                  Owner earns: {ethers.utils.formatEther(loan.asset.dailyRate)} FARM/day
                </p>
                <button onClick={() => returnAsset(loan.loanId)}>
                  Return Asset
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default MyLoans;
