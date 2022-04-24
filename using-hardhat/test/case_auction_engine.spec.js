const { expect } = require("chai")
const { ethers } = require("hardhat")
// const {changeEtherBalance} = require("@nomiclabs/hardhat-waffle")

describe("Case 1: auction engine", () => {
  let owner, seller, buyer;
  let auction;

  beforeEach(async () => {
    [owner, seller, buyer] = await ethers.getSigners();

    const AuctionEngine = await ethers.getContractFactory(
      "AuctionEngine",
      owner
    );

    auction = await AuctionEngine.deploy();
    await auction.deployed();
  });

  it("TC 1: Check owner", async () => {
    const currentOwner = await auction.owner();
    expect(currentOwner, `Test must be have owner: ${owner.address}`).to.eq(
      owner.address
    );
  });

  const getTimestamp = async (bn) => {
    return (await ethers.provider.getBlock(bn)).timestamp;
  };

  describe("TC 2: testing createAuction()", async () => {
    it("Creating auction correctly", async () => {
      const item = "fake item";
      const duration = 60;

      const tx = await auction.createAuction(
        ethers.utils.parseEther("0.0001"),
        3,
        item,
        duration
      );

      const currentAuction = await auction.auctions(0);
      expect(currentAuction.item).to.eq(item);

      const ts = await getTimestamp(tx.blockNumber);

      // console.log(BigNumber.from(currentAuction.endsAt).toNumber())
      // console.log(await ethers.utils.toNumber(currentAuction.endsAt))
      console.log(duration);
      console.log(ts);
      console.log(ts + duration);
      console.log(Number(currentAuction.endsAt));

      // expect(BigNumber.from(currentAuction.endsAt).toNumber()).to.be(ts + duration)
      // expect(Number(currentAuction.endsAt)).to.eql(ts + duration);
    });
  });

  const delay = (ms) => {
    return new Promise((resolve) => setTimeout(resolve, ms));
  };

  // describe("Buy", async () => {
  //   it("Allows to buy", async () => {
  //     const item = "fake item";
  //     const duration = 60;
  //     const money = ethers.utils.parseEther("0.0001");

  //     const tx = await auction
  //       .connect(seller)
  //       .createAuction(money, 3, item, duration);

  //     await delay(1000);
      

  //     const buyTx = await auction.connect(buyer).buy(0, { value: money });

  //     const currentAuction = await auction.auctions(0);
  //     const finalPrice = currentAuction.finalPrice;

  //     await expect(() => buyTx)
  //     .to.changeEtherBalance(
  //       seller,
  //       finalPrice - Math.floor((finalPrice * 10) / 100), {
          
  //       }
  //     );
  //   });
  // });
});
