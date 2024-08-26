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
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IFactoryManager } from "../interfaces/IFactoryManager.sol";

contract TokenFactoryBase is Ownable, ReentrancyGuard {
    using Address for address payable;

    address public immutable FACTORY_MANAGER;
    address public implementation;
    uint96 public implementationVersion; // Max value: 79228162514264337593543950335
    address public feeTo;
    uint256 public flatFee;
    uint256 public immutable MAX_FEE;

    event TokenCreated(
        address indexed owner,
        address indexed token,
        uint8 tokenType,
        uint96 tokenVersion
    );

    error InvalidFactoryManager(address implementation);
    error InvalidImplementation(address factoryManager);
    error InvalidFeeReceiver(address receiver);
    error InvalidFee(uint256 fee);
    error InvalidMaxFee(uint256 maxFee);
    error InsufficientFee(uint256 fee);

    modifier enoughFee() {
        if (msg.value < flatFee) revert InsufficientFee(msg.value);
        _;
    }

    constructor(
        address factoryManager_,
        address implementation_,
        address feeTo_,
        uint256 flatFee_,
        uint256 maxFee_
    ) {
        if (factoryManager_ == address(0))
            revert InvalidFactoryManager(factoryManager_);
        if (implementation_ == address(0))
            revert InvalidImplementation(implementation_);
        if (feeTo_ == address(0)) revert InvalidFeeReceiver(feeTo_);
        if (flatFee_ >= maxFee_) revert InvalidFee(flatFee_);
        if (flatFee_ == 0) revert InvalidMaxFee(maxFee_);

        FACTORY_MANAGER = factoryManager_;
        implementation = implementation_;
        implementationVersion = 1;
        feeTo = feeTo_;
        flatFee = flatFee_;
        MAX_FEE = maxFee_;
    }

    function setImplementation(address implementation_) external onlyOwner {
        if (implementation_ == address(0) || implementation_ == address(this))
            revert InvalidImplementation(implementation_);
        implementation = implementation_;
        ++implementationVersion;
    }

    function setFeeTo(address feeReceivingAddress) external onlyOwner {
        if (
            feeReceivingAddress == address(0) ||
            feeReceivingAddress == address(this)
        ) revert InvalidFeeReceiver(feeReceivingAddress);
        feeTo = feeReceivingAddress;
    }

    function setFlatFee(uint256 fee) external onlyOwner {
        if (fee >= MAX_FEE) revert InvalidFee(fee);
        flatFee = fee;
    }

    function assignTokenToOwner(
        address owner,
        address token,
        uint8 tokenType
    ) internal {
        IFactoryManager(FACTORY_MANAGER).assignTokensToOwner(
            owner,
            token,
            tokenType
        );
    }

    function refundExcessiveFee() internal {
        uint256 refund = msg.value - flatFee;
        if (refund > 0) {
            payable(msg.sender).sendValue(refund);
        }
    }
}
