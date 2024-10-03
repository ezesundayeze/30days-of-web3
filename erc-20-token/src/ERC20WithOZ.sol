// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Lace is ERC20 {
    constructor() ERC20("LazyToken", "LZ") {
        _mint(msg.sender, 1000000 * 10e8);
    }
}
