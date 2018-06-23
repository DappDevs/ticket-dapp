/*
    This script is just to help ensure that your mnemonic is set up and working correctly
    If you haven't already, create the file mnemonic.secret.js with the following contents:

    module.exports = {'mnemonic': 'your string of words that equates to a private key so dont share it'}

*/
const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const { mnemonic } = require('./mnemonic.secret');

// Note use of rinkeby network. Change here to deploy to another network
//const networkURL = 'https://mainnet.infura.io/rHwTRH80oEUbN5W5EVBA';
const networkURL = 'https://rinkeby.infura.io/rHwTRH80oEUbN5W5EVBA';

const provider = new HDWalletProvider( mnemonic, networkURL, 0, 10 );

console.log("* mnemonic:",provider.mnemonic);
//console.log("* wallet address:",provider.address);

const web3 = new Web3(provider);

const check = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log('* accounts:',accounts);
}
check()
