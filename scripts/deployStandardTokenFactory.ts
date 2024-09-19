// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the

import { ethers } from "hardhat";

// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const feeData = await ethers.provider.getFeeData();
  const StandardToken01 = await hre.ethers.getContractFactory("StandardToken01");
  const standardToken01 = await StandardToken01.deploy();
  const standardToken01Address = standardToken01.address
  console.log("standardTokenAddress 01:", standardToken01Address)

  const TokenFactoryManager = await hre.ethers.getContractFactory("TokenFactoryManager");
  //manta
  // const uniswapV2RouterAddress = "0xA3C957B20779Abf06661E25eE361Be1430ef1038"
  //conflux
  // const uniswapV2RouterAddress = "0x62b0873055bf896dd869e172119871ac24aea305"
  //neox
  // const uniswapV2RouterAddress = "0x82b56Dd9c7FD5A977255BA51B96c3D97fa1Af9A9"
  //bitlayer
  // const uniswapV2RouterAddress = "0xB0Cc30795f9E0125575742cFA8e73D20D9966f81"
  //eth
  // const uniswapV2RouterAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
  //bitlayer test
  const uniswapV2RouterAddress = "0xA16fC83947D26f8a16cA02DC30D95Af5440C38AD"
  const tokenFactoryManager = await TokenFactoryManager.deploy(uniswapV2RouterAddress);
  const tokenFactoryManagerAddress = tokenFactoryManager.address
  console.log("tokenFactoryManagerAddress:", tokenFactoryManagerAddress)

  const feeToAddress = "0x7002421C457b83425293DE5a7BFEB68B01A6f693"
  const StandardTokenFactory01 = await hre.ethers.getContractFactory("StandardTokenFactory01");
  const standardTokenFactory01 = await StandardTokenFactory01.deploy( 
    tokenFactoryManagerAddress,
    standardToken01Address,
    feeToAddress,
    "100000000000000000000000000");

  const standardTokenFactory01Address = standardTokenFactory01.address
  console.log("standardTokenFactoryAddress 01:", standardTokenFactory01Address)
 
  await standardTokenFactory01.setLevels([0, 1, 2])
  //eth
  // await standardTokenFactory01.setFee(1, "200000000000000000")
  // await standardTokenFactory01.setFee(2, "100000000000000000")

  //btc
  await standardTokenFactory01.setFee(1, "200000000000000")
  await standardTokenFactory01.setFee(2, "100000000000000")

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
    constructorArguments: [uniswapV2RouterAddress],
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
