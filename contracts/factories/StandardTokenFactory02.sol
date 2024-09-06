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
import { IStandard02ERC20 } from "../interfaces/IStandard02ERC20.sol";
import { TokenMetadata } from "../StandardToken02.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract StandardTokenFactory02 is TokenFactoryBase {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private levels;
    constructor(
        address factoryManager_,
        address implementation_,
        address feeTo_,
        uint256 maxFee_
    )
        TokenFactoryBase(
            factoryManager_,
            implementation_,
            feeTo_,
            maxFee_
        )
    {}

    function create(
        uint256 level,
        TokenMetadata calldata tokenMetadata
    ) external payable enoughFee(level) nonReentrant returns (address token) {
        require(levels.contains(level), "Invalid Level");
        refundExcessiveFee(level);
        if (fees[level] > 0){
            payable(feeTo).sendValue(fees[level]);
        }
        token = Clones.cloneDeterministic(implementation, keccak256(abi.encodePacked(msg.sender, tokenMetadata.name, tokenMetadata.symbol, tokenMetadata.decimals, tokenMetadata.totalSupply)));
        IStandard02ERC20(token).initialize(
            msg.sender,
            tokenMetadata
        );
        assignTokenToOwner(msg.sender, token, 1);
        emit TokenCreated(msg.sender, token, 1, implementationVersion, level);
    }

    function setLevels(uint256[] memory _levels) external onlyOwner {
        for (uint256 i = 0; i < levels.length(); i++) {
            levels.remove(levels.at(i));
        }

        for (uint256 i = 0; i < _levels.length; i++) {
            levels.add(_levels[i]);
        }
    }

    function getLevels() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](levels.length());
        for (uint256 i = 0; i < levels.length(); i++) {
            result[i] = levels.at(i);
        }
        return result;
    }
}
