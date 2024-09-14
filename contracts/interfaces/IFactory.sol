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

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint allPairsLength);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function feeToRate() external view returns (uint256);

    function feeRateNumerator() external view returns (uint256);

    function FEE_RATE_DENOMINATOR() external view returns (uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint index) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function getSupportListLength() external view returns (uint256);

    function isSupportPair(address pair) external view returns (bool);

    function getSupportPair(uint256 index) external view returns (address);

    function getAllSupportPairs() external view returns (address[] memory);

    function getPairFees(address pair) external view returns (uint256);

    function getPairRate(address pair) external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address _feeTo) external;

    function setFeeToSetter(address _feeToSetter) external;

    function addPairs(address[] calldata pairs) external returns (bool);

    function delPairs(address[] calldata pairs) external returns (bool);

    function setFeeRateNumerator(uint256 _feeRateNumerator) external;

    function setPairFees(address[] calldata pairs, uint256[] calldata fees) external;

    function setDefaultFeeToRate(uint256 rate) external;

    function setPairFeeToRate(address[] calldata pairs, uint256[] calldata rates) external;
}

