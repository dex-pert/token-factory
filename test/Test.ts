import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";
import StandardTokenJSON from "../artifacts/contracts/StandardToken01.sol/StandardToken01.json";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const TokenFactoryManager = await hre.ethers.getContractFactory("TokenFactoryManager");
    const tokenFactoryManager = await TokenFactoryManager.deploy();

    const StandardToken01 = await hre.ethers.getContractFactory("StandardToken01");
    const standardToken01 = await StandardToken01.deploy();

    const StandardToken02 = await hre.ethers.getContractFactory("StandardToken02");
    const standardToken02 = await StandardToken02.deploy();

    const feeToAddress = "0xD3952283B16C813C6cE5724B19eF56CBEE0EaA89"
    const StandardTokenFactory01 = await hre.ethers.getContractFactory("StandardTokenFactory01");

    const tokenFactoryManagerAddress = await tokenFactoryManager.getAddress()
    const standardToken01Address = await standardToken01.getAddress()
    const standardToken02Address = await standardToken02.getAddress()
    const standardTokenFactory01 = await StandardTokenFactory01.deploy(
      tokenFactoryManagerAddress,
      standardToken01Address,
      feeToAddress,
      "300000000000000000",
      "300000000000000000",
      "100000000000000000000000000"
    );

    const StandardTokenFactory02 = await hre.ethers.getContractFactory("StandardTokenFactory02");
    const standardTokenFactory02 = await StandardTokenFactory02.deploy(
      tokenFactoryManagerAddress,
      standardToken02Address,
      feeToAddress,
      "300000000000000000",
      "300000000000000000",
      "100000000000000000000000000"
    );

    console.log("owner:", owner.address)
    console.log("otherAccount:", otherAccount.address)
    return { standardToken01, standardToken02, tokenFactoryManager, standardTokenFactory01, standardTokenFactory02, owner };
  }

  describe("standardTokenFactory01", function () {
    it("level 0", async function () {
      const { standardToken01, standardToken02, tokenFactoryManager, standardTokenFactory01, standardTokenFactory02, owner } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory01.getAddress());
      await tokenFactoryManager.addTokenFactory(standardTokenFactory02.getAddress());
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      await standardTokenFactory01.connect(owner).create(
        0,
        {
          name: name,
          symbol: symbol,
          decimals: decimals,
          totalSupply: totalSupply,
          description: "",
          logoLink: "",
          twitterLink: "",
          telegramLink: "",
          discordLink: "",
          websiteLink: ""
        },
        { value: hre.ethers.parseEther("0.3") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 1)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      const token: any = tokens[0][0]
      const tokenContract: any = new ethers.Contract(token, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(token, totalSupply)
      await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.parseEther("1") })
      // await tokenContract.connect(owner).openTrading("0xb0cc30795f9e0125575742cfa8e73d20d9966f81",totalSupply, {value:  hre.ethers.parseEther("1")})
    });
    it("level 1", async function () {
      const { standardToken01, standardToken02, tokenFactoryManager, standardTokenFactory01, standardTokenFactory02, owner } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory01.getAddress());
      await tokenFactoryManager.addTokenFactory(standardTokenFactory02.getAddress());
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      await standardTokenFactory01.connect(owner).create(
        1,
        {
          name: name,
          symbol: symbol,
          decimals: decimals,
          totalSupply: totalSupply,
          description: "",
          logoLink: "",
          twitterLink: "",
          telegramLink: "",
          discordLink: "",
          websiteLink: ""
        },
        { value: hre.ethers.parseEther("0.3") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 1)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      const token: any = tokens[0][0]
      const tokenContract: any = new ethers.Contract(token, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(token, totalSupply)
      await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.parseEther("1") })
      // await tokenContract.connect(owner).openTrading("0xb0cc30795f9e0125575742cfa8e73d20d9966f81",totalSupply, {value:  hre.ethers.parseEther("1")})
    });
    it("level 2", async function () {
      const { standardToken01, standardToken02, tokenFactoryManager, standardTokenFactory01, standardTokenFactory02, owner } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory01.getAddress());
      await tokenFactoryManager.addTokenFactory(standardTokenFactory02.getAddress());
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      const createTokenRespon2 = await standardTokenFactory01.connect(owner).create(
        2,
        {
          name: name + "222",
          symbol: symbol,
          decimals: decimals,
          totalSupply: totalSupply,
          description: "",
          logoLink: "",
          twitterLink: "",
          telegramLink: "",
          discordLink: "",
          websiteLink: ""
        },
        { value: hre.ethers.parseEther("0.3") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 1)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      const token: any = tokens[0][0]
      const tokenContract: any = new ethers.Contract(token, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(token, totalSupply)
      await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.parseEther("1") })
      // await tokenContract.connect(owner).openTrading("0xb0cc30795f9e0125575742cfa8e73d20d9966f81",totalSupply, {value:  hre.ethers.parseEther("1")})
    });
  });

  describe("standardTokenFactory02", function () {
    it("level 0", async function () {
      const { standardToken01, standardToken02, tokenFactoryManager, standardTokenFactory01, standardTokenFactory02, owner } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory01.getAddress());
      await tokenFactoryManager.addTokenFactory(standardTokenFactory02.getAddress());
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      await standardTokenFactory02.connect(owner).create(
        0,
        {
          name: name,
          symbol: symbol,
          decimals: decimals,
          totalSupply: totalSupply,
          logoLink: "",
          twitterLink: "",
          telegramLink: "",
          discordLink: "",
          maxTxAmount: totalSupply,
          maxWalletSize: totalSupply,
          taxSwapThreshold: 0,
          maxTaxSwap: 0,
          initialBuyTax: 0,
          initialSellTax: 0,
          finalBuyTax: 0,
          finalSellTax: 0,
          reduceBuyTaxAt: 0,
          reduceSellTaxAt: 0,
          noSwapBefore: 0,
          buyCount: 0,
          description: "",
          websiteLink: ""
        },
        { value: hre.ethers.parseEther("100") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 1)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      const token: any = tokens[0][0]
      const tokenContract: any = new ethers.Contract(token, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(token, totalSupply)
      await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.parseEther("1") })
      // await tokenContract.connect(owner).openTrading("0xb0cc30795f9e0125575742cfa8e73d20d9966f81",totalSupply, {value:  hre.ethers.parseEther("1")})
    });
    it("level 1", async function () {
      const { standardToken01, standardToken02, tokenFactoryManager, standardTokenFactory01, standardTokenFactory02, owner } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory01.getAddress());
      await tokenFactoryManager.addTokenFactory(standardTokenFactory02.getAddress());
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      await standardTokenFactory02.connect(owner).create(
        1,
        {
          name: name,
          symbol: symbol,
          decimals: decimals,
          totalSupply: totalSupply,
          logoLink: "",
          twitterLink: "",
          telegramLink: "",
          discordLink: "",
          maxTxAmount: totalSupply,
          maxWalletSize: totalSupply,
          taxSwapThreshold: 0,
          maxTaxSwap: 0,
          initialBuyTax: 0,
          initialSellTax: 0,
          finalBuyTax: 0,
          finalSellTax: 0,
          reduceBuyTaxAt: 0,
          reduceSellTaxAt: 0,
          noSwapBefore: 0,
          buyCount: 0,
          description: "",
          websiteLink: ""
        },
        { value: hre.ethers.parseEther("100") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 1)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      console.log("tokenLength:", tokenLength)
      console.log("tokens:", tokens)
      const token: any = tokens[0][0]
      console.log("token:", token)
      const tokenContract: any = new ethers.Contract(token, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(token, totalSupply)
      await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.parseEther("1") })
      // await tokenContract.connect(owner).openTrading("0xb0cc30795f9e0125575742cfa8e73d20d9966f81",totalSupply, {value:  hre.ethers.parseEther("1")})
    });
    it("level 2", async function () {
      const { standardToken01, standardToken02, tokenFactoryManager, standardTokenFactory01, standardTokenFactory02, owner } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory01.getAddress());
      await tokenFactoryManager.addTokenFactory(standardTokenFactory02.getAddress());
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      const createTokenRespon2 = await standardTokenFactory02.connect(owner).create(
        2,
       {
          name: name,
          symbol: symbol,
          decimals: decimals,
          totalSupply: totalSupply,
          logoLink: "",
          twitterLink: "",
          telegramLink: "",
          discordLink: "",
          description: "",
          maxTxAmount: totalSupply,
          maxWalletSize: totalSupply,
          taxSwapThreshold: 0,
          maxTaxSwap: 0,
          initialBuyTax: 0,
          initialSellTax: 0,
          finalBuyTax: 0,
          finalSellTax: 0,
          reduceBuyTaxAt: 0,
          reduceSellTaxAt: 0,
          noSwapBefore: 0,
          buyCount: 0,
          websiteLink: ""
        },
        { value: hre.ethers.parseEther("100") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 1)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      console.log("tokenLength:", tokenLength)
      console.log("tokens:", tokens)
      const token: any = tokens[0][0]
      console.log("token:", token)
      const tokenContract: any = new ethers.Contract(token, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(token, totalSupply)
      await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.parseEther("1") })
      // await tokenContract.connect(owner).openTrading("0xb0cc30795f9e0125575742cfa8e73d20d9966f81",totalSupply, {value:  hre.ethers.parseEther("1")})
    });
  });
});
