// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FarmToken is ERC20, Ownable {
    constructor() ERC20("FarmToken", "FARM") {}
    
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

contract AssetLending is ReentrancyGuard, Ownable {
    FarmToken public farmToken;
    
    struct Asset {
        uint256 id;
        address owner;
        string name;
        string description;
        string imageUrl;
        uint256 dailyRate; // tokens earned per day
        bool isAvailable;
        bool exists;
    }
    
    struct Loan {
        uint256 assetId;
        address borrower;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
    }
    
    struct Fertilizer {
        uint256 id;
        string name;
        uint256 price; // in FARM tokens
        uint256 stock;
    }
    
    mapping(uint256 => Asset) public assets;
    mapping(uint256 => Loan) public loans;
    mapping(uint256 => Fertilizer) public fertilizers;
    mapping(address => uint256[]) public userAssets;
    mapping(address => uint256[]) public userLoans;
    
    uint256 public nextAssetId = 1;
    uint256 public nextLoanId = 1;
    uint256 public nextFertilizerId = 1;
    
    event AssetListed(uint256 indexed assetId, address indexed owner, string name);
    event AssetBorrowed(uint256 indexed assetId, address indexed borrower, uint256 loanId);
    event AssetReturned(uint256 indexed assetId, uint256 indexed loanId);
    event TokensEarned(address indexed owner, uint256 amount);
    event FertilizerPurchased(address indexed buyer, uint256 fertilizerId, uint256 amount);
    
    constructor(address _farmToken) {
        farmToken = FarmToken(_farmToken);
        
        // Add initial fertilizers
        fertilizers[nextFertilizerId++] = Fertilizer(1, "Organic Compost", 50 * 10**18, 100);
        fertilizers[nextFertilizerId++] = Fertilizer(2, "NPK Fertilizer", 75 * 10**18, 50);
        fertilizers[nextFertilizerId++] = Fertilizer(3, "Bio Fertilizer", 100 * 10**18, 25);
    }
    
    function listAsset(
        string memory _name,
        string memory _description,
        string memory _imageUrl,
        uint256 _dailyRate
    ) external {
        uint256 assetId = nextAssetId++;
        
        assets[assetId] = Asset({
            id: assetId,
            owner: msg.sender,
            name: _name,
            description: _description,
            imageUrl: _imageUrl,
            dailyRate: _dailyRate,
            isAvailable: true,
            exists: true
        });
        
        userAssets[msg.sender].push(assetId);
        
        emit AssetListed(assetId, msg.sender, _name);
    }
    
    function borrowAsset(uint256 _assetId, uint256 _days) external {
        require(assets[_assetId].exists, "Asset does not exist");
        require(assets[_assetId].isAvailable, "Asset not available");
        require(assets[_assetId].owner != msg.sender, "Cannot borrow own asset");
        require(_days > 0, "Duration must be positive");
        
        uint256 loanId = nextLoanId++;
        uint256 endTime = block.timestamp + (_days * 1 days);
        
        loans[loanId] = Loan({
            assetId: _assetId,
            borrower: msg.sender,
            startTime: block.timestamp,
            endTime: endTime,
            isActive: true
        });
        
        assets[_assetId].isAvailable = false;
        userLoans[msg.sender].push(loanId);
        
        emit AssetBorrowed(_assetId, msg.sender, loanId);
    }
    
    function returnAsset(uint256 _loanId) external {
        require(loans[_loanId].borrower == msg.sender, "Not the borrower");
        require(loans[_loanId].isActive, "Loan not active");
        
        Loan storage loan = loans[_loanId];
        Asset storage asset = assets[loan.assetId];
        
        // Calculate tokens to mint for asset owner
        uint256 daysUsed = (block.timestamp - loan.startTime) / 1 days + 1;
        uint256 tokensToMint = daysUsed * asset.dailyRate;
        
        // Mint tokens to asset owner
        farmToken.mint(asset.owner, tokensToMint);
        
        // Update states
        loan.isActive = false;
        asset.isAvailable = true;
        
        emit AssetReturned(loan.assetId, _loanId);
        emit TokensEarned(asset.owner, tokensToMint);
    }
    
    function purchaseFertilizer(uint256 _fertilizerId, uint256 _quantity) external {
        require(fertilizers[_fertilizerId].id != 0, "Fertilizer does not exist");
        require(fertilizers[_fertilizerId].stock >= _quantity, "Insufficient stock");
        
        uint256 totalCost = fertilizers[_fertilizerId].price * _quantity;
        require(farmToken.balanceOf(msg.sender) >= totalCost, "Insufficient tokens");
        
        // Burn tokens from user
        farmToken.transferFrom(msg.sender, address(this), totalCost);
        
        // Update stock
        fertilizers[_fertilizerId].stock -= _quantity;
        
        emit FertilizerPurchased(msg.sender, _fertilizerId, _quantity);
    }
    
    function getAllAssets() external view returns (Asset[] memory) {
        Asset[] memory allAssets = new Asset[](nextAssetId - 1);
        for (uint256 i = 1; i < nextAssetId; i++) {
            if (assets[i].exists) {
                allAssets[i - 1] = assets[i];
            }
        }
        return allAssets;
    }
    
    function getUserAssets(address _user) external view returns (uint256[] memory) {
        return userAssets[_user];
    }
    
    function getUserLoans(address _user) external view returns (uint256[] memory) {
        return userLoans[_user];
    }
    
    function getAllFertilizers() external view returns (Fertilizer[] memory) {
        Fertilizer[] memory allFertilizers = new Fertilizer[](nextFertilizerId - 1);
        for (uint256 i = 1; i < nextFertilizerId; i++) {
            if (fertilizers[i].id != 0) {
                allFertilizers[i - 1] = fertilizers[i];
            }
        }
        return allFertilizers;
    }
}
