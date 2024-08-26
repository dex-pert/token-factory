// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const liquidityBuySellFeeToken = await hre.ethers.deployContract("LiquidityBuySellFeeToken");
  await liquidityBuySellFeeToken.waitForDeployment();
  const liquidityBuySellFeeTokenAddress = liquidityBuySellFeeToken.target
  console.log("liquidityBuySellFeeTokenAddress:",liquidityBuySellFeeTokenAddress)

  const tokenFactoryManager = await hre.ethers.deployContract("TokenFactoryManager");
  await tokenFactoryManager.waitForDeployment();
  const tokenFactoryManagerAddress = tokenFactoryManager.target
  console.log("tokenFactoryManagerAddress:",tokenFactoryManagerAddress)

  const feeToAddress = "0xD3952283B16C813C6cE5724B19eF56CBEE0EaA89"
  const liquidityBuySellFeeTokenFactory = await hre.ethers.deployContract("LiquidityBuySellFeeTokenFactory", [
    tokenFactoryManagerAddress,
    liquidityBuySellFeeTokenAddress,
    feeToAddress,
    "300000000000000000",
    "100000000000000000000000000"
  ]);
  await liquidityBuySellFeeTokenFactory.waitForDeployment();
  const liquidityBuySellFeeTokenFactoryAddress = liquidityBuySellFeeTokenFactory.target
  console.log("liquidityBuySellFeeTokenFactoryAddress:",liquidityBuySellFeeTokenFactoryAddress)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
