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

struct TokenMetaData {
    string description;
    string logo;
    string twitter;
    string telegram;
    string discord;
    string website;
}

interface IFactoryManager {
    function assignTokensToOwner(
        address owner,
        address token,
        uint8 tokenType,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals,
        TokenMetaData memory metaData
    ) external;

    function updateTokenData(
        address owner,
        address token,
        TokenMetaData memory metaData_
    ) external;

    function openTrading(
        address owner,
        address token,
        uint tokenAmount
    ) external payable;
}
