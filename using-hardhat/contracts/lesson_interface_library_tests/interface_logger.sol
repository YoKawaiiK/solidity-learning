// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface InterfaceLogger {
    function log(address _from, uint _amount) external;

    function getEntry(address _from, uint _index) external view returns (uint);
}
