import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

const FertilizerShop = ({ contract, tokenContract, account, onRefresh }) => {
  const [fertilizers, setFertilizers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (contract) {
      loadFertilizers();
    }
  }, [contract]);

  const loadFertilizers = async () => {
    try {
      const allFertilizers = await contract.getAllFertilizers();
      setFertilizers(allFertilizers.filter(f => f.id.gt(0)));
    } catch (error) {
      console.error("Error loading fertilizers:", error);
    } finally {
      setLoading(false);
    }
  };

  const purchaseFertilizer = async (fertilizerId, quantity) => {
    try {
      const fertilizer = fertilizers.find(f => f.id.eq(fertilizerId));
      const totalCost = fertilizer.price.mul(quantity);
      
      const approveTx = await tokenContract.approve(contract.address, totalCost);
      await approveTx.wait();
      
      const tx = await contract.purchaseFertilizer(fertilizerId, quantity);
      await tx.wait();
      
      alert("Fertilizer purchased successfully!");
      loadFertilizers();
      onRefresh();
    } catch (error) {
      console.error("Error purchasing fertilizer:", error);
      alert("Error purchasing fertilizer");
    }
  };

  if (loading) return <div className="loading">Loading fertilizers...</div>;

  return (
    <div className="fertilizer-shop">
      <h2>🌱 Token Shop</h2>
      <p>Use your FARM tokens to purchase fertilizers!</p>
      
      <div className="fertilizers-grid">
        {fertilizers.map((fertilizer) => (
          <FertilizerCard 
            key={fertilizer.id.toString()} 
            fertilizer={fertilizer} 
            onPurchase={purchaseFertilizer}
          />
        ))}
      </div>
    </div>
  );
};

const FertilizerCard = ({ fertilizer, onPurchase }) => {
  const [quantity, setQuantity] = useState(1);

  const handlePurchase = () => {
    if (quantity > 0 && quantity <= fertilizer.stock) {
      onPurchase(fertilizer.id, quantity);
    }
  };

  const totalCost = fertilizer.price.mul(quantity);

  return (
    <div className="fertilizer-card">
      <h3>{fertilizer.name}</h3>
      <p className="price">
        Price: {ethers.utils.formatEther(fertilizer.price)} FARM
      </p>
      <p className="stock">Stock: {fertilizer.stock.toString()}</p>
      
      <div className="purchase-section">
        <input
          type="number"
          min="1"
          max={fertilizer.stock.toString()}
          value={quantity}
          onChange={(e) => setQuantity(parseInt(e.target.value))}
        />
        <p className="total-cost">
          Total: {ethers.utils.formatEther(totalCost)} FARM
        </p>
        <button 
          onClick={handlePurchase}
          disabled={fertilizer.stock.eq(0)}
        >
          {fertilizer.stock.eq(0) ? 'Out of Stock' : 'Purchase'}
        </button>
      </div>
    </div>
  );
};

export default FertilizerShop;
