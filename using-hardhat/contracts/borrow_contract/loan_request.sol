// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

import {ERC20Token} from "../ERC20_token/erc20_token.sol";
import {LoanContract} from "./loan_contract.sol";

contract LoanRequestContract {
    address public borrower = msg.sender;
    ERC20Token public token;
    uint256 public collateralAmount;
    uint256 public loanAmount;
    uint256 public payOffAmount;
    uint256 public loanDuration;

    constructor(
        ERC20Token _token,
        uint256 _collateralAmount,
        uint256 _loanAmount,
        uint256 _payOffAmount,
        uint256 _loanDuration
    ) {
        token = _token;
        collateralAmount = _collateralAmount;
        loanAmount = _loanAmount;
        payOffAmount = _payOffAmount;
        loanDuration = _loanDuration;
    }

    LoanContract public loan;
    event LoanRequestAccepted(address loan);

    function lendEther() public payable {
        require(msg.value == collateralAmount, "Don't enough");
        loan = new LoanContract(
            msg.sender,
            borrower,
            token,
            collateralAmount,
            payOffAmount,
            loanDuration
        );
        require(token.transferFrom(borrower, address(loan), collateralAmount));
        payable(borrower).transfer(loanAmount);
        emit LoanRequestAccepted(address(loan));
    }
}
