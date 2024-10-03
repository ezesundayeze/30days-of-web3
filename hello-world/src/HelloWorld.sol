// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract Hello {
    function sayHello() public pure returns (bytes32) {
        return "Hello World!";
    }
}
// Deployed contract on Sepolia testnet, 16 gas more than the Hello World using assembly
// https://sepolia.etherscan.io/tx/0x49e29d92e154060e3891657f1d7a90ec95593959332f627da5d534bbde5b9cc0
