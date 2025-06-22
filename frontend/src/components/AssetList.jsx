import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

const AssetList = ({ contract, account, onRefresh }) => {
  const [assets, setAssets] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (contract) {
      loadAssets();
    }
  }, [contract]);

  const loadAssets = async () => {
    try {
      const allAssets = await contract.getAllAssets();
      const availableAssets = allAssets.filter(asset => 
        asset.exists && asset.isAvailable && asset.owner !== account
      );
      setAssets(availableAssets);
    } catch (error) {
      console.error("Error loading assets:", error);
    } finally {
      setLoading(false);
    }
  };

  const borrowAsset = async (assetId, days) => {
    try {
      const tx = await contract.borrowAsset(assetId, days);
      await tx.wait();
      alert("Asset borrowed successfully!");
      loadAssets();
      onRefresh();
    } catch (error) {
      console.error("Error borrowing asset:", error);
      alert("Error borrowing asset");
    }
  };

  if (loading) return <div className="loading">Loading assets...</div>;

  return (
    <div className="asset-list">
      <h2>Available Assets</h2>
      {assets.length === 0 ? (
        <p>No assets available for borrowing.</p>
      ) : (
        <div className="assets-grid">
          {assets.map((asset) => (
            <AssetCard key={asset.id.toString()} asset={asset} onBorrow={borrowAsset} />
          ))}
        </div>
      )}
    </div>
  );
};

const AssetCard = ({ asset, onBorrow }) => {
  const [days, setDays] = useState(1);

  const handleBorrow = () => {
    if (days > 0) {
      onBorrow(asset.id, days);
    }
  };

  return (
    <div className="asset-card">
      {asset.imageUrl && (
        <img src={asset.imageUrl} alt={asset.name} className="asset-image" />
      )}
      <div className="asset-info">
        <h3>{asset.name}</h3>
        <p>{asset.description}</p>
        <p className="daily-rate">
          Earns: {ethers.utils.formatEther(asset.dailyRate)} FARM/day
        </p>
        <div className="borrow-section">
          <input
            type="number"
            min="1"
            value={days}
            onChange={(e) => setDays(parseInt(e.target.value))}
            placeholder="Days"
          />
          <button onClick={handleBorrow}>
            Borrow for {days} day{days !== 1 ? 's' : ''}
          </button>
        </div>
      </div>
    </div>
  );
};

export default AssetList;
