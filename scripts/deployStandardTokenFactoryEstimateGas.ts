// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the

import { ethers } from "hardhat";
import { abi } from "../artifacts/contracts/StandardToken02.sol/StandardToken02.json"
import { BigNumber } from "ethers";

// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const StandardToken01 = await hre.ethers.getContractFactory("StandardToken01");
  const gasEstimateStandardToken01 = await hre.ethers.provider.estimateGas(StandardToken01.getDeployTransaction());
console.log("StandardToken01 部署的 Gas 预估:", gasEstimateStandardToken01.toString());

  const TokenFactoryManager = await hre.ethers.getContractFactory("TokenFactoryManager");
  const gasEstimateTokenFactoryManager = await hre.ethers.provider.estimateGas(TokenFactoryManager.getDeployTransaction());
console.log("TokenFactoryManager 部署的 Gas 预估:", gasEstimateTokenFactoryManager.toString());

  const feeToAddress = "0x7002421C457b83425293DE5a7BFEB68B01A6f693"
  const StandardTokenFactory01 = await hre.ethers.getContractFactory("StandardTokenFactory01");
  // const gasEstimateStandardTokenFactory01 = await hre.ethers.provider.estimateGas(StandardTokenFactory01.getDeployTransaction(
  //   ethers.constants.AddressZero,
  //   ethers.constants.AddressZero,
  //   feeToAddress,
  //   "100000000000000000000000000"))
  // console.log("StandardTokenFactory01 部署的 Gas 预估:", gasEstimateStandardTokenFactory01.toString());
  const gasEstimateStandardTokenFactory01 = BigNumber.from(1394708)

  const gasPrice = await hre.ethers.provider.getGasPrice();
console.log("当前的 Gas 价格:", hre.ethers.utils.formatUnits(gasPrice, "gwei"), "gwei");

const costStandardToken01 = gasEstimateStandardToken01.mul(gasPrice);
console.log("StandardToken01 部署的成本 (wei):", costStandardToken01.toString());

const costTokenFactoryManager = gasEstimateTokenFactoryManager.mul(gasPrice);
console.log("TokenFactoryManager 部署的成本 (wei):", costTokenFactoryManager.toString());

const costStandardTokenFactory01 = gasEstimateStandardTokenFactory01.mul(gasPrice);
console.log("StandardTokenFactory01 部署的成本 (wei):", costStandardTokenFactory01.toString());

console.log("StandardToken01 部署的成本 (ETH):", hre.ethers.utils.formatEther(costStandardToken01));
console.log("TokenFactoryManager 部署的成本 (ETH):", hre.ethers.utils.formatEther(costTokenFactoryManager));
console.log("StandardTokenFactory01 部署的成本 (ETH):", hre.ethers.utils.formatEther(costStandardTokenFactory01));


// const costStandardTokenFactory01 = gasEstimateStandardTokenFactory01.mul(gasPrice);
// console.log("StandardTokenFactory01 部署的成本 (wei):", costStandardTokenFactory01.toString());


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
