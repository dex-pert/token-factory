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
    const tokenFactoryManager = await TokenFactoryManager.deploy();

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
        { value: hre.ethers.utils.parseEther("0.3") }
      );
      const tokens = await tokenFactoryManager.getTokens(owner.address, 0, 1)
      const tokenLength = await tokenFactoryManager.getTokensCount(owner.address);
      const token: any = tokens[0][0]
      const tokenContract: any = new ethers.Contract(token, StandardTokenJSON.abi)
      // console.log("tokenContract:",tokenContract)
      await tokenContract.connect(owner).approve(token, totalSupply)
      // await tokenContract.connect(owner).openTrading("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", totalSupply, { value: hre.ethers.utils.parseEther("1") })
      await tokenContract.connect(owner).openTrading("0xB0Cc30795f9E0125575742cFA8e73D20D9966f81", totalSupply, { value: hre.ethers.utils.parseEther("1") })
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
