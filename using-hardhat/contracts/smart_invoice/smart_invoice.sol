// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

// Contract with conditions what will require fullPrice,
//  mark if paid and owner will be able to get funds
contract SmartInvoice {
    uint public dueDate;
    uint public invoiceAmount;
    address public owner;
    address public payer;
    bool public isPaid;

    constructor(uint _invoiceAmount, address _payer) {
        dueDate = block.timestamp + 1 days;
        invoiceAmount = _invoiceAmount;
        owner = msg.sender;
        isPaid = false;
        payer = _payer;
    }

    modifier requireFullPrice() {
        require(
            msg.value == invoiceAmount,
            "Payment should be the invoiced amount."
        );
        _;
    }

    fallback() external payable requireFullPrice {}

    receive() external payable requireFullPrice {}

    // payer or owner
    modifier onlyBy(address _account) {
        require(msg.sender == _account, "Not allowed");
        _;
    }

    function pay() public payable requireFullPrice onlyBy(payer) {
        require(address(this).balance == invoiceAmount, "This check was pay.");
        isPaid = true;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getBackFunds() external payable onlyBy(payer) {
        require(block.timestamp < dueDate, "Overdate");
        (bool sent, ) = payer.call{value: address(this).balance}("");
        require(sent, "Failed to get back");
        isPaid = false;
    }

    function sendTo(address payable _to) public payable onlyBy(owner) {
        // bool sent = _to.send(msg.value);
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function withdraw() public onlyBy(owner) {
        require(block.timestamp > dueDate, "Due date has not reached.");
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        isPaid = false;
        require(sent, "Failed to send Ether");
    }
}
