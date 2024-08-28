// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const standardToken01 = await hre.ethers.deployContract("StandardToken01");
  await standardToken01.waitForDeployment();
  const standardToken01Address = standardToken01.target
  console.log("standardTokenAddress 01:", standardToken01Address)

  const standardToken02 = await hre.ethers.deployContract("StandardToken02");
  await standardToken02.waitForDeployment();
  const standardToken02Address = standardToken02.target
  console.log("standardTokenAddress 02:", standardToken02Address)

  const tokenFactoryManager = await hre.ethers.deployContract("TokenFactoryManager");
  await tokenFactoryManager.waitForDeployment();
  const tokenFactoryManagerAddress = tokenFactoryManager.target
  console.log("tokenFactoryManagerAddress:", tokenFactoryManagerAddress)

  const feeToAddress = "0xD3952283B16C813C6cE5724B19eF56CBEE0EaA89"
  const StandardTokenFactory01 = await hre.ethers.deployContract("StandardTokenFactory01", [
    tokenFactoryManagerAddress,
    standardToken01Address,
    feeToAddress,
    "300000000000000000",
    "100000000000000000",
    "100000000000000000000000000"
  ]);
  const StandardTokenFactory02 = await hre.ethers.deployContract("StandardTokenFactory02", [
    tokenFactoryManagerAddress,
    standardToken02Address,
    feeToAddress,
    "300000000000000000",
    "100000000000000000",
    "100000000000000000000000000"
  ]);
  await StandardTokenFactory01.waitForDeployment();
  await StandardTokenFactory02.waitForDeployment();
  const standardTokenFactory01Address = StandardTokenFactory01.target
  const standardTokenFactory02Address = StandardTokenFactory02.target
  console.log("standardTokenFactoryAddress 01:", standardTokenFactory01Address)
  console.log("standardTokenFactoryAddress 02:", standardTokenFactory02Address)

  await tokenFactoryManager.addTokenFactory(standardTokenFactory01Address);
  await tokenFactoryManager.addTokenFactory(standardTokenFactory02Address);

  await hre.run("verify:verify", {
    address: standardToken01Address,
  });

  await hre.run("verify:verify", {
    address: standardToken02Address,
  });

  await hre.run("verify:verify", {
    address: tokenFactoryManagerAddress,
  });

  // await hre.run("verify:verify", {
  //   address: liquidityBuySellFeeTokenFactoryAddress,
  //   constructorArguments: [
  //     tokenFactoryManagerAddress,
  //     standardTokenAddress,
  //     feeToAddress,
  //     "300000000000000000",
  //     "300000000000000000",
  //     "100000000000000000000000000"
  //   ],
  // });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
