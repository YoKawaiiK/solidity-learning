// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./logger.sol";

import "./interface_logger.sol";

contract Demo {
    InterfaceLogger logger;

    constructor(address _logger) {
        logger = InterfaceLogger(_logger);
    }

    receive() external payable {
        logger.log(msg.sender, msg.value);
    }

    function payment(address _from, uint _number) public view returns (uint) {
        return logger.getEntry(_from, _number);
    }
}
