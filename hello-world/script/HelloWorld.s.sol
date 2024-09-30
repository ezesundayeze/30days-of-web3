// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Script.sol";

contract HelloWorldScript is Script {
    function setup() public {}

    function run() public {
        vm.broadcast();
    }
}
