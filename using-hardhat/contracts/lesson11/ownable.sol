// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

abstract contract Ownable {
    address public owner;

    constructor(address _owner) {
        owner = _owner == address(0) ? msg.sender : _owner;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not an owner!");
        _;
    }

    function withdraw(address payable _to) public virtual onlyOwner {
        payable(owner).transfer(address(_to).balance);
    }
}
