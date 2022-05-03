// SPDX-License-Identifier: MIT

pragma solidity >0.8.0 <0.9.0;

import "./ownable.sol";
// import "./ierc20.sol";

contract ERC20 is Ownable {
    uint256 private constant MAX_UINT256 = 2**256 - 1;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public totalSupply;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _decimalUnits,
        uint256 _initialSupply
    ) {
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        // mint(msg.sender, _initialSupply);
    }

    modifier enoughTokens(address _from, uint256 _amount) {
        require(balanceOf(_from) >= _amount, "Not enough tokens!");
        _;
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
        enoughTokens(msg.sender, _value)
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
    ) public enoughTokens(_from, _value) returns (bool success) {
        _beforeTokenTransfer(_from, _to, _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _beforeTokenTransfer(_from, address(0), _amount);
        balances[_from] -= _amount;
        totalSupply -= _amount;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function myBalance() public view returns (uint256 balance) {
        return balances[msg.sender];
    }

    event Approve(address _sender, address _spender, uint256 _value);

    function approve(address _spender, uint256 _amount)
        public
        returns (bool success)
    {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function _approve(
        address _sender,
        address _spender,
        uint256 _amount
    ) internal virtual {
        allowances[_sender][_spender] = _amount;
        emit Approve(_sender, _spender, _amount);
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    event Mint(address indexed _to, uint256 _amount);
    event MintFinished();
    bool public mintingFinished = false;

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual {}

    function mint(address _to, uint _value) public onlyOwner {
        _beforeTokenTransfer(msg.sender, _to, _value);

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
