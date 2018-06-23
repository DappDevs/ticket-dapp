var contract = 'TicketBooth';
// assumes you have ./contracts/NAME.sol

const path = require('path');
const fs = require('fs');
const solc = require('solc');

const contractFilePath = path.resolve(__dirname, 'contracts', contract+'.sol');
const source = fs.readFileSync(contractFilePath, 'utf8');

// Sneak a peek at the source:
// console.log( solc.compile(source, 1) );

/*
const { interface, bytecode } = solc.compile(source, 1).contracts[':'+contract]
console.log("abi", interface);
console.log("bytecode", bytecode);
*/

module.exports = solc.compile(source, 1).contracts[':'+contract]

console.log( 'Contract compilation for '+contract+' completed successfully' );
