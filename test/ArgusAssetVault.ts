import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ArgusAssetVault__factory, ArgusAssetVault, ArgusRWA, ArgusRWA__factory, Truffles, Truffles__factory } from "../typechain-types";

describe("ArtemisZkVoting", () => {
  let accounts: any[];
  let ownerAddress: string;
  let argusAssetVault: ArgusAssetVault;
  let argusRWA: ArgusRWA;
  let truffles: Truffles;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    ownerAddress = await accounts[0].getAddress();

    // Deploy ArgusRWA and Truffles contracts
    const ArgusRWAFactory = await ethers.getContractFactory("ArgusRWA", accounts[0]);
    argusRWA = await ArgusRWAFactory.deploy(ownerAddress);
    const TrufflesFactory = await ethers.getContractFactory("Truffles", accounts[0]);
    truffles = await TrufflesFactory.deploy(ownerAddress);

    // Deploy ArgusAssetVault contract
    const ArgusAssetVaultFactory = await ethers.getContractFactory("ArgusAssetVault", accounts[0]);
    const argusRWAAdress = await argusRWA.getAddress();
    const trufflesAddress = await truffles.getAddress();
    argusAssetVault = await ArgusAssetVaultFactory.deploy(ownerAddress, argusRWAAdress, trufflesAddress);
    await truffles.mint(ownerAddress, ethers.parseEther("1000"));
    await truffles.mint(argusAssetVault, ethers.parseEther("1000"));
  });

  describe("createMarket", function () {
    it("Should create a market successfully", async function () {
      const reserveRatio = 500000; // example ratio
      const initialAmount = ethers.parseEther("1"); // 1 ETH
      const uri = "https://ipfs.io/ipfs/example";

      // Call createMarket
      await expect(argusAssetVault.createMarket(reserveRatio, initialAmount, uri, { value: ethers.parseEther("0.5") }))
        .to.emit(argusAssetVault, "MarketCreated") // Assuming you have a MarketCreated event
        .withArgs(ownerAddress, anyValue); // Use anyValue for dynamic arguments
    });
  });
});
