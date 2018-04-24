pragma solidity ^0.4.20;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
// Constructed according to OpenZeppelin Burnable Token contract
// https://github.com/OpenZeppelin/zeppelin-solidity/
interface BurnableERC20
{
    /* ERC20 BASIC */
    // Get the total token supply
    function totalSupply() public constant returns (uint256 _totalSupply);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);
 
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    /* ERC20 Standard */
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) public returns (bool success);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
 
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    
    /* BURNABLE ERC20 */
    // Burn _value amount of your own tokens
    function burn(uint256 _value) public;

    // Triggered whenever burn(uint256 _value) is called
    event Burn(address indexed burner, uint256 value);
}

/* @title TicketBooth contract
 *
 * @author RJ Herrick
 * @author DappDevs @ UConn 3/24/2018
 * @author Bryant Eisenbach
 *
 * @notice Contract Specification:
 *
 * Contract is created by an event organizer (aka "Ticket Master") who is
 * collecting ETH in order to host an event (each deployed contract is an event).
 *
 * Users (aka "Ticket Holders") wish to purchase tickets to attend the event.
 * They can purchase exactly 1 ticket each, and can request a refund up until
 * the event is closed.
 *
 * The Ticket Master can "punch" a ticket, thereby validating entry for
 * a particular Ticket Holder, and giving that ticket holder an amount of
 * a reward token in return for showing up.
 * 
 * Requirements ("Ticket Booth" contract):
 * @req 01 Ticket Booth has an Administrator (referred to as "Ticket Master").
 * @req 02 Ticket Booth lets any User purchase exactly one ticket (referred to as "Ticket Holder").
 * @req 03 Ticket Booth has a link to the event details.
 * @req 04 Ticket Booth has a ticket price.
 * @req 05 Ticket Booth has a defined number of tickets to sell.
 * @req 06 Ticket Booth has a refund period for tickets that are sold.
 * @req 07 A Ticket Holder can claim a refund for their ticket during the refund period.
 * @req 08 Ticket Master can update the event details link.
 * @req 09 Ticket Master can change the ticket price.
 * @req 10 Ticket Master can change the number of tickets for sale.
 * @req 11 Ticket Master validates Ticket Holder attendance to event.
 * @req 12 Ticket Master can withdraw event funds when the event is completed.
 */

