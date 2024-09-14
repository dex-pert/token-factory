// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 *
 * /$$$$$$$                                                      /$$    
 *| $$__  $$                                                    | $$    
 *| $$  \ $$  /$$$$$$  /$$   /$$  /$$$$$$   /$$$$$$   /$$$$$$  /$$$$$$  
 *| $$  | $$ /$$__  $$|  $$ /$$/ /$$__  $$ /$$__  $$ /$$__  $$|_  $$_/  
 *| $$  | $$| $$$$$$$$ \  $$$$/ | $$  \ $$| $$$$$$$$| $$  \__/  | $$    
 *| $$  | $$| $$_____/  >$$  $$ | $$  | $$| $$_____/| $$        | $$ /$$
 *| $$$$$$$/|  $$$$$$$ /$$/\  $$| $$$$$$$/|  $$$$$$$| $$        |  $$$$/
 *|_______/  \_______/|__/  \__/| $$____/  \_______/|__/         \___/  
 *                             | $$                                    
 *                             | $$                                    
 *                            |__/                                    
 *
 * This smart contract was created effortlessly using the Dexpert Token Creator.
 * 
 * 🌐 Website: https://dexpert.io/
 * 🐦 Twitter: https://x.com/DexpertOfficial
 * 💬 Telegram: https://t.me/DexpertCommunity
 * 
 * 🚀 Unleash the power of decentralized finances and tokenization with Dexpert Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!
 */
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IFactoryManager, TokenMetaData } from "../interfaces/IFactoryManager.sol";

contract TokenFactoryBase is Ownable, ReentrancyGuard {
    using Address for address payable;

    address public immutable FACTORY_MANAGER;
    address public implementation;
    uint96 public implementationVersion; // Max value: 79228162514264337593543950335
    address public feeTo;
    mapping(uint256 => uint256) public fees;
    uint256 public immutable MAX_FEE;

    event TokenCreated(
        address indexed owner,
        address indexed token,
        uint8 tokenType,
        uint96 tokenVersion,
        uint256 level
    );
    event FeeToUpdated(address newFeeTo);
    event FeeUpdated(uint256 level, uint256 newFee);
    event TokenMetaDataUpdated(address owner, address token, TokenMetaData metaData);
    event TradingOpened(address sender, address token, uint tokenAmount, uint ethAmount);
    event LevelsUpdated(uint256[] newLevels);
    error InvalidFactoryManager(address implementation);
    error InvalidImplementation(address factoryManager);
    error InvalidFeeReceiver(address receiver);
    error InvalidFee(uint256 fee);
    error InvalidMaxFee(uint256 maxFee);
    error InsufficientFee(uint256 fee);
    error InvalidLevel(uint256 level);
    error OnlyOwner();

    modifier enoughFee(uint256 level) {
        if (msg.value < fees[level]) revert InsufficientFee(msg.value);
        _;
    }

    constructor(
        address factoryManager_,
        address implementation_,
        address feeTo_,
        uint256 maxFee_
    ) {
        if (factoryManager_ == address(0))
            revert InvalidFactoryManager(factoryManager_);
        if (implementation_ == address(0))
            revert InvalidImplementation(implementation_);
        if (feeTo_ == address(0)) revert InvalidFeeReceiver(feeTo_);

        FACTORY_MANAGER = factoryManager_;
        implementation = implementation_;
        implementationVersion = 1;
        feeTo = feeTo_;
        MAX_FEE = maxFee_;
    }

    function setFee(uint256 level, uint256 fee) external onlyOwner {
        if (fee >= MAX_FEE) revert InvalidFee(fee);
        fees[level] = fee;
        emit FeeUpdated(level, fee);
    }

    function setImplementation(address implementation_) external onlyOwner {
        if (implementation_ == address(0) || implementation_ == address(this))
            revert InvalidImplementation(implementation_);
        require(Address.isContract(implementation_), "New implementation must be a contract");

        implementation = implementation_;
        ++implementationVersion;
    }

    function setFeeTo(address feeTo_) external onlyOwner {
        if (
            feeTo_ == address(0) ||
            feeTo_ == address(this)
        ) revert InvalidFeeReceiver(feeTo_);
        
        feeTo = feeTo_;
        emit FeeToUpdated(feeTo);
    }

    function assignTokenToOwner(
        address owner,
        address token,
        uint8 tokenType,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals,
        TokenMetaData memory metaData
    ) internal {
        IFactoryManager(FACTORY_MANAGER).assignTokensToOwner(
            owner,
            token,
            tokenType,
            name,
            symbol,
            totalSupply,
            decimals,
            metaData
        );
    }

    function refundExcessiveFee(uint256 level) internal {
        uint256 refund = msg.value - fees[level];
        if (refund > 0) {
            Address.sendValue(payable(msg.sender),refund);
        }
    }

    function updateTokenData(
        address owner,
        address token,
        TokenMetaData memory metaData
    ) internal {
        IFactoryManager(FACTORY_MANAGER).updateTokenData(
            owner,
            token,
            metaData
        );
    }
}
