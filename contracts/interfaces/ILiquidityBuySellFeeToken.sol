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
interface ILiquidityBuySellFeeToken {
    function initialize(
        address owner_,
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address[3] memory addrs, // router, marketing wallet, marketing token
        uint16[3] memory feeSettings, // tax, liquidity, marketing
        uint16[3] memory buyFeeSettings, // buyTax, buyLiquidity, buyMarketing
        uint16[3] memory sellFeeSettings // sellTax, sellLiquidity, sellMarketing
    ) external;
}
