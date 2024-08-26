import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const StandardToken = await hre.ethers.getContractFactory("StandardToken");
    const standardToken = await StandardToken.deploy();

    const TokenFactoryManager = await hre.ethers.getContractFactory("TokenFactoryManager");
    const tokenFactoryManager = await TokenFactoryManager.deploy();

    const feeToAddress = "0xD3952283B16C813C6cE5724B19eF56CBEE0EaA89"
    const StandardTokenFactory = await hre.ethers.getContractFactory("StandardTokenFactory");

    const tokenFactoryManagerAddress = await tokenFactoryManager.getAddress()
    const standardTokenAddress = await standardToken.getAddress()
    const standardTokenFactory = await StandardTokenFactory.deploy(
      tokenFactoryManagerAddress,
      standardTokenAddress,
      feeToAddress,
      "300000000000000000",
      "100000000000000000000000000"
    );
    console.log("owner:",owner.address)
    console.log("otherAccount:",otherAccount.address)
    return { standardToken, tokenFactoryManager, standardTokenFactory, owner};
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { standardToken, tokenFactoryManager, standardTokenFactory, owner } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory.getAddress());
      console.log("standardToken address:",await standardToken.getAddress())
      console.log("tokenFactoryManager address:",await tokenFactoryManager.getAddress())
      console.log("standardTokenFactory address:",await standardTokenFactory.getAddress())
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      const a = await standardTokenFactory.connect(owner).create(
        {
          name: name,
          symbol: symbol,
          decimals: decimals,
          totalSupply: totalSupply,
          logoLink: "",
          twitterLink: "",
          telegramLink: "",
          discordLink: ""
        },
        {value: hre.ethers.parseEther("100")}
      );
    });
  });
});
