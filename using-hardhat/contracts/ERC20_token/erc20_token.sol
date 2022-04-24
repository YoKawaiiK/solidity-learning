// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

import "./ownable.sol";

contract ERC20Token is Ownable {
    uint256 private constant MAX_UINT256 = 2**256 - 1;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public totalSupply;

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getName() public view returns (string memory) {
        return name;
    }

    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    function getDecimals() public view returns (uint8) {
        return decimals;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        uint256 allowanceToken = allowed[_from][msg.sender];
        require(
            balances[_from] >= _value && allowanceToken >= _value,
            "Don't enough token in wallet"
        );

        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowanceToken < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    
    function myBalance() public view returns (uint256 balance) {
        return balances[msg.sender];
    }

    event Approval(address _sender, address _spender, uint256 _value);

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    event Mint(address indexed _to, uint256 _amount);
    event MintFinished();
    bool public mintingFinished = false;

    function mint(address _to, uint _value) public onlyOwner {
        assert(
            (totalSupply + _value >= totalSupply) &&
                (balances[_to] + _value >= balances[_to])
        );

        require(!mintingFinished);
        balances[_to] += _value;
        totalSupply += _value;
        emit Mint(_to, _value);
    }

    uint public ownerPercentage = 25;

    function finishMinting() public onlyOwner returns (bool) {
        require(!mintingFinished);

        // task: add minting token for the owner as a percentage
        payable(owner).transfer((totalSupply * ownerPercentage) / 100);

        mintingFinished = true;

        emit MintFinished();
        return true;
    }
}
