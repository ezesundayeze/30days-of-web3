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
