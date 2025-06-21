import React, { useState } from 'react';
import { ethers } from 'ethers';

const ListAsset = ({ contract, account }) => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    imageUrl: '',
    dailyRate: ''
  });
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!contract || !account) return;

    setLoading(true);
    try {
      const dailyRateWei = ethers.utils.parseEther(formData.dailyRate);
      
      const tx = await contract.listAsset(
        formData.name,
        formData.description,
        formData.imageUrl,
        dailyRateWei
      );
      
      await tx.wait();
      alert("Asset listed successfully!");
      
      setFormData({
        name: '',
        description: '',
        imageUrl: '',
        dailyRate: ''
      });
    } catch (error) {
      console.error("Error listing asset:", error);
      alert("Error listing asset");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="list-asset">
      <h2>List Your Asset</h2>
      <form onSubmit={handleSubmit} className="asset-form">
        <div className="form-group">
          <label>Asset Name</label>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            placeholder="e.g., John's Tractor"
            required
          />
        </div>
        
        <div className="form-group">
          <label>Description</label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            placeholder="Describe your asset..."
            required
          />
        </div>
        
        <div className="form-group">
          <label>Image URL (optional)</label>
          <input
            type="url"
            name="imageUrl"
            value={formData.imageUrl}
            onChange={handleChange}
            placeholder="https://..."
          />
        </div>
        
        <div className="form-group">
          <label>Daily Rate (FARM tokens)</label>
          <input
            type="number"
            step="0.01"
            name="dailyRate"
            value={formData.dailyRate}
            onChange={handleChange}
            placeholder="10"
            required
          />
        </div>
        
        <button type="submit" disabled={loading}>
          {loading ? 'Listing...' : 'List Asset'}
        </button>
      </form>
    </div>
  );
};

export default ListAsset;
