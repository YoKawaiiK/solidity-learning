// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

import "./ownable.sol";
import "./ierc20.sol";
import "./yo_token.sol";

contract YoShop is Ownable {
    IERC20 public token;

    event Bought(uint256 _amount, address indexed _buyer);
    event Sold(uint256 _amount, address indexed _seller);

    constructor() {
        YoToken yoToken = new YoToken(address(this));
        token = IERC20(address(yoToken));

        owner = payable(msg.sender);
    }

    function sell(uint _amountToSell) external {
        require(
            _amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell,
            "Incorrect amount!"
        );

        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "Check allowance!");

        token.transferFrom(msg.sender, address(this), _amountToSell);

        payable(msg.sender).transfer(_amountToSell);

        emit Sold(_amountToSell, msg.sender);
    }

    receive() external payable {
        uint256 tokensToBuy = msg.value;
        require(tokensToBuy > 0, "Not enough funds!");

        uint256 currentBalance = getTokenBalance();
        require(currentBalance >= tokensToBuy, "Not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }

    function getTokenBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }
}
