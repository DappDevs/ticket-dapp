pragma solidity ^0.4.17;

import "Owned.sol";
import "ERC20Token.sol";

contract EventToken is Owned, ERC20Token
{
    uint256 _totalSupply;
 
    // Balances for each account
    mapping(address => uint256) public balances;
 
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
 
    // Constructor
    function EventToken(uint256 initialSupply)
        public
    {
        _totalSupply = initialSupply;
        balances[owner] = _totalSupply;
    }
 
    function totalSupply()
        public
        constant
        returns (uint256)
    {
        return _totalSupply;
    }
 
    // What is the balance of a particular account?
    function balanceOf(address _owner)
        public
        constant
        returns (uint256)
    {
        return balances[_owner];
    }
 
    // Transfer the balance from owner's account to another account
    function transfer(address _to,
                      uint256 _amount)
        public
        returns (bool success)
    {
        // Departure from typical ERC20 Implementation
        require(balances[msg.sender] >= _amount);
        require(_amount > 0);
        require(balances[_to] + _amount > balances[_to]);

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);

        return true;
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from,
                          address _to,
                          uint256 _amount)
        public
        returns (bool success)
    {
        // Departure from typical ERC20 Implementation
        require(_amount > 0);
        require(msg.sender == owner);
        require(balances[_from] >= _amount);
        require(balances[_to] + _amount > balances[_to]);
        
        balances[_from] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    }
 
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender,
                     uint256 _amount)
        public
        returns (bool success)
    {
        // Only owner is allowed to do anything with transferFrom
        require(_amount == balanceOf(msg.sender));
        if (_spender == owner)
            return true;
        return false;
    }
 
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining)
    {
        // Only owner is allowed to do anything with transferFrom
        if (_spender == owner)
        {
            return balances[_owner];
        } else {
            return 0;
        }
    }
}
