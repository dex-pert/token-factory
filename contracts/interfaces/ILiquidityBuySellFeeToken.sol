// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 *  ____            ____           _   
 * |  _ \  _____  _|  _ \ ___ _ __| |_ 
 * | | | |/ _ \ \/ / |_) / _ \ '__| __|
 * | |_| |  __/>  <|  __/  __/ |  | |_ 
 * |____/ \___/_/\_\_|   \___|_|   \__|
 *
 * This smart contract was created effortlessly using the DexPert Token Creator.
 * 
 * 🌐 Website: https://www.dexpert.io/
 * 🐦 Twitter: https://x.com/DexpertOfficial
 * 💬 Telegram: https://t.me/DexpertCommunity
 * 
 * 🚀 Unleash the power of decentralized finances and tokenization with DexPert Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!
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