contract TicketBooth
{
    /* STATE VARIABLES */
    // Reward Token address
    BurnableERC20 public token;
    
    // Event meta-data
    string public eventDetailsURL;
    uint public eventCost; // wei
    
    // @dev Keep track of total tickets
    // Note: total = bought + left
    uint public ticketsBought;
    uint public ticketsLeft;
    
    // Record when event is started (locking out purchases/refunds)
    bool public eventConfirmed;
    
    // Organizer
    address public ticketMaster;
    
    // Struct for managing user data
    struct User {
        bool bought;
        bool punched;
        uint pricePaid;
    }
    
    // Storage of each user data record
    mapping(address => User) public ticketHolders;

    /* EVENTS */
    event TicketPurchase(address purchaser, uint numberOfTickets, uint pricePaid);
    event TicketRefund(address ticketholder, uint numberOfTickets, uint amountRefunded);
    event TicketPunch(address attendee, uint numberOfTickets);

    /* 
     * @notice Initialize Contract Parameters
     *
     * @param _eventDetailsURL (string) The event's details stored in IPFS
     * @param _eventDate (uint) UTC timestamp of the event's start time
     * @param _eventCost (uint "wei") Cost of purchasing a ticket
     * @param _ticketsLeft (uint) Number of tickets available for purchase
     */
    function TicketBooth (
        address _token,
        string _eventDetailsURL,
        uint _eventCost,
        uint _ticketsLeft
    )
        public
    {
        ticketMaster = msg.sender;
        token = BurnableERC20(_token);
        eventDetailsURL = _eventDetailsURL;
        eventCost = _eventCost;
        ticketsLeft = _ticketsLeft;
    }

    /* 
     * @notice Enforce only Ticket Master ACL
     */
    modifier onlyTicketMaster()
    {
        require(msg.sender == ticketMaster);
        _;
    }

    /* 
     * @notice Update the details of the event
     * @dev Only ticketMaster may do this
     *
     * @param _eventDetailsURL (string) The event's details stored in IPFS
     */
    function updateEventDetails(string _eventDetailsURL)
        public
        onlyTicketMaster()
    {
        eventDetailsURL = _eventDetailsURL;
    }

    /* 
     * @notice Update amount of tickets available for purchase
     * @dev Only ticketMaster may do this
     *
     * @param _ticketsLeft (uint) Number of tickets available for purchase
     * @dev By setting the amount of tickets left, ticketMaster can control
     *      future purchases, but not affect past purchases or refunds.
     */
    function updateTicketsLeft(uint _ticketsLeft)
        public
        onlyTicketMaster()
    {
        ticketsLeft = _ticketsLeft;
    }

    /* 
     * @notice Anyone can buy a ticket
     * @dev All amount over the ticket price must be refunded
     * @dev Function is payable, must send more than a ticket costs
     */
    function buyTicket()
        public
        payable
    {
        // User is below per-user limit of ticket(s)
        require(!ticketHolders[msg.sender].bought); // Re-entrancy protection
        
        // Enough money was provided to purchase the ticket
        require(msg.value >= eventCost);
        
        // There are enough tickets left to buy
        require(ticketsLeft > 0); // State check; Underflow protection
        
        // Buy a ticket
        ticketsLeft -= 1; // Cannot underflow, only decrements by one
        ticketsBought += 1; // Should not overflow, only increments by one
        
        // Log User's purchase
        ticketHolders[msg.sender].bought = true; // Re-entrancy protection
        ticketHolders[msg.sender].pricePaid = eventCost;
        emit TicketPurchase(msg.sender, 1, eventCost);
        
        // Refund user's change from purchase (external call)
        msg.sender.transfer(msg.value-eventCost);
    }

    /* 
     * @notice Ticket Purchasers can refund a ticket before the start time
     */
    function refundTicket()
        public
    {
        // Event hasn't been confirmed yet
        require(!eventConfirmed);

        // User has ticket(s) to refund
        require(ticketHolders[msg.sender].bought); // State check; re-entrancy protection
        
        // Process refund
        uint pricePaid = ticketHolders[msg.sender].pricePaid;
        delete ticketHolders[msg.sender]; // Remove from storage; re-entrancy protection
        ticketsLeft += 1; // Cannot overflow, limited to amount of ticket holders
        ticketsBought -= 1; // Cannot underflow, limited matches number of possible refunds
        msg.sender.transfer(pricePaid); // external call
        emit TicketRefund(msg.sender, 1, eventCost);
    }
        
    function confirmEvent()
        public
        onlyTicketMaster()
    {
        // Event hasn't been confirmed yet
        require(!eventConfirmed);
        
        // Someone has transferred tokens to this contract
        require(token.balanceOf(this) == ticketsBought);
        
        // Set the event started
        eventConfirmed = true;
    }


    function punchTicket(address _ticketHolder)
        public
        onlyTicketMaster()
    {
        // Event is locked in!
        require(eventConfirmed);

        // Punch Ticket Holder's ticket
        ticketHolders[_ticketHolder].punched = true;

        // Give them their reward token(s)
        token.transfer(_ticketHolder, 1);

        // Alert ticket is punched
        emit TicketPunch(_ticketHolder, 1);
    }

    function finalizeEvent()
        public
        onlyTicketMaster()
    {
        // Ensure that an event happened
        require(eventConfirmed);

        // Burn the rest of the tokens (people who didn't show up)
        token.burn(token.balanceOf(this));

        // Ticket master gets the funds raised from the event
        selfdestruct(ticketMaster);
    }
}
