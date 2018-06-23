const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');

// Correction from earlier applied again
const provider = ganache.provider();
const web3 = new Web3(provider);

const { interface, bytecode } = require('../compile');

// No arguments:
// const deployment_arguments = { data: bytecode };

/* With arguments:
  address _token,
  string _eventDetailsURL,
  uint _eventCost,
  uint _ticketsLeft
*/
const deployment_arguments = { data: bytecode, arguments: ['0x74e1f5848c8d9eb41dae555af6068bebfd66f1dd', 'http://www.meetup.com/event', '300', '10']  };

let contract;
let accounts;

// Set up a helper to execute before each test, resetting state
beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    contract = await new web3.eth.Contract(JSON.parse(interface))
        .deploy( deployment_arguments )
        .send({ from: accounts[0], gas: '1000000' });

    // Need to mint some tokens and send them to the contract?

});

describe('TicketBooth Contract', () => {

    // Basic test - are we addressing a valid deployed contract?
    it('deploys a contract', () => {
        assert.ok(contract.options.address);
    });


    // Confirm that the data values were initialized
    it('correctly sets `token`', async () => {
        const token = await contract.methods.token().call();
        assert.equal( '0x74E1f5848C8D9eb41daE555AF6068BEbFd66f1dd', token);

    });

    it('correctly sets `eventDetailsURL`', async () => {

        const eventDetailsURL = await contract.methods.eventDetailsURL().call();
        assert.equal( 'http://www.meetup.com/event', eventDetailsURL);

    });

    it('correctly sets `eventCost`', async () => {
        const eventCost = await contract.methods.eventCost().call();
        assert.equal( 300, eventCost);

    });

    it('correctly sets `ticketsLeft`', async () => {
        const ticketsLeft = await contract.methods.ticketsLeft().call();
        assert.equal( 10, ticketsLeft);

    });

    // Test the functions

    // updateEventDetails
    it('allows the ticketmaster to update the event details', async () => {
        const url = 'https://www.somewhereelse.com/'
        const amount = '12345'
        await contract.methods.updateEventDetails( url, amount ).send({
            from: accounts[0],
            // value: web3.utils.toWei('0.02', 'ether')
        });

        const eventCost = await contract.methods.eventCost().call();
        assert.equal( 12345, eventCost );

        const eventDetailsURL = await contract.methods.eventDetailsURL().call();
        assert.equal( 'https://www.somewhereelse.com/', eventDetailsURL);
    });

    it('does not allow someone other that the ticketmaster to update event details', async () => {
        const url = 'https://www.somewhereelse.com/'
        const amount = '12345'

        try {
            await contract.methods.updateEventDetails( url, amount ).send({
                from: accounts[1],
                // value: web3.utils.toWei('0.02', 'ether')
            });
            assert(false);
        } catch (err) {
            assert(err);
        }

    });

    // updateTicketsLeft
    it('allows ticketmaster to update the number of tickets left', async () => {
        const newcount = 55

        await contract.methods.updateTicketsLeft(newcount).send({
            from:accounts[0],
            gas:1000000
        });

        const ticketsLeft = await contract.methods.ticketsLeft().call();
        assert.equal( newcount, ticketsLeft);

     });

    // buyTicket
    it('allows a user to buy a ticket', async () => {

        // Before purchasing, should have no ticket
        const before = await contract.methods.ticketHolders( accounts[1] ).call();
        assert.equal( 0, before.bought );

        await contract.methods.buyTicket().send({
            from:accounts[1],
            value: 300,
            gas:1000000
        });

        // After purchasing, should have one ticket
        const after = await contract.methods.ticketHolders( accounts[1] ).call();
        assert.equal( 1, after.bought );

     });

    // refundTicket
    it('allows a user to get a refund on a ticket', async () => {

        await contract.methods.buyTicket().send({
            from:accounts[1],
            value: 300,
            gas:1000000
        });

        // After purchasing, should have one ticket
        const after = await contract.methods.ticketHolders( accounts[1] ).call();
        assert.equal( 1, after.bought );

        await contract.methods.refundTicket().send({
            from:accounts[1],
            gas:1000000
        });

        // After refund, should have no ticket
        const refunded = await contract.methods.ticketHolders( accounts[1] ).call();
        assert.equal( 0, refunded.bought );

     });

});
