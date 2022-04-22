// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./balances.sol";
import "./ownable.sol";

contract MoneyTransfer is Ownable, Balances {
    
    constructor() Ownable(msg.sender){}

    function withdraw(address payable _to) public override(Ownable, Balances) onlyOwner {
        require(_to != address(0), "Zero addres");
        super.withdraw(_to);
    }
}
