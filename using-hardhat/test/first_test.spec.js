const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FirstTest", function () {
  it("Should return the new first test once it's changed", async function () {
    const FirstTest = await ethers.getContractFactory("FirstTest");
    const firstTest = await FirstTest.deploy();
    await firstTest.deployed();

    expect(await firstTest.get()).to.equal("");

    await firstTest.set("Data");
    expect(await firstTest.get()).to.equal("Data");

  });
});
