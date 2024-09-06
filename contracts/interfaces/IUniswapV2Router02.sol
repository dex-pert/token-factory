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
import { IUniswapV2Router01 } from "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
