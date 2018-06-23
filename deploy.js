const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');

// use our compile.js script to produce the ABI + bytecode
const { interface, bytecode } = require('./compile');

// For contracts...
// WITHOUT arguments: 
//const deployment_arguments = { data: bytecode };

// WITH arguments:
const deployment_arguments = { data: bytecode, arguments: [
    '0x74e1f5848c8d9eb41dae555af6068bebfd66f1dd',
    'https://www.eventbrite.com/e/blockchain-development-training-w-ethereum-tickets-45391823165',
    '634936955012370048', // price in wei, ~$300 2018-6-22
    '10'
    ] };
/*
  ARG cheatsheet:
  address _token,
  string _eventDetailsURL,
  uint _eventCost,
  uint _ticketsLeft
*/

// Use your mnemonic to allow access to the wallet and ALL accounts generated from it
// This wallet will need some ether to deploy!
const { mnemonic } = require('./mnemonic.secret');

// Deploy from first wallet account
const which_wallet_acct = 0; // First

// Select network
const network = 
// 'mainnet';
    'rinkeby';
// 'infuranet';
// 'ropsten';
// 'kovan';

// Note use of rinkeby network. Change here to deploy to another network
const networkURL = 'https://'+network+'.infura.io/rHwTRH80oEUbN5W5EVBA';

const provider = new HDWalletProvider( mnemonic, networkURL );

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log('Attempting to deploy from account', accounts[which_wallet_acct]);

    const result = await new web3.eth.Contract(JSON.parse(interface))
        .deploy( deployment_arguments )
        .send( {gas: '1000000', from: accounts[which_wallet_acct]} )

    //console.log('ABI', abi);
    console.log('Contract deployed to', result.options.address )

    let network_prefix = network + '.';
    if ('mainnet' === network) network_prefix = '';
    console.log('See https://'+network_prefix+'etherscan.io/address/'+result.options.address);
}
deploy().catch(function (e) {
     console.log("Deployment failed. :(\n","Details:\n",e);
});

