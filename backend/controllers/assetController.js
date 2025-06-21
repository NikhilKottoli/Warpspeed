const { ethers } = require('ethers');
require('dotenv').config();

// Configuration
const ASSET_LENDING_ADDRESS = "0x20dd56804752f7815b1131205c6e3d9cbe71ec9a";
const RPC_URL = "https://ethereum-sepolia-rpc.publicnode.com";
const privateKey = process.env.PRIVATE_KEY;

// Contract ABIs
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

// Initialize provider and wallet
const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(privateKey, provider);

const contract = new ethers.Contract(ASSET_LENDING_ADDRESS, ASSET_LENDING_ABI, wallet);

const assetsController = {
  getAllAssets: async (req, res) => {
    try {
        if(!wallet) {
          return res.status(500).json({ error: 'Wallet not initialized' });
        }
      const assets = await contract.getAllAssets();
      const formattedAssets = assets.map(asset => ({
        id: asset.id.toString(),
        owner: asset.owner,
        name: asset.name,
        description: asset.description,
        imageUrl: asset.imageUrl,
        dailyRate: ethers.formatEther(asset.dailyRate),
        isAvailable: asset.isAvailable,
        exists: asset.exists
      }));
      res.json(formattedAssets);
    } catch (error) {
      console.error('Error getting all assets:', error);
      res.status(500).json({ error: 'Failed to fetch assets' });
    }
  },

  getAssetById: async (req, res) => {
    try {
      const id = req.params.id;
      const asset = await contract.assets(id);
      
      if (!asset.exists) {
        return res.status(404).json({ error: 'Asset not found' });
      }
      
      const formattedAsset = {
        id: asset.id.toString(),
        owner: asset.owner,
        name: asset.name,
        description: asset.description,
        imageUrl: asset.imageUrl,
        dailyRate: ethers.formatEther(asset.dailyRate),
        isAvailable: asset.isAvailable,
        exists: asset.exists
      };
      
      res.json(formattedAsset);
    } catch (error) {
      console.error('Error getting asset by ID:', error);
      res.status(500).json({ error: 'Failed to fetch asset' });
    }
  },

  getUserAssets: async (req, res) => {
    try {
      const userAddress = req.params.address;
      
      // Validate address format
      if (!ethers.isAddress(userAddress)) {
        return res.status(400).json({ error: 'Invalid address format' });
      }
      
      const assetIds = await contract.getUserAssets(userAddress);
      
      // Get detailed asset information for each ID
      const userAssets = [];
      for (const assetId of assetIds) {
        try {
          const asset = await contract.assets(assetId);
          if (asset.exists) {
            userAssets.push({
              id: asset.id.toString(),
              owner: asset.owner,
              name: asset.name,
              description: asset.description,
              imageUrl: asset.imageUrl,
              dailyRate: ethers.formatEther(asset.dailyRate),
              isAvailable: asset.isAvailable,
              exists: asset.exists
            });
          }
        } catch (err) {
          console.error(`Error fetching asset ${assetId}:`, err);
        }
      }
      
      res.json(userAssets);
    } catch (error) {
      console.error('Error getting user assets:', error);
      res.status(500).json({ error: 'Failed to fetch user assets' });
    }
  },

  createAsset: async (req, res) => {
    try {
      const { name, description, imageUrl, dailyRate } = req.body;
      
      // Validate required fields
      if (!name || !description || !dailyRate) {
        return res.status(400).json({ error: 'Missing required fields' });
      }
      
      // Convert daily rate to wei
      const dailyRateWei = ethers.parseEther(dailyRate.toString());
      
      // Call smart contract function
      const tx = await contract.listAsset(name, description, imageUrl, dailyRateWei);
      const receipt = await tx.wait();
      
      // Return transaction details
      res.status(201).json({
        success: true,
        transactionHash: receipt.hash,
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString(),
        asset: {
          name,
          description,
          imageUrl,
          dailyRate,
          owner: wallet.address
        }
      });
    } catch (error) {
      console.error('Error creating asset:', error);
      res.status(500).json({ error: 'Failed to create asset' });
    }
  },

};

module.exports = assetsController;
