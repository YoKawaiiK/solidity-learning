const { expect } = require("chai");
const { ethers } = require("hardhat");
const YoTokenJSON = require("../artifacts/contracts/lesson_erc20_shop/yo_token.sol/YoToken.json");

describe("YoShop", function () {
    let owner;
    let shop;
    let buyer;

    let yoToken;

    beforeEach(async () => {
        [owner, buyer] = await ethers.getSigners();
        const YoShop = await ethers.getContractFactory("YoShop", owner);
        shop = await YoShop.deploy();
        await shop.deployed();

        // read human readable interface of smart contract to read token address
        yoToken = new ethers.Contract(await shop.token(), YoTokenJSON.abi, owner);
    });

    it("Should have an owner and token", async () => {
        expect(await shop.owner()).to.eq(owner.address);

        expect(await shop.token()).to.be.properAddress;
    });

    it("Allow to buy", async () => {
        const tokenAmount = 3;
        const txData = {
            value: tokenAmount,
            to: shop.address,
        };

        const tx = await buyer.sendTransaction(txData);
        await tx.wait();

        expect(await yoToken.balanceOf(buyer.address)).to.eq(tokenAmount);

        await expect(() => tx).to.changeEtherBalance(shop, tokenAmount);

        await expect(tx)
            .to.emit(shop, "Bought")
            .withArgs(tokenAmount, buyer.address);
    });

    it("Allows to sell", async () => {
        const tokenAmount = 3;
        const txData = {
            value: tokenAmount,
            to: shop.address,
        };

        const tx = await buyer.sendTransaction(txData);
        await tx.wait();

        const sellAmount = 2;
        const approval = await yoToken.connect(buyer)
        .approve(shop.address, sellAmount);
        await approval.wait();

        const sellTx = await shop.connect(buyer).sell(sellAmount);
        expect(await sellTx).to.changeEtherBalance(shop, sellAmount)


        expect(sellTx).to.emit(shop, "Sold").withArgs(tokenAmount, buyer.address)

    })
});
