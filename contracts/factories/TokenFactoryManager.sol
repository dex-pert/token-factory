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
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IFactoryManager, TokenMetaData } from "../interfaces/IFactoryManager.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Router02 } from "../interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "../interfaces/IUniswapV2Factory.sol";

contract TokenFactoryManager is Ownable, IFactoryManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Token {
        uint8 tokenType;
        address tokenAddress;
        TokenMetaData metaData;
        bool tradingOpen;
        address pair;
        string name;
        string symbol;
        uint256 totalSupply;
        uint8 decimals;
    }

    EnumerableSet.AddressSet private tokenFactories;
    mapping(address => Token[]) private tokensOf;
    mapping(address => mapping(address => bool)) private hasToken;
    mapping(address => bool) private isGenerated;

    mapping(address => mapping(uint8 => Token[])) private tokensByType;
    mapping(address => mapping(address => Token)) private tokensByTokenAddress;

    address private _uniswapV2Router;
    event UniswapV2RouterUpdated(address newUniswapV2Router);
    error CallerIsNotAValidFactory(address factory);
    error TokenAlreadyExists(address owner, address token);
    error TokenNotCreated(address owner, address token);
    error InvalidStart(uint256 start);
    error InvalidRouter(address uniswapV2Router);

    modifier onlyAllowedFactory() {
        if (!tokenFactories.contains(msg.sender))
            revert CallerIsNotAValidFactory(msg.sender);
        _;
    }

    constructor(
        address uniswapV2Router_
    ) {
        if (uniswapV2Router_ == address(0)) revert InvalidRouter(uniswapV2Router_);

        _uniswapV2Router = uniswapV2Router_;
    }

    function addTokenFactory(address factory) public onlyOwner {
        tokenFactories.add(factory);
    }

    function addTokenFactories(address[] memory factories) external onlyOwner {
        for (uint256 i = 0; i < factories.length; i++) {
            addTokenFactory(factories[i]);
        }
    }

    function removeTokenFactory(address factory) external onlyOwner {
        tokenFactories.remove(factory);
    }

    function updateUniswapV2Router(address newUniswapV2Router) external onlyOwner {
        _uniswapV2Router = newUniswapV2Router;
        emit UniswapV2RouterUpdated(newUniswapV2Router);
    }

    function assignTokensToOwner(
        address owner,
        address token,
        uint8 tokenType,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals,
        TokenMetaData calldata metaData
    ) external override onlyAllowedFactory {
        if (isGenerated[token]) revert TokenAlreadyExists(owner, token);
        Token memory tokenInfo = Token(tokenType, token, metaData, false, address(0), name, symbol, totalSupply, decimals);
        tokensOf[owner].push(tokenInfo);
        tokensByType[owner][tokenType].push(tokenInfo);
        tokensByTokenAddress[owner][token] = tokenInfo;
        hasToken[owner][token] = true;
        isGenerated[token] = true;
    }

    function getAllowedFactories() external view returns (address[] memory) {
        uint256 length = tokenFactories.length();
        address[] memory factories = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            factories[i] = tokenFactories.at(i);
        }
        return factories;
    }

    function isTokenGenerated(address token) external view returns (bool) {
        return isGenerated[token];
    }

    function getToken(
        address owner,
        uint256 index
    ) external view returns (address, uint8) {
        if (index > tokensOf[owner].length) {
            return (address(0), 0);
        }
        return (
            tokensOf[owner][index].tokenAddress,
            uint8(tokensOf[owner][index].tokenType)
        );
    }

    function getTokensCount(address owner) external view returns (uint256) {
        return tokensOf[owner].length;
    }

    function getTokens(
        address owner,
        uint256 start,
        uint256 limit
    ) external view returns (Token[] memory) {
        uint256 length = tokensOf[owner].length;

        if (start > length) revert InvalidStart(start);

        if (start + limit > length) {
            limit = length - start;
        }

        Token[] memory tokenTokens = new Token[](limit);

        length = start + limit;

        for (uint256 i = start; i < length; i++) {
            tokenTokens[i - start] = tokensOf[owner][i];
        }

        return tokenTokens;
    }

    function getTokensCountByType(
        address owner,
        uint8 tokenType
    ) external view returns (uint256) {
        return tokensByType[owner][tokenType].length;
    }

    function getTokensByType(
        address owner,
        uint8 tokenType,
        uint256 start,
        uint256 limit
    ) external view returns (Token[] memory) {
        uint256 length = tokensByType[owner][tokenType].length;

        if (start > length) revert InvalidStart(start);

        if (start + limit > length) {
            limit = length - start;
        }

        Token[] memory tokens = new Token[](limit);

        length = start + limit;

        for (uint256 i = start; i < length; i++) {
            tokens[i - start] = tokensByType[owner][tokenType][i];
        }

        return tokens;
    }

    function getTokenByAddress(
        address owner,
        address token
    ) external view returns (Token memory) {
        return tokensByTokenAddress[owner][token];
    }

    function updateTokenData(
        address owner,
        address token,
        TokenMetaData memory metaData_
    ) external override onlyAllowedFactory {
        if (!isGenerated[token]) revert TokenNotCreated(owner, token);
        tokensByTokenAddress[owner][token].metaData = metaData_;

        Token storage tokenInfo = tokensByTokenAddress[owner][token];
        tokenInfo.metaData = metaData_;
        
        uint tokensLength = tokensOf[owner].length;
        for (uint i = 0; i < tokensLength; i++) {
            if(tokensOf[owner][i].tokenAddress == token) {
                tokensOf[owner][i].metaData = metaData_;
            }
        }

        uint tokensByTypeLength = tokensByType[owner][tokenInfo.tokenType].length;
        for (uint i = 0; i < tokensByTypeLength; i++) {
            if(tokensByType[owner][tokenInfo.tokenType][i].tokenAddress == token) {
                tokensByType[owner][tokenInfo.tokenType][i].metaData = metaData_;
            }
        }
    }

    /**
     * @dev Open Trading
     */
    function openTrading(
        address owner,
        address token,
        uint tokenAmount
    ) external payable override onlyAllowedFactory {
        if (!isGenerated[token]) revert TokenNotCreated(owner, token);
        require(!tokensByTokenAddress[owner][token].tradingOpen,"trading is already open");

        // Ensure ETH is sent with the transaction
        require(msg.value > 0, "ETH amount must be greater than 0");
        
        IERC20(token).approve(_uniswapV2Router, tokenAmount);
        require(tokenAmount <=  IERC20(token).totalSupply(), "Token amount exceeds total supply");
        IUniswapV2Router02 router = IUniswapV2Router02(_uniswapV2Router);
        IUniswapV2Factory factory=IUniswapV2Factory(router.factory());
        address pair = factory.getPair(token, router.WETH());
        // Create pair if it doesn't exist
        if(pair==address(0x0)){
          pair = factory.createPair(token, router.WETH());
        }

        // Add liquidity
        router.addLiquidityETH{value: msg.value}(
            token,
            tokenAmount,
            0,
            0,
            owner,
            block.timestamp
        );

        IERC20(pair).approve(_uniswapV2Router, type(uint).max);
        
        _updateTokenTradingStatus(owner, token, true, pair);
    }

    function _updateTokenTradingStatus(address owner, address token, bool tradingOpen, address pair) internal {
        Token storage tokenInfo = tokensByTokenAddress[owner][token];
        tokenInfo.tradingOpen = tradingOpen;
        tokenInfo.pair = pair;
        
        uint tokensLength = tokensOf[owner].length;
        for (uint i = 0; i < tokensLength; i++) {
            if(tokensOf[owner][i].tokenAddress == token) {
                tokensOf[owner][i].tradingOpen = tradingOpen;
                tokensOf[owner][i].pair = pair;
            }
        }

        uint tokensByTypeLength = tokensByType[owner][tokenInfo.tokenType].length;
        for (uint i = 0; i < tokensByTypeLength; i++) {
            if(tokensByType[owner][tokenInfo.tokenType][i].tokenAddress == token) {
                tokensByType[owner][tokenInfo.tokenType][i].tradingOpen = tradingOpen;
                tokensByType[owner][tokenInfo.tokenType][i].pair = pair;
            }
        }
    }

    function uniswapV2Router() external view returns (address) {
        return _uniswapV2Router;
    }
}
