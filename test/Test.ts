import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";
import StandardTokenJSON from "../artifacts/contracts/StandardToken01.sol/StandardToken01.json";
import factoryABI from "../abi/factory.json"
import routerABI from "../abi/router.json"
import universalRouterABI from "../abi/UniversalRouter.json"
import permit2ABI from "../abi/permit2.json"
import { BigNumber } from "ethers";

const resetFork = async (block: number = 20633609) => {
  await hre.network.provider.request({
    method: 'hardhat_reset',
    params: [
      {
        forking: {
          jsonRpcUrl: `https://eth-mainnet.g.alchemy.com/v2/NeEJGJMxp5H5Wd9ytPi8c1_PcmiKEh0o`,
          blockNumber: block,
        },
      },
    ],
  })
}

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    await resetFork()
    const [owner, otherAccount]: any = await ethers.getSigners();

    const TokenFactoryManager = await hre.ethers.getContractFactory("TokenFactoryManager");
    const tokenFactoryManager = await TokenFactoryManager.deploy("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D");

    const StandardToken01 = await hre.ethers.getContractFactory("StandardToken01");
    const standardToken01 = await StandardToken01.deploy();


    const feeToAddress = "0xD3952283B16C813C6cE5724B19eF56CBEE0EaA89"
    const StandardTokenFactory01 = await hre.ethers.getContractFactory("StandardTokenFactory01");

    const tokenFactoryManagerAddress = await tokenFactoryManager.address
    const standardToken01Address = await standardToken01.address
    const standardTokenFactory01 = await StandardTokenFactory01.deploy(
      tokenFactoryManagerAddress,
      standardToken01Address,
      feeToAddress,
      "100000000000000000000000000"
    );

    await standardTokenFactory01.connect(owner).setLevels([0, 1, 2])
    await standardTokenFactory01.connect(owner).setFee(0, 0)
    await standardTokenFactory01.connect(owner).setFee(1, "100000000000000000")
    await standardTokenFactory01.connect(owner).setFee(2, "300000000000000000")

    const levels1 = await standardTokenFactory01.connect(owner).getLevels();
    const fee0 = await standardTokenFactory01.connect(owner).fees(0)
    const fee1 = await standardTokenFactory01.connect(owner).fees(1)
    console.log("levels 1:", levels1)
    console.log("fee 0:", fee0)
    console.log("fee 1:", fee1)
    console.log("owner:", owner.address)
    console.log("otherAccount:", otherAccount.address)
    return { standardToken01, tokenFactoryManager, standardTokenFactory01, owner, otherAccount };
  }

  describe("standardTokenFactory01", function () {
    it("level 0", async function () {
      const { standardToken01, tokenFactoryManager, standardTokenFactory01, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);

      await tokenFactoryManager.addTokenFactory(standardTokenFactory01.address);
      const name = "name"
      const symbol = "symbol"
      const decimals = 18
      const totalSupply = 1000000000
      await standardTokenFactory01.connect(owner).create(
        0,
        name,
        symbol,
        decimals,
        totalSupply,
        {
          description: "",
          logo: "",
          twitter: "",
          telegram: "",
          discord: "",
          website: ""
        },
        { value: hre.ethers.utils.parseEther("0.3") }
      );
      await standardTokenFactory01.connect(owner).create(
        0,
        name + "1",
        symbol,
        decimals,
        totalSupply,
        {
          description: "",
          logo: "",
          twitter: "",
          telegram: "",
          discord: "",
          website: ""
        },
        { value: hre.ethers.utils.parseEther("0.3") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 2)
      const tokenA = await tokenFactoryManager.getTokensByType(owner.address, 0, 0, 2)
      console.log("token a:", tokenA)
      const a = await tokenFactoryManager.getTokensCountByType(owner.address, 0)
      console.log("a:", a)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      console.log("tokenLength:",tokenLength)
      const token: any = tokens
      console.log("token[0].tokenAddress:",token[0].tokenAddress)
      const tokenAddress = token[0].tokenAddress
      const tokenContract: any = new ethers.Contract(tokenAddress, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(standardTokenFactory01.address, totalSupply)
      // await tokenContract.connect(owner).approve(tokenFactoryManager.address, totalSupply)
      // await tokenContract.connect(owner).approve("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply)
      console.log("owner address")
      // await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.utils.parseEther("1") })
      await standardTokenFactory01.connect(owner).openTrading(tokenAddress, totalSupply, { value: hre.ethers.utils.parseEther("1") })
      let tokens1 = await tokenFactoryManager.getTokens(owner.address, 0, 2)
      console.log("tokens1:",tokens1)
      let tokenAb = await tokenFactoryManager.getTokensByType(owner.address, 0, 0, 2)
      console.log("token a:", tokenAb)
      let abc = await tokenFactoryManager.getTokenByAddress(owner.address, tokenAddress)
      console.log("token a:", abc)

      await standardTokenFactory01.connect(owner).updateTokenMetaData(0, tokenAddress, {
        description: "1",
          logo: "2",
          twitter: "3",
          telegram: "4",
          discord: "5",
          website: "6"
      })
      tokens1 = await tokenFactoryManager.getTokens(owner.address, 0, 2)
      console.log("tokens1:",tokens1)
      tokenAb = await tokenFactoryManager.getTokensByType(owner.address, 0, 0, 2)
      console.log("token a:", tokenAb)
      abc = await tokenFactoryManager.getTokenByAddress(owner.address, tokenAddress)
      console.log("token a:", abc)
      return;
      console.log("----------updateTokenMetaData-----------")
      console.log(standardTokenFactory01.address)
      // await tokenContract.connect(otherAccount).updateTokenMetaData({
      //   description: "",
      //   logoLink: "",
      //   twitterLink: "",
      //   telegramLink: "",
      //   discordLink: "",
      //   websiteLink: ""
      // })
      await standardTokenFactory01.connect(owner).updateTokenMetaData(1, token, {
        description: "",
        logoLink: "",
        twitterLink: "",
        telegramLink: "",
        discordLink: "",
        websiteLink: ""
      }, {value: ethers.utils.parseEther('1')})
    });
  });
});
