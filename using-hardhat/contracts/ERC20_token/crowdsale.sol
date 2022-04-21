// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./erc20_token.sol";

contract Crowdsale {
    address owner;

    ERC20Token public token;
    uint start = block.timestamp + 10 days;
    uint period = 28 days;

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not a owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        token = new ERC20Token(0, "Simple Token", 20, "STK");
    }

    function startSelling() public payable onlyOwner {
        // Check data 
        // require(block.timestamp > start && block.timestamp < start + period);
        payable(owner).transfer(msg.value);
        
        token.mint(msg.sender, address(this).balance);
    }

}
