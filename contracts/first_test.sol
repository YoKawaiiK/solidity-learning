// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract FirstTest {
    string storedData;

    function set( string memory x) public {
        storedData = x;
    }

    function get() public view returns (string memory) {
        return storedData;
    }
}