pragma solidity ^0.4.17;

import "Owned.sol";
import "EventToken.sol";

contract Event is Owned
{
    // Event token
    EventToken public token;

    // Number of seats total
    uint256 public seats;
    // Number of seats available
    uint256 public seatsAvailable;

    // Event Token Price (in wei)
    uint256 public price;

    // Cap on per-address seat hodling
    uint256 public rsvpCap;

    // Ticket Holder List (for processing cancellations and refunds)
    address[] public ticketHolders;

    // Tickets Purchased Receipt
    event TicketReceipt(uint256 ticketsBought, uint256 change);
    event RefundFailed(address holder, uint256 amount);

    function Event(uint256 _seats,
                   uint256 _price,
                   uint256 _rsvpCap)
        public
    {
        seats = _seats;
        seatsAvailable = seats;
        price = _price;
        rsvpCap = _rsvpCap;
        token = new EventToken(seats);
    }

    function min(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function buyTickets()
        public
        payable
    {
        // Must not be sold out
        require(seatsAvailable > 0);
        // Must be able to purchase at least one ticket
        require(msg.value >= price);
        // Sender asks for some amount of tickets (>= multiple of ticket price)
        uint256 ticketsWanted = msg.value / price;
        // Can only purchase seats left or remainder of personal cap, whichever is lowest
        uint256 ticketsAvailable = min(seatsAvailable, rsvpCap - token.balanceOf(msg.sender));
        uint256 ticketsBought = min(ticketsWanted, ticketsAvailable);
        // Transfer the tickets
        seatsAvailable -= ticketsBought;
        ticketHolders.push(msg.sender);
        token.transfer(msg.sender, ticketsBought);
        // Return the change
        uint256 change = msg.value - (ticketsBought * price);
        msg.sender.transfer(change);
        TicketReceipt(ticketsBought, change);
    }

    function refund(uint256 numTickets)
        public
    {
        // Will fail if not enough tickets
        token.transferFrom(msg.sender, this, numTickets);
        // Send refund once tickets are received
        msg.sender.transfer(numTickets * price);
    }

    function cancelEvent()
        public
        onlyOwner()
        returns (bool complete)
    {
        while (ticketHolders.length > 0)
        {
            // Break out and try again if there's not enough gas for the next loop + completion logic
            if (msg.gas < 60000) break;
            
            // Process refund list in reverse
            address holder = ticketHolders[ticketHolders.length-1];
            // "pop" the last entry
            delete ticketHolders[ticketHolders.length-1];
            // Send a refund if the holder has tickets to refund
            uint256 ticketsHeld = token.balanceOf(holder);
            if (ticketsHeld > 0)
            {
                // Get our tickets back
                token.transferFrom(holder, this, ticketsHeld);
                // Note refund failures, send them cash later
                if (holder.send(ticketsHeld * price))
                    RefundFailed(holder, ticketsHeld * price);
            }
        }
        return ticketHolders.length == 0;
    }

    function destroy()
        public
        onlyOwner()
    {
        // Only if no one holds tickets
        require(token.balanceOf(this) == seats);
        // Note we might have funds from failed refunds, send them manually
        selfdestruct(owner);
    }
}
