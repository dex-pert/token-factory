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
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { TokenFactoryBase } from "./TokenFactoryBase.sol";
import { IStandardERC20 } from "../interfaces/IStandard02ERC20.sol";
import { TokenMetadata } from "../StandardToken02.sol";

contract StandardTokenFactory02 is TokenFactoryBase {
    using Address for address payable;
    constructor(
        address factoryManager_,
        address implementation_,
        address feeTo_,
        uint256 flatFee_,
        uint256 proxyFee_,
        uint256 maxFee_
    )
        TokenFactoryBase(
            factoryManager_,
            implementation_,
            feeTo_,
            flatFee_,
            proxyFee_,
            maxFee_
        )
    {}

    function create(
        uint256 level,
        TokenMetadata calldata tokenMetadata
    ) external payable enoughFee nonReentrant returns (address token) {
        require(level == 0 || level == 1 || level == 2, "Invalid Level");
        if (level == 1) {
            refundExcessiveFlatFee();
            payable(feeTo).sendValue(flatFee);
        } else if (level == 2) {
            refundExcessiveProxyFee();
            payable(feeTo).sendValue(proxyFee);
        } else {
            payable(msg.sender).sendValue(msg.value);
        }
        token = Clones.cloneDeterministic(implementation, keccak256(abi.encodePacked(msg.sender, tokenMetadata.name, tokenMetadata.symbol, tokenMetadata.decimals, tokenMetadata.totalSupply)));
        IStandardERC20(token).initialize(
            msg.sender,
            tokenMetadata
        );
        assignTokenToOwner(msg.sender, token, 0);
        emit TokenCreated(msg.sender, token, 0, implementationVersion);
    }
}
