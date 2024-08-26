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
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IFactoryManager } from "../interfaces/IFactoryManager.sol";
import "hardhat/console.sol";

contract TokenFactoryManager is Ownable, IFactoryManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Token {
        uint8 tokenType;
        address tokenAddress;
    }

    EnumerableSet.AddressSet private tokenFactories;
    mapping(address => Token[]) private tokensOf;
    mapping(address => mapping(address => bool)) private hasToken;
    mapping(address => bool) private isGenerated;

    mapping(address => mapping(uint8 => address[])) private tokensByType;

    error CallerIsNotAValidFactory(address factory);
    error TokenAlreadyExists(address owner, address token);
    error InvalidStart(uint256 start);

    modifier onlyAllowedFactory() {
        if (!tokenFactories.contains(msg.sender))
            revert CallerIsNotAValidFactory(msg.sender);
        _;
    }

    function addTokenFactory(address factory) public onlyOwner {
        tokenFactories.add(factory);
    }

    function addTokenFactories(address[] memory factories) external onlyOwner {
        for (uint256 i = 0; i < factories.length; i++) {
            addTokenFactory(factories[i]);
        }
    }

    function removeTokenFactory(address factory) external onlyOwner {
        tokenFactories.remove(factory);
    }

    function assignTokensToOwner(
        address owner,
        address token,
        uint8 tokenType
    ) external override onlyAllowedFactory {
        console.log("-----------assignTokensToOwner------------");
        if (isGenerated[token]) revert TokenAlreadyExists(owner, token);
        tokensOf[owner].push(Token(tokenType, token));
        tokensByType[owner][tokenType].push(token);
        hasToken[owner][token] = true;
        isGenerated[token] = true;
    }

    function getAllowedFactories() external view returns (address[] memory) {
        uint256 length = tokenFactories.length();
        address[] memory factories = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            factories[i] = tokenFactories.at(i);
        }
        return factories;
    }

    function isTokenGenerated(address token) external view returns (bool) {
        return isGenerated[token];
    }

    function getToken(
        address owner,
        uint256 index
    ) external view returns (address, uint8) {
        if (index > tokensOf[owner].length) {
            return (address(0), 0);
        }
        return (
            tokensOf[owner][index].tokenAddress,
            uint8(tokensOf[owner][index].tokenType)
        );
    }

    function getTokensCount(address owner) external view returns (uint256) {
        return tokensOf[owner].length;
    }

    function getTokens(
        address owner,
        uint256 start,
        uint256 limit
    ) external view returns (address[] memory, uint8[] memory) {
        uint256 length = tokensOf[owner].length;

        if (start > length) revert InvalidStart(start);

        if (start + limit > length) {
            limit = length - start;
        }

        address[] memory tokenAddresses = new address[](limit);
        uint8[] memory tokenTypes = new uint8[](limit);

        length = start + limit;

        for (uint256 i = start; i < length; i++) {
            tokenAddresses[i - start] = tokensOf[owner][i].tokenAddress;
            tokenTypes[i - start] = uint8(tokensOf[owner][i].tokenType);
        }

        return (tokenAddresses, tokenTypes);
    }

    function getTokensCountByType(
        address owner,
        uint8 tokenType
    ) external view returns (uint256) {
        return tokensByType[owner][tokenType].length;
    }

    function getTokensByType(
        address owner,
        uint8 tokenType,
        uint256 start,
        uint256 limit
    ) external view returns (address[] memory) {
        uint256 length = tokensByType[owner][tokenType].length;

        if (start > length) revert InvalidStart(start);

        if (start + limit > length) {
            limit = length - start;
        }

        address[] memory tokenAddresses = new address[](limit);

        length = start + limit;

        for (uint256 i = start; i < length; i++) {
            tokenAddresses[i - start] = tokensByType[owner][tokenType][i];
        }

        return tokenAddresses;
    }
}
