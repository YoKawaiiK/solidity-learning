// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

interface IERC20 {
    function getName() external view returns (string memory);

    function getSymbol() external view returns (string memory);

    function getDecimals() external view returns (uint8);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approve(address _sender, address _spender, uint256 _value);

    function getTotalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    // extended

    function mint(address _to, uint _value) external;

    function finishMinting() external returns (bool);

    function myBalance() external view returns (uint256 balance);
}
