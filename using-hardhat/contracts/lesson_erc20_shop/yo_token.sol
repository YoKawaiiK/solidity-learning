// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 < 0.9.0;

import "./erc20.sol";

contract YoToken is ERC20 {

    constructor(address _shop) ERC20("YoToken", "YTKN", 8, 20) {
        mint(_shop, 20);
    }
}
