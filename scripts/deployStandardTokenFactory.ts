// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the

import { ethers } from "hardhat";
import { abi } from "../artifacts/contracts/StandardToken02.sol/StandardToken02.json"

// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const StandardToken01 = await hre.ethers.getContractFactory("StandardToken01");
  const standardToken01 = await StandardToken01.deploy();
  const standardToken01Address = standardToken01.address
  console.log("standardTokenAddress 01:", standardToken01Address)

  const TokenFactoryManager = await hre.ethers.getContractFactory("TokenFactoryManager");
  const tokenFactoryManager = await TokenFactoryManager.deploy();
  const tokenFactoryManagerAddress = tokenFactoryManager.address
  console.log("tokenFactoryManagerAddress:", tokenFactoryManagerAddress)
  const gasEstimateTokenFactoryManager = await hre.ethers.provider.estimateGas(TokenFactoryManager.getDeployTransaction());
console.log("TokenFactoryManager 部署的 Gas 预估:", gasEstimateTokenFactoryManager.toString());

  const feeToAddress = "0x7002421C457b83425293DE5a7BFEB68B01A6f693"
  const StandardTokenFactory01 = await hre.ethers.getContractFactory("StandardTokenFactory01");
  const standardTokenFactory01 = await StandardTokenFactory01.deploy( 
    tokenFactoryManagerAddress,
    standardToken01Address,
    feeToAddress,
    "100000000000000000000000000");

  const gasEstimateStandardTokenFactory01 = await hre.ethers.provider.estimateGas(StandardTokenFactory01.getDeployTransaction(
    tokenFactoryManagerAddress,
    standardToken01Address,
    feeToAddress,
    "100000000000000000000000000"))
  console.log("StandardTokenFactory01 部署的 Gas 预估:", gasEstimateStandardTokenFactory01.toString());
  const standardTokenFactory01Address = standardTokenFactory01.address
  console.log("standardTokenFactoryAddress 01:", standardTokenFactory01Address)
 
  await standardTokenFactory01.setLevels([0, 1, 2])
  //eth
  await standardTokenFactory01.setFee(1, "200000000000000000")
  await standardTokenFactory01.setFee(2, "100000000000000000")

  //btc
  // await standardTokenFactory01.setFee(1, "20000000000000000")
  // await standardTokenFactory01.setFee(2, "10000000000000000")

  await tokenFactoryManager.addTokenFactory(standardTokenFactory01Address);
  // await tokenFactoryManager.addTokenFactory(standardTokenFactory02Address);

  // 合约部署后自动验证
  await hre.run("verify:verify", {
    address: standardToken01Address,
    constructorArguments: [],
    force: true,
  });

  await hre.run("verify:verify", {
    address: tokenFactoryManagerAddress,
    constructorArguments: [],
    force: true,
  });

  await hre.run("verify:verify", {
    address: standardTokenFactory01Address,
    constructorArguments: [
      tokenFactoryManagerAddress,
      standardToken01Address,
      feeToAddress,
      "100000000000000000000000000",
    ],
    force: true,
  });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
