// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../src/escrow.sol";

contract EscrowTest is Test {
    Escrow public escrow;
    IERC20 public usdtToken;
    address buyer = address(0x123); // Define buyer
    address seller = address(0x456); // Define seller

    function setUp() public {
        usdtToken = new MockUSDT();

        // Deploy the Escrow contract
        escrow = new Escrow(address(usdtToken));

        // Set initial balance for the buyer
        deal(address(usdtToken), buyer, 10000 * 10 ** 6);

        // Label addresses for clarity in test output
        vm.label(buyer, "Buyer");
        vm.label(seller, "Seller");
    }

    function testSellProduct() public {
        vm.startPrank(seller); // Use seller for this operation
        bytes memory productName = bytes("Laptop");

        // Seller lists a product
        escrow.sell(100 * 10 ** 6, productName);

        // Verify product details
        (
            uint256 id,
            ,
            uint256 price,
            ,
            bool isDelivered,
            bool isFundsReleased
        ) = escrow.products(1);

        assertEq(id, 1);
        assertEq(price, 100 * 10 ** 6);
        assertEq(isDelivered, false);
        assertEq(isFundsReleased, false);
    }

    function testBuyProduct() public {
        // Seller lists a product
        vm.prank(seller); // Seller lists the product
        escrow.sell(100 * 10 ** 6, bytes("Laptop"));

        // Buyer approves the Escrow contract to spend their USDT
        vm.prank(buyer);
        usdtToken.approve(address(escrow), 100 * 10 ** 6); // Approve $100 for the transaction

        // Buyer buys the product
        vm.prank(buyer); 
        escrow.buy(1); // Buy product with ID 1

        // Verify transaction details
        (, uint256 productId, uint256 amount, uint256 timestamp) = escrow
            .transactions(1);

        assertEq(productId, 1);
        assertEq(amount, 100 * 10 ** 6);
        assertGt(timestamp, 0);

        // Verify USDT balance after purchase
        assertEq(usdtToken.balanceOf(address(escrow)), 100 * 10 ** 6); // Escrow should have 100 USDT
        assertEq(usdtToken.balanceOf(buyer), 10000 * 10 ** 6 - 100 * 10 ** 6); // Buyer balance should decrease
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
