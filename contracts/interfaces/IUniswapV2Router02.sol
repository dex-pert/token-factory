// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 *  ____  _______  _______           _     
 * |  _ \| ____\ \/ /_   _|__   ___ | |___ 
 * | | | |  _|  \  /  | |/ _ \ / _ \| / __|
 * | |_| | |___ /  \  | | (_) | (_) | \__ \
 * |____/|_____/_/\_\ |_|\___/ \___/|_|___/
 *
 * This smart contract was created effortlessly using the DEXTools Token Creator.
 * 
 * 🌐 Website: https://www.dextools.io/
 * 🐦 Twitter: https://twitter.com/DEXToolsApp
 * 💬 Telegram: https://t.me/DEXToolsCommunity
 * 
 * 🚀 Unleash the power of decentralized finances and tokenization with DEXTools Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!
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
