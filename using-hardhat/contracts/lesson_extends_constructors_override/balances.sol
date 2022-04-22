// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./ownable.sol";

abstract contract Balances is Ownable {
    function getBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }

    function withdraw(address payable _to) public virtual override onlyOwner {
        _to.transfer(getBalance());
    }

    function giveMoney() public payable {
        require(msg.value > 0, "Only real value");
    }

}
