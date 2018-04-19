pragma solidity ^0.4.20;

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
 */

contract TicketBooth
{
    /* STATE VARIABLES */
    
    // Event meta-data
    string public eventDetailsIPFSHash;
    uint public eventCost; // wei
    
    // @dev Keep track of total tickets
    // Note: total = bought + left
    uint public ticketsBought;
    uint public ticketsLeft;
    
    //
    bool public eventStarted;
    
    // Organizer
    address public ticketMaster;
    
    // Struct for managing user data
    struct User {
        bool hasPaid;
        bool punched;
        uint pricePaid;
    }
    
    // Storage of each user data record
    mapping(address => User) public ticketHolders;

    /* EVENTS */
    event TicketPurchase(address purchaser, uint numberOfTickets, uint pricePaid);
    event TicketRefund(address purchaser, uint numberOfTickets, uint amountRefunded);

    /* 
     * @notice Initialize Contract Parameters
     *
     * @param _eventDetailsIPFSHash (string) The event's details stored in IPFS
     * @param _eventDate (uint) UTC timestamp of the event's start time
     * @param _eventCost (uint "wei") Cost of purchasing a ticket
     * @param _ticketsLeft (uint) Number of tickets available for purchase
     */
    function TicketBooth (
        string _eventDetailsIPFSHash,
        uint _eventCost,
        uint _ticketsLeft
    )
        public
    {
        ticketMaster = msg.sender;
        eventDetailsIPFSHash = _eventDetailsIPFSHash;
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
     * @param _eventDetailsIPFSHash (string) The event's details stored in IPFS
     */
    function updateEventDetails(string _eventDetailsIPFSHash)
        public
        onlyTicketMaster()
    {
        eventDetailsIPFSHash = _eventDetailsIPFSHash;
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
    function getTicket()
        public
        payable
    {
        // User is below per-user limit of ticket(s)
        require(!ticketHolders[msg.sender].hasPaid); // Re-entrancy protection
        
        // Enough money was provided to purchase the ticket
        require(msg.value >= eventCost);
        
        // There are enough tickets left to buy
        require(ticketsLeft > 0); // State check; Underflow protection
        
        // Buy a ticket
        ticketsLeft -= 1; // Cannot underflow, only decrements by one
        ticketsBought += 1; // Should not overflow, only increments by one
        
        // Log User's purchase
        ticketHolders[msg.sender].hasPaid = true; // Re-entrancy protection
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
        // Event hasn't started yet
        require(!eventStarted);

        // User has ticket(s) to refund
        require(ticketHolders[msg.sender].hasPaid); // State check; re-entrancy protection
        
        // Process refund
        uint pricePaid = ticketHolders[msg.sender].pricePaid;
        delete ticketHolders[msg.sender]; // Remove from storage; re-entrancy protection
        ticketsLeft += 1; // Cannot overflow, limited to amount of ticket holders
        ticketsBought -= 1; // Cannot underflow, limited matches number of possible refunds
        msg.sender.transfer(pricePaid); // external call
        emit TicketRefund(msg.sender, 1, eventCost);
    }

    function punchTicket(address _ticketHolder)
        public
        onlyTicketMaster()
    {
        // Set the event started if it isn't
        eventStarted = true;

        // Punch Ticket Holder's ticket
        ticketHolders[_ticketHolder].punched = true;
    }

    function finalizeEvent()
        public
        onlyTicketMaster()
    {
        // Ensure that an event happened before withdrawels are possible
        require(eventStarted);

        // Ticket master gets the funds raised from the event
        selfdestruct(ticketMaster);
    }
}
