// This file allows us to get a handle for our deployed instance easily
import web3 from './web3';

// The deployed contract address
const address = '0x6962141b7e644c1f4bc6d9937952fd653cbf9d98';

// A static copy of the ABI. There are better ways, but not with React set up like this. Left as an exercise to the reader.
const abi = 
[
	{
		"constant": false,
		"inputs": [],
		"name": "buyTicket",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "confirmEvent",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "finalizeEvent",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_ticketHolder",
				"type": "address"
			}
		],
		"name": "punchTicket",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "refundTicket",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "purchaser",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "numberOfTickets",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "pricePaid",
				"type": "uint256"
			}
		],
		"name": "TicketPurchase",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "ticketholder",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "numberOfTickets",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "amountRefunded",
				"type": "uint256"
			}
		],
		"name": "TicketRefund",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "attendee",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "numberOfTickets",
				"type": "uint256"
			}
		],
		"name": "TicketPunch",
		"type": "event"
	},
	{
		"inputs": [
			{
				"name": "_token",
				"type": "address"
			},
			{
				"name": "_eventDetailsURL",
				"type": "string"
			},
			{
				"name": "_eventCost",
				"type": "uint256"
			},
			{
				"name": "_ticketsLeft",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_eventDetailsURL",
				"type": "string"
			}
		],
		"name": "updateEventDetails",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_ticketsLeft",
				"type": "uint256"
			}
		],
		"name": "updateTicketsLeft",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "eventConfirmed",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "eventCost",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "eventDetailsURL",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "ticketHolders",
		"outputs": [
			{
				"name": "bought",
				"type": "bool"
			},
			{
				"name": "punched",
				"type": "bool"
			},
			{
				"name": "pricePaid",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "ticketMaster",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "ticketsBought",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "ticketsLeft",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "token",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
]
;

export default new web3.eth.Contract(abi, address);
