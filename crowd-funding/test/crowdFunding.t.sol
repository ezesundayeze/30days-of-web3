// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../src/CrowdFunding.sol";

contract CrowdFundingTest is Test {
    CrowdFunding public crowdFunding;
    IERC20 public usdtToken;
    address owner = address(0x123);
    address donor = address(0x456);

    function setUp() public {
        usdtToken = new MockUSDT();

        // Deploy the CrowdFunding contract
        crowdFunding = new CrowdFunding(address(usdtToken), 1000);

        // Set initial balances
        deal(address(usdtToken), owner, 10000 * 10 ** 18);
        deal(address(usdtToken), donor, 10000 * 10 ** 18);

        // Label addresses for clarity in test output
        vm.label(owner, "Owner");
        vm.label(donor, "Donor");
    }

    function testDonate() public {
        // Prank the donor (set msg.sender to donor)
        vm.startPrank(donor);

        // Approve the contract to spend USDT on behalf of the donor
        usdtToken.approve(address(crowdFunding), 500);

        // Donate 500 USDT
        crowdFunding.donate(500);

        // Check balances and donations
        assertEq(crowdFunding.donations(donor), 500);
        assertEq(crowdFunding.totalAmountDonated(), 500);

        vm.stopPrank();
    }

    function testWithdraw() public {
        // Simulate a donation first to meet the target
        vm.startPrank(donor);
        usdtToken.approve(address(crowdFunding), 1000);
        crowdFunding.donate(1000);
        vm.stopPrank();

        // Now withdraw
        vm.prank(owner);
        crowdFunding.withdraw(owner);

        // Ensure the contract's balance is 0
        assertEq(usdtToken.balanceOf(address(crowdFunding)), 0);
    }
}

contract MockUSDT is ERC20 {
    uint8 private _decimals;

    constructor() ERC20("USDT", "Tether USD") {
        _decimals = 6;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
