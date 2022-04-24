// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

import {ERC20Token} from "../ERC20_token/erc20_token.sol";

contract LoanContract {
    address public lender;
    address public borrower;
    ERC20Token public token;
    uint256 public collateralAmount;
    uint256 public payOffAmount;
    uint256 public dueDate;

    constructor(
        address _lender,
        address _borrower,
        ERC20Token _token,
        uint256 _collateralAmount,
        uint256 _payOffAmount,
        uint256 _loanDuration
    ) {
        lender = _lender;
        borrower = _borrower;
        token = _token;
        collateralAmount = _collateralAmount;
        payOffAmount = _payOffAmount;
        dueDate = _loanDuration + _loanDuration;
    }

    event LoanPaid();

    function payLoan() public payable {
        require(block.timestamp <= dueDate);
        require(msg.value == payOffAmount);
        require(token.transfer(borrower, collateralAmount));
        payable(lender).transfer(payOffAmount);
        emit LoanPaid();
        selfdestruct(payable(lender));
    }

    function repossess() public {
        require(block.timestamp > dueDate);
        require(token.transfer(lender, collateralAmount));
        selfdestruct(payable(lender));
    }
}
