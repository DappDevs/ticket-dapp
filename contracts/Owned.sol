pragma solidity ^0.4.17;

contract Owned
{
    // Owner who put up this contract
    address public owner = msg.sender;
    
    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner()
    {
        require(msg.sender == owner);

        _;
    }
    
    // Change owner
    function changeOwner(address newOwner)
        public
        onlyOwner()
    {
        owner = newOwner;
    }
}
