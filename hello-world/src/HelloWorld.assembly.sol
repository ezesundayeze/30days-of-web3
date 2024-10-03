// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract Hello {
    function sayHello() public pure returns (bytes32) {
        assembly {
            mstore(
                0,
                0x48656C6C6F20576F726C64210000000000000000000000000000000000000000
            ) // store `Hello World!` in hex starting from the 0th byte
            return(0, 32)
        }
    }
}

// Deployed contract on Sepolia testnet, 16 gas less than the Hello World using Solidity without assembly
// https://sepolia.etherscan.io/tx/0x3afc5b042ed6d7b47caad96c80fcb23c12aec7012681a7ef0ab61c6e97c047c0
