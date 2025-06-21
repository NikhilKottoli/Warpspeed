import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

const MyAssets = ({ contract, account, onRefresh }) => {
  const [assets, setAssets] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (contract && account) {
      loadMyAssets();
    }
  }, [contract, account]);

  const loadMyAssets = async () => {
    try {
      const userAssetIds = await contract.getUserAssets(account);
      const assetPromises = userAssetIds.map(id => contract.assets(id));
      const assets = await Promise.all(assetPromises);
      setAssets(assets.filter(asset => asset.exists));
    } catch (error) {
      console.error("Error loading my assets:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="loading">Loading your assets...</div>;

  return (
    <div className="my-assets">
      <h2>My Assets</h2>
      {assets.length === 0 ? (
        <p>You haven't listed any assets yet.</p>
      ) : (
        <div className="assets-grid">
          {assets.map((asset) => (
            <div key={asset.id.toString()} className="asset-card">
              {asset.imageUrl && (
                <img src={asset.imageUrl} alt={asset.name} className="asset-image" />
              )}
              <div className="asset-info">
                <h3>{asset.name}</h3>
                <p>{asset.description}</p>
                <p className="daily-rate">
                  Daily Rate: {ethers.utils.formatEther(asset.dailyRate)} FARM
                </p>
                <p className={`status ${asset.isAvailable ? 'available' : 'borrowed'}`}>
                  {asset.isAvailable ? 'Available' : 'Currently Borrowed'}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default MyAssets;
