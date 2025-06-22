import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ethers } from 'ethers';
import LandingPage from './components/LandingPage';
import AssetList from './components/AssetList';
import ListAsset from './components/ListAsset';
import MyAssets from './components/MyAssets';
import MyLoans from './components/MyLoans';
import FertilizerShop from './components/FertilizerShop';
import './App.css';

const ASSET_LENDING_ADDRESS = "0x20dd56804752f7815b1131205c6e3d9cbe71ec9a";
const ASSET_LENDING_ABI = [
  "function farmToken() view returns (address)",
  "function listAsset(string name, string description, string imageUrl, uint256 dailyRate)",
  "function borrowAsset(uint256 assetId, uint256 days)",
  "function returnAsset(uint256 loanId)",
  "function purchaseFertilizer(uint256 fertilizerId, uint256 quantity)",
  "function getAllAssets() view returns (tuple(uint256 id, address owner, string name, string description, string imageUrl, uint256 dailyRate, bool isAvailable, bool exists)[])",
  "function getUserAssets(address user) view returns (uint256[])",
  "function getUserLoans(address user) view returns (uint256[])",
  "function getAllFertilizers() view returns (tuple(uint256 id, string name, uint256 price, uint256 stock)[])",
  "function assets(uint256) view returns (uint256 id, address owner, string name, string description, string imageUrl, uint256 dailyRate, bool isAvailable, bool exists)",
  "function loans(uint256) view returns (uint256 assetId, address borrower, uint256 startTime, uint256 endTime, bool isActive)"
];

const FARM_TOKEN_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function approve(address spender, uint256 amount) returns (bool)",
  "function allowance(address owner, address spender) view returns (uint256)"
];

const MainApp = () => {
  const [account, setAccount] = useState('');
  const [assetContract, setAssetContract] = useState(null);
  const [tokenContract, setTokenContract] = useState(null);
  const [tokenBalance, setTokenBalance] = useState('0');
  const [activeTab, setActiveTab] = useState('browse');

  useEffect(() => {
    initializeWeb3();
  }, []);

  const initializeWeb3 = async () => {
    if (window.ethereum) {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const accounts = await provider.send("eth_requestAccounts", []);
        const signer = provider.getSigner();
        
        setAccount(accounts[0]);

        const assetContract = new ethers.Contract(ASSET_LENDING_ADDRESS, ASSET_LENDING_ABI, signer);
        setAssetContract(assetContract);

        const farmTokenAddress = await assetContract.farmToken();
        const tokenContract = new ethers.Contract(farmTokenAddress, FARM_TOKEN_ABI, signer);
        setTokenContract(tokenContract);

        const balance = await tokenContract.balanceOf(accounts[0]);
        setTokenBalance(ethers.utils.formatEther(balance));

      } catch (error) {
        console.error("Error connecting to wallet:", error);
      }
    }
  };

  const refreshBalance = async () => {
    if (tokenContract && account) {
      const balance = await tokenContract.balanceOf(account);
      setTokenBalance(ethers.utils.formatEther(balance));
    }
  };
  return (
    <div className="app">
      <header className="header">
        <h1>Farm Asset Lending</h1>
        <div className="wallet-info">
          {account ? (
            <div>
              <span>Connected: {account.slice(0, 6)}...{account.slice(-4)}</span>
              <span className="token-balance">FARM: {parseFloat(tokenBalance).toFixed(2)}</span>
            </div>
          ) : (
            <button onClick={initializeWeb3}>Connect Wallet</button>
          )}
        </div>
      </header>

      <nav className="nav-tabs">
        <button className={activeTab === 'browse' ? 'active' : ''} onClick={() => setActiveTab('browse')}>
          Browse Assets
        </button>
        <button className={activeTab === 'list' ? 'active' : ''} onClick={() => setActiveTab('list')}>
          List Asset
        </button>
        <button className={activeTab === 'my-assets' ? 'active' : ''} onClick={() => setActiveTab('my-assets')}>
          My Assets
        </button>
        <button className={activeTab === 'my-loans' ? 'active' : ''} onClick={() => setActiveTab('my-loans')}>
          My Loans
        </button>
        <button className={activeTab === 'shop' ? 'active' : ''} onClick={() => setActiveTab('shop')}>
          Token Shop
        </button>
      </nav>

      <main className="main-content">
        {activeTab === 'browse' && (
          <AssetList contract={assetContract} account={account} onRefresh={refreshBalance} />
        )}
        {activeTab === 'list' && (
          <ListAsset contract={assetContract} account={account} />
        )}
        {activeTab === 'my-assets' && (
          <MyAssets contract={assetContract} account={account} onRefresh={refreshBalance} />
        )}
        {activeTab === 'my-loans' && (
          <MyLoans contract={assetContract} account={account} onRefresh={refreshBalance} />
        )}
        {activeTab === 'shop' && (
          <FertilizerShop contract={assetContract} tokenContract={tokenContract} account={account} onRefresh={refreshBalance} />
        )}
      </main>
    </div>
    
  );
};

function App() {
  return (
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/app" element={<MainApp />} />
      </Routes>
  );
}

export default App;
