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
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { TokenFactoryBase } from "./TokenFactoryBase.sol";
import "../interfaces/IStandardToken01.sol";
import { TokenInitializeParams, TokenMetaData } from "../lib/TokenFactoryStructs.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract StandardTokenFactory01 is TokenFactoryBase {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private levels;

    mapping(address => address) private _tokenOwnerAddresses;

    function _onlyTokenOwner(address token) internal view {
        if (msg.sender != _tokenOwnerAddresses[token]) {
            revert OnlyOwner();
        }
    }

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
        TokenInitializeParams calldata tokenInitializeParams
    ) external payable enoughFee(level) nonReentrant returns (address token) {
        // Ensure msg.sender is an externally owned account (EOA) and not a contract
        require(!Address.isContract(msg.sender), "Contracts are not allowed");

        require(levels.contains(level), "Invalid Level");
        refundExcessiveFee(level);
        if (fees[level] > 0){
            Address.sendValue(payable(feeTo), fees[level]);
        }
        token = Clones.cloneDeterministic(implementation, keccak256(abi.encodePacked(msg.sender, tokenInitializeParams.name, tokenInitializeParams.symbol, tokenInitializeParams.decimals, tokenInitializeParams.totalSupply)));
        IStandardToken01(token).initialize(
            msg.sender,
            address(this),
            tokenInitializeParams
        );
        assignTokenToOwner(msg.sender, token, 0);
        _tokenOwnerAddresses[token] = msg.sender;
        emit TokenCreated(msg.sender, token, 0, implementationVersion, level);
    }

    function setLevels(uint256[] memory _levels) external onlyOwner {
        for (uint256 i = 0; i < levels.length(); i++) {
            levels.remove(levels.at(i));
        }

        for (uint256 i = 0; i < _levels.length; i++) {
            levels.add(_levels[i]);
        }
        emit LevelsUpdated(_levels);
    }

    function getLevels() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](levels.length());
        for (uint256 i = 0; i < levels.length(); i++) {
            result[i] = levels.at(i);
        }
        return result;
    }

    function updateTokenMetaData(
        uint256 level,
        address token, 
        TokenMetaData memory tokenMetaData_
    ) external payable enoughFee(level) nonReentrant {
        _onlyTokenOwner(token);

        require(levels.contains(level), "Invalid Level");
        refundExcessiveFee(level);
        if (fees[level] > 0){
            Address.sendValue(payable(feeTo), fees[level]);
        }

        IStandardToken01(token).updateTokenMetaData(
            tokenMetaData_
        );
        
        emit TokenMetaDataUpdated(tokenMetaData_);
    }
}
