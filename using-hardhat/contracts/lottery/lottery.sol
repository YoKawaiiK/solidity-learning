// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract Lottery {
    address public owner;
    address[] public players;

    uint public enterPrice = 1 ether;

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function getEnterPrice() public view returns (uint) {
        return enterPrice;
    }

    function getPrizePool() public view returns (uint) {
        return address(this).balance;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "This can only be done by the owner.");
        _;
    }

    event Winner(address winner, uint participantCount, uint prize);

    function setEnterPrice(uint newPrice) public onlyOwner {
        enterPrice = newPrice;
    }

    function enter() public payable {
        require(msg.value == enterPrice);
        players.push(msg.sender);
    }

    function pickWinner() public payable onlyOwner {
        uint winnerIndex = random() % players.length;
        emit Winner(
            players[winnerIndex],
            players.length,
            address(this).balance
        );
        payable(players[winnerIndex]).transfer(address(this).balance);
        // reset contract
        players = new address[](0);
    }

    function random() private view returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }
}
