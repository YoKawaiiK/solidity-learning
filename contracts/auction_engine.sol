// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

struct Auction {
    address payable seller;
    uint startingPrice;
    uint finalPrice;
    uint startAt;
    uint endsAt;
    uint discountRate;
    string item;
    bool stopped;
}

contract AuctionEngine {
    address public owner;
    uint constant DURATION = 2 days;
    uint constant FEE = 10;
    Auction[] public auctions;

    constructor() {
        owner = msg.sender;
    }

    event AuctionCreated(
        uint index,
        string itemName,
        uint startingPrice,
        uint duration
    );
    event AuctionEnded(uint index, uint price, address winner);

    function createAuction(
        uint startingPrice,
        uint discountRate,
        string calldata item,
        uint duration
    ) external {
        duration = duration == 0 ? duration : DURATION;

        require(
            startingPrice >= discountRate * duration,
            "Incorrect starting price"
        );

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: startingPrice,
            finalPrice: startingPrice,
            startAt: block.timestamp,
            endsAt: block.timestamp + duration,
            discountRate: discountRate,
            item: item,
            stopped: false
        });

        auctions.push(newAuction);

        emit AuctionCreated(auctions.length - 1, item, startingPrice, duration);
    }

    function getPriceFor(uint index) public view returns (uint) {
        Auction memory cAuction = auctions[index];

        require(!cAuction.stopped, "It's stopped");

        uint elapsed = block.timestamp - cAuction.startAt;
        uint discount = cAuction.discountRate * elapsed;
        return cAuction.startingPrice - discount;
    }

    function buy(uint index) external payable {
        Auction memory cAuction = auctions[index];
        require(!cAuction.stopped, "It's stopped");
        require(block.timestamp < cAuction.endsAt, "It's ended");
        uint cPrice = getPriceFor(index);
        require(msg.value >= cPrice, "Not enough funds");

        cAuction.stopped = true;
        cAuction.finalPrice = cPrice;
        uint refund = msg.value - cPrice;

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        cAuction.seller.transfer(cPrice - ((cPrice * FEE) / 100));

        emit AuctionEnded(index, cPrice, msg.sender);
    }
}
