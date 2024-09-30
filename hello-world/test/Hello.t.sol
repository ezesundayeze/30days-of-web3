// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/HelloWorld.sol";

contract HelloTest is Test {
    Hello public hello;

    // Setup the contract instance before tests
    function setUp() public {
        hello = new Hello();
    }

    // Test if the sayHello() function returns the expected string
    function testSayHello() public view {
        bytes32 expected = "Hello World!";
        bytes32 result = hello.sayHello();
        console.log(string(abi.encodePacked(result)));

        assertEq(
            result,
            expected,
            "sayHello() did not return the expected string."
        );
    }

    function testEmptyString() public view {
        bytes32 result = hello.sayHello();

        assertTrue(
            result != bytes32(0),
            "sayHello() should not return an empty string"
        );
    }

    function testDeployment() public view {
        assertTrue(address(hello) != address(0), "Contract deployment failed");
    }
}
