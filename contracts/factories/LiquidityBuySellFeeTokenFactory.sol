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
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { TokenFactoryBase } from "./TokenFactoryBase.sol";
import { ILiquidityBuySellFeeToken } from "../interfaces/ILiquidityBuySellFeeToken.sol";

contract LiquidityBuySellFeeTokenFactory is TokenFactoryBase {
    using Address for address payable;

    constructor(
        address factoryManager_,
        address implementation_,
        address feeTo_,
        uint256 flatFee_,
        uint256 maxFee_
    )
        TokenFactoryBase(
            factoryManager_,
            implementation_,
            feeTo_,
            flatFee_,
            maxFee_
        )
    {}

    function create(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address[3] memory addrs, // router, marketing wallet, marketing token
        uint16[3] memory feeSettings,
        uint16[3] memory buyFeeSettings,
        uint16[3] memory sellFeeSettings
    ) external payable enoughFee nonReentrant returns (address token) {
        refundExcessiveFee();
        payable(feeTo).sendValue(flatFee);
        token = Clones.cloneDeterministic(implementation, keccak256(abi.encodePacked(msg.sender, name, symbol, totalSupply, feeSettings, buyFeeSettings, sellFeeSettings)));
        ILiquidityBuySellFeeToken(token).initialize(
            msg.sender,
            name,
            symbol,
            totalSupply,
            addrs,
            feeSettings,
            buyFeeSettings,
            sellFeeSettings
        );
        assignTokenToOwner(msg.sender, token, 3);
        emit TokenCreated(msg.sender, token, 3, implementationVersion);
    }
}
