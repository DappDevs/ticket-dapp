import Web3 from 'web3';

// grab the global web3 from metamask and use 
// the provider to boot our new updated library's provider
const web3 = new Web3(window.web3.currentProvider);

export default web3;