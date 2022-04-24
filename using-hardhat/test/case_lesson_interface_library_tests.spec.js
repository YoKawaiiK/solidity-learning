const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Lesson: interface, library, tests", () => {
  describe("Part 1: Using interfaces", async () => {
    let owner;
    let demo;

    beforeEach(async () => {
      [owner] = await ethers.getSigners();

      // logger deploy
      const Logger = await ethers.getContractFactory("Logger", owner);
      logger = await Logger.deploy();
      await logger.deployed();

      // demo deploy
      const Demo = await ethers.getContractFactory("Demo", owner);
      demo = await Demo.deploy(logger.address);
      await demo.deployed();
    });

    it("Allows to pay and get payment info", async () => {
      const sum = 100;

      const txData = {
        value: sum,
        to: demo.address,
      };

      const tx = await owner.sendTransaction(txData);

      await tx.wait();

      await expect(tx).to.changeEtherBalance(demo, sum);

      const amount = await demo.payment(owner.address, 0);

      expect(amount).to.eq(sum);
    });
  });

  describe("Part 2: Using libraries", async () => {
    let owner;
    let libraryDemo;

    beforeEach(async () => {
      [owner] = await ethers.getSigners();

      const StringExtension = await ethers.getContractFactory(
        "StringExtension"
      );
      const stringExtension = await StringExtension.deploy();
      await stringExtension.deployed();

      const ArrayExtension = await ethers.getContractFactory("ArrayExtension");
      const arrayExtension = await ArrayExtension.deploy();
      await arrayExtension.deployed();

      // libraryDemo deploy
      LibraryDemo = await ethers.getContractFactory("LibraryDemo", {
        owner: owner,
        libraries: {
          StringExtension: stringExtension.address,
          ArrayExtension: arrayExtension.address,
        },
      });
      libraryDemo = await LibraryDemo.deploy();
      await libraryDemo.deployed();
    });

    it("Compare strings", async () => {
      const result = await libraryDemo.runnerString("cat", "cat");
      expect(result).to.eq(true);
      const result2 = await libraryDemo.runnerString("cat", "cot");
      expect(result2).to.eq(false);
    });

    it("Contain number in array", async () => {
      const result1 = await libraryDemo.runnerArray([1, 2, 3], 1);
      expect(result1).to.eq(true);

      const result2 = await libraryDemo.runnerArray([1, 2, 3], 3);
      expect(result2).to.eq(true);

      const result3 = await libraryDemo.runnerArray([1, 2, 3], 0);
      expect(result3).to.eq(false);

      const result4 = await libraryDemo.runnerArray([1, 2, 3], 4);
      expect(result4).to.eq(false);
    });
  });
});
