pragma solidity ^0.4.21;

/* @title TicketBooth contract
 *
 * @author RJ Herrick
 * @author DappDevs @ UConn 3/24/2018
 * @author Bryant Eisenbach
 *
 * @notice Contract Specification:
 *
 * Contract is created by an event organizer
 * (aka "Ticket Master") who is collecting ETH
 * in order to host an event (each deployed
 * contract is an event).
 *
 * Users (aka "Ticket Holders") wish to purchase
 * tickets to attend the event. They can purchase
 * exactly 1 ticket each, and can request a refund
 * up until the event is closed.
 *
 * The Ticket Master can "punch" a ticket, thereby
 * validating entry for a particular Ticket Holder,
 * and giving that ticket holder an amount of a
 * reward token in return for showing up.
 *
 */

contract TicketBooth
{
    /* STATE VARIABLES */
    
    // Event meta-data
    string public eventName;
    uint public eventDate;
    uint public eventCost; // wei
    uint public ticketsLeft;
    
    // Organizer
    address public ticketMaster;
    
    // Struct for managing user data
    struct User {
        bool hasPaid;
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
     * @param _eventName (string) The event's name
     * @param _eventDate (uint) UTC timestamp of the event's start time
     * @param _eventCost (uint "wei") Cost of purchasing a ticket
     * @param _ticketsLeft (uint) Number of tickets available for purchase
     */
    function TicketBooth (
        string _eventName,
        uint _eventDate,
        uint _eventCost,
        uint _ticketsLeft
    )
        public
    {
        ticketMaster = msg.sender;
        eventName = _eventName;
        eventDate = _eventDate;
        eventCost = _eventCost;
        ticketsLeft = _ticketsLeft;
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
    {
        require(msg.sender == ticketMaster);
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
        require(!ticketHolders[msg.sender].hasPaid);
        
        // Enough money was provided to purchase the ticket
        require(msg.value >= eventCost);
        
        // There are enough tickets left to buy
        require(ticketsLeft > 0); // State check; Underflow protection
        
        // Buy a ticket
        ticketsLeft -= 1; // Cannot underflow, only decrements by one; re-entrancy protection
        
        // Log User's purchase
        ticketHolders[msg.sender] = User(true, eventCost);
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
        // It is before the start time
        require(now < eventDate);

        // User has ticket(s) to refund
        require(ticketHolders[msg.sender].hasPaid); // State check; re-entrancy protection
        
        // Process refund
        uint pricePaid = ticketHolders[msg.sender].pricePaid;
        delete ticketHolders[msg.sender]; // Remove from storage; re-entrancy protection
        ticketsLeft += 1; // Cannot overflow, limited to amount of ticket holders
        msg.sender.transfer(pricePaid); // external call
        emit TicketRefund(msg.sender, 1, eventCost);
    }
}
